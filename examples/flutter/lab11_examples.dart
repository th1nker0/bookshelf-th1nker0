// ===========================================================================
//  Разбор примеров к лабораторной работе №11
//  Пакеты, зависимости и хранение данных в SQLite
// ===========================================================================
//
//      flutter run -t lib/examples/lab11_examples.dart
//
//  Пример требует зависимостей, которые подключаются в задании 2
//  лабораторной работы:
//      flutter pub add sqflite path path_provider shared_preferences
// ===========================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(const ExampleApp());

// @MODEL@
/// Модель для базы отличается от модели для JSON двумя вещами:
/// у неё есть id (его назначает база) и метод toMap вместо toJson —
/// SQLite не умеет хранить списки и вложенные объекты.
class Movie {
  final int? id;
  final String title;
  final String director;
  final int year;

  const Movie({
    this.id,
    required this.title,
    required this.director,
    this.year = 0,
  });

  Map<String, Object?> toMap() => <String, Object?>{
    // id не передаём при вставке: база назначит его сама
    if (id != null) 'id': id,
    'title': title,
    'director': director,
    'year': year,
  };

  factory Movie.fromMap(Map<String, Object?> row) => Movie(
    id: row['id'] as int?,
    title: row['title'] as String? ?? '',
    director: row['director'] as String? ?? '',
    year: (row['year'] as num?)?.toInt() ?? 0,
  );

  Movie copyWith({int? id}) =>
      Movie(id: id ?? this.id, title: title, director: director, year: year);
}
// @MODEL_END@

// @REPO@
/// Интерфейс репозитория. Экраны зависят ОТ НЕГО, а не от sqflite:
/// в тестах можно подставить реализацию в памяти, а источник данных
/// заменить, не трогая интерфейс.
abstract interface class MovieRepository {
  Future<List<Movie>> findAll({String? query});
  Future<Movie> insert(Movie movie);
  Future<void> update(Movie movie);
  Future<void> delete(int id);
  Future<void> close();
}

class SqfliteMovieRepository implements MovieRepository {
  static const String _table = 'movies';
  Database? _db;

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    // Путь к каталогу приложения даёт path_provider: писать
    // в произвольное место мобильная система не позволит
    final Directory dir = await getApplicationDocumentsDirectory();

    return openDatabase(
      // Склейка пути — пакетом path, а не вручную
      p.join(dir.path, 'movies.db'),
      version: 1,
      // Вызывается ОДИН раз при первом создании базы
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            title    TEXT    NOT NULL,
            director TEXT    NOT NULL,
            year     INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('CREATE INDEX idx_title ON $_table (title)');
      },
      // Вызывается при повышении номера версии — здесь миграции
      onUpgrade: (Database db, int oldV, int newV) async {
        if (oldV < 2) {
          await db.execute('ALTER TABLE $_table ADD COLUMN rating REAL');
        }
      },
    );
  }

  @override
  Future<List<Movie>> findAll({String? query}) async {
    final Database db = await _database;
    final List<Map<String, Object?>> rows = await db.query(
      _table,
      // Значения подставляются ТОЛЬКО через ? и whereArgs.
      // Склейка строк открыла бы внедрение SQL и ломалась бы
      // на любом апострофе в названии.
      where: (query == null || query.isEmpty) ? null : 'title LIKE ?',
      whereArgs: (query == null || query.isEmpty)
          ? null
          : <Object?>['%$query%'],
      orderBy: 'title COLLATE NOCASE',
    );
    return rows.map(Movie.fromMap).toList();
  }

  @override
  Future<Movie> insert(Movie movie) async {
    final Database db = await _database;
    final int id = await db.insert(_table, movie.toMap());
    return movie.copyWith(id: id);
  }

  @override
  Future<void> update(Movie movie) async {
    final Database db = await _database;
    await db.update(
      _table,
      movie.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[movie.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final Database db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: <Object?>[id]);
  }

  @override
  Future<void> close() async => _db?.close();
}
// @REPO_END@

// @BATCH@
/// Пакетная вставка. Тысяча отдельных insert — тысяча транзакций;
/// batch выполняет их одной. Разница заметна уже на сотнях записей.
Future<void> insertMany(Database db, List<Movie> movies) async {
  final Batch batch = db.batch();
  for (final Movie movie in movies) {
    batch.insert('movies', movie.toMap());
  }
  await batch.commit(noResult: true);
}
// @BATCH_END@

// @PREFS@
/// shared_preferences — для небольших настроек, а не для данных.
/// Аналоги: SharedPreferences в Android, UserDefaults в iOS.
class Settings {
  static const String _keyGrid = 'view_as_grid';

  Future<bool> loadGridMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Ключа может не быть при первом запуске — отсюда ?? false
    return prefs.getBool(_keyGrid) ?? false;
  }

  Future<void> saveGridMode(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGrid, value);
  }
}
// @PREFS_END@

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    home: const DatabaseScreen(),
  );
}

// @FUTUREBUILDER@
class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  final MovieRepository _repository = SqfliteMovieRepository();
  late Future<List<Movie>> _future;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _future = _repository.findAll();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  void _reload() {
    // ВАЖНО: тело в фигурных скобках, а не стрелка. Запись
    // setState(() => _future = ...) вернула бы Future, и Flutter
    // упал бы с «setState() callback argument returned a Future».
    // Анализатор такую ошибку не ловит — видна только при запуске.
    setState(() {
      _future = _repository.findAll();
    });
  }

  Future<void> _add() async {
    _counter++;
    await _repository.insert(
      Movie(
        title: 'Фильм $_counter',
        director: 'Режиссёр',
        year: 2000 + _counter,
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite'),
        actions: <Widget>[
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      // FutureBuilder обрабатывает ТРИ состояния, а не одно
      body: FutureBuilder<List<Movie>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
          // 1. Ждём
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Ошибка
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Ошибка: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          // 3. Данные
          final List<Movie> movies = snapshot.data ?? <Movie>[];
          if (movies.isEmpty) {
            return const Center(child: Text('Пусто. Нажмите «+»'));
          }
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (BuildContext context, int index) {
              final Movie movie = movies[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${movie.id}')),
                title: Text(movie.title),
                subtitle: Text('${movie.director}, ${movie.year}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await _repository.delete(movie.id!);
                    _reload();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// @FUTUREBUILDER_END@
