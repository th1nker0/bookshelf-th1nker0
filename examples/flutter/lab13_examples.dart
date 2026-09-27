// ===========================================================================
//  Разбор примеров к лабораторной работе №13
//  Архитектура и управление состоянием
// ===========================================================================
//
//      flutter pub add provider
//      flutter run -t lib/examples/lab13_examples.dart
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const ExampleApp());

// @MODEL@
class Movie {
  final int? id;
  final String title;
  final bool watched;

  const Movie({this.id, required this.title, this.watched = false});

  Movie copyWith({int? id, bool? watched}) =>
      Movie(id: id ?? this.id, title: title, watched: watched ?? this.watched);
}

/// Слой данных: экраны зависят от этого интерфейса, а не от SQLite.
abstract interface class MovieRepository {
  Future<List<Movie>> findAll();
  Future<Movie> insert(Movie movie);
  Future<void> update(Movie movie);
  Future<void> delete(int id);
}

/// Реализация в памяти. В настоящем приложении здесь была бы SQLite,
/// но ИМЕННО такая подставная реализация используется в тестах —
/// база для них не нужна.
class InMemoryMovieRepository implements MovieRepository {
  final List<Movie> _items = <Movie>[
    const Movie(id: 1, title: 'Интерстеллар', watched: true),
    const Movie(id: 2, title: 'Начало'),
    const Movie(id: 3, title: 'Престиж'),
  ];
  int _nextId = 4;

  @override
  Future<List<Movie>> findAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<Movie>.unmodifiable(_items);
  }

  @override
  Future<Movie> insert(Movie movie) async {
    final Movie saved = movie.copyWith(id: _nextId++);
    _items.add(saved);
    return saved;
  }

  @override
  Future<void> update(Movie movie) async {
    final int i = _items.indexWhere((Movie m) => m.id == movie.id);
    if (i != -1) {
      _items[i] = movie;
    }
  }

  @override
  Future<void> delete(int id) async =>
      _items.removeWhere((Movie m) => m.id == id);
}
// @MODEL_END@

// @VIEWMODEL@
/// Слой состояния — роль ViewModel в схеме MVVM.
///
/// Обратите внимание: здесь НЕТ ни одного импорта виджетов.
/// Модель ничего не знает об интерфейсе, поэтому её можно проверить
/// обычным модульным тестом, без запуска приложения.
class MovieListModel extends ChangeNotifier {
  final MovieRepository _repository;
  MovieListModel(this._repository);

  List<Movie> _movies = const <Movie>[];
  bool _loading = false;
  String? _error;
  bool _onlyWatched = false;

  // Наружу — только чтение
  bool get isLoading => _loading;
  String? get error => _error;
  bool get onlyWatched => _onlyWatched;
  int get watchedCount => _movies.where((Movie m) => m.watched).length;

  List<Movie> get movies =>
      _onlyWatched ? _movies.where((Movie m) => m.watched).toList() : _movies;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners(); // сообщаем подписчикам: началась загрузка

    try {
      _movies = await _repository.findAll();
    } catch (e) {
      _error = 'Не удалось загрузить: $e';
    } finally {
      _loading = false;
      notifyListeners(); // и ещё раз: данные готовы или произошла ошибка
    }
  }

  Future<void> toggleWatched(Movie movie) async {
    final Movie updated = movie.copyWith(watched: !movie.watched);
    await _repository.update(updated);
    _movies = _movies.map((Movie m) => m.id == movie.id ? updated : m).toList();
    notifyListeners();
  }

  Future<void> add(String title) async {
    final Movie saved = await _repository.insert(Movie(title: title));
    _movies = <Movie>[..._movies, saved];
    notifyListeners();
  }

  void setFilter(bool onlyWatched) {
    _onlyWatched = onlyWatched;
    notifyListeners();
  }
}
// @VIEWMODEL_END@

// @PROVIDE@
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Слой данных
        Provider<MovieRepository>(
          create: (BuildContext context) => InMemoryMovieRepository(),
        ),
        // Слой состояния зависит от слоя данных, а не создаёт его сам.
        // Это и есть внедрение зависимости.
        ChangeNotifierProvider<MovieListModel>(
          create: (BuildContext context) =>
              MovieListModel(context.read<MovieRepository>())..load(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MovieListScreen(),
      ),
    );
  }
}
// @PROVIDE_END@

// @CONSUME@
class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch подписывает виджет на изменения: при notifyListeners
    // этот build выполнится заново
    final MovieListModel model = context.watch<MovieListModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MVVM и provider'),
        actions: <Widget>[
          // Selector следит ТОЛЬКО за одним значением: перестроится,
          // когда изменится счётчик, но не когда изменится фильтр
          Selector<MovieListModel, int>(
            selector: (BuildContext context, MovieListModel m) =>
                m.watchedCount,
            builder: (BuildContext context, int count, Widget? child) => Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('Просмотрено: $count'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // read — получить модель БЕЗ подписки. В обработчиках событий
        // нужен именно он: подписка здесь не нужна и приведёт к ошибке
        onPressed: () => context.read<MovieListModel>().add(
          'Новый фильм ${DateTime.now().second}',
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Только просмотренные'),
            value: model.onlyWatched,
            onChanged: (bool v) => context.read<MovieListModel>().setFilter(v),
          ),
          const Divider(height: 1),
          Expanded(child: _body(context, model)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, MovieListModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.error != null) {
      return Center(child: Text(model.error!));
    }
    if (model.movies.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }
    return ListView.builder(
      itemCount: model.movies.length,
      itemBuilder: (BuildContext context, int index) {
        final Movie movie = model.movies[index];
        return CheckboxListTile(
          title: Text(movie.title),
          value: movie.watched,
          onChanged: (bool? v) =>
              context.read<MovieListModel>().toggleWatched(movie),
        );
      },
    );
  }
}
// @CONSUME_END@
