// ===========================================================================
//  Разбор примеров к лабораторной работе №4
//  Работа с текстовыми файлами
// ===========================================================================
//
//  Предметная область — фильмы, а не книги.
//
//      dart run examples/lab04_examples.dart
//
//  Файл ничего не портит: все операции идут во временном каталоге,
//  который удаляется в конце.
// ===========================================================================

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  // Временный каталог — чтобы примеры не мусорили в репозитории
  final Directory work = await Directory.systemTemp.createTemp('lab04_');
  try {
    await demoWriteRead(work);
    await demoStream(work);
    await demoDirectory(work);
    demoJson();
    demoModel();
    await demoExceptions(work);
  } finally {
    await work.delete(recursive: true);
    print('\nВременный каталог удалён.');
  }
}

// ---------------------------------------------------------------------------
// 1. ЗАПИСЬ И ЧТЕНИЕ ФАЙЛА
// ---------------------------------------------------------------------------
// @FILE@
Future<void> demoWriteRead(Directory work) async {
  print('\n=== 1. Запись и чтение ===\n');

  final File file = File('${work.path}/movies.txt');

  // Запись: перезаписывает файл целиком
  await file.writeAsString('Интерстеллар\nНачало\n');

  // Дозапись: добавляет в конец
  await file.writeAsString('Престиж\n', mode: FileMode.append);

  // Чтение целиком — когда файл заведомо помещается в память
  final String all = await file.readAsString();
  print('Содержимое:\n$all');

  // Чтение списком строк
  final List<String> lines = await file.readAsLines();
  print('Строк: ${lines.length}, первая: ${lines.first}');

  // Существует ли файл
  print('Файл есть: ${await file.exists()}');
  print('Размер: ${await file.length()} байт');
}
// @FILE_END@

// ---------------------------------------------------------------------------
// 2. ПОТОКОВОЕ ЧТЕНИЕ БОЛЬШОГО ФАЙЛА
// ---------------------------------------------------------------------------
// @STREAM@
Future<void> demoStream(Directory work) async {
  print('\n=== 2. Потоковое чтение ===\n');

  final File big = File('${work.path}/big.txt');
  final StringBuffer buffer = StringBuffer();
  for (int i = 1; i <= 5; i++) {
    buffer.writeln('Фильм $i');
  }
  await big.writeAsString(buffer.toString());

  // Файл не загружается в память целиком: строки приходят по одной.
  // Так читают журналы и выгрузки, которые могут весить гигабайты.
  int count = 0;
  final Stream<String> lines = big
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  await for (final String line in lines) {
    if (line.trim().isNotEmpty) {
      count++;
    }
  }
  print('Прочитано строк потоком: $count');
}
// @STREAM_END@

// ---------------------------------------------------------------------------
// 3. КАТАЛОГИ
// ---------------------------------------------------------------------------
// @DIR@
Future<void> demoDirectory(Directory work) async {
  print('\n=== 3. Каталоги ===\n');

  // recursive: true создаёт и промежуточные каталоги
  final Directory data = Directory('${work.path}/data/archive');
  await data.create(recursive: true);
  await File('${data.path}/a.json').writeAsString('{}');
  await File('${data.path}/b.txt').writeAsString('текст');

  // Обход каталога: list() возвращает поток записей
  await for (final FileSystemEntity entity in data.list()) {
    if (entity is File) {
      final String name = entity.path.split(Platform.pathSeparator).last;
      print('$name — ${await entity.length()} байт');
    }
  }

  // Разделитель пути различается: / в Unix, \ в Windows.
  // Поэтому его берут из Platform, а не пишут руками.
  print('Разделитель пути в этой системе: «${Platform.pathSeparator}»');
}
// @DIR_END@

// ---------------------------------------------------------------------------
// 4. JSON: КОДИРОВАНИЕ И ДЕКОДИРОВАНИЕ
// ---------------------------------------------------------------------------
// @JSON@
void demoJson() {
  print('\n=== 4. JSON ===\n');

  final Map<String, Object?> data = <String, Object?>{
    'version': 1,
    'movies': <Map<String, Object?>>[
      <String, Object?>{'title': 'Интерстеллар', 'year': 2014},
      <String, Object?>{'title': 'Довод', 'year': 2020},
    ],
  };

  // Объект Dart → строка JSON
  final String raw = jsonEncode(data);
  print('В одну строку: $raw');

  // С отступами — так пишут в файл, чтобы его можно было читать глазами
  const JsonEncoder pretty = JsonEncoder.withIndent('  ');
  print('С отступами:\n${pretty.convert(data)}');

  // Строка JSON → объект Dart.
  // Объект превращается в Map<String, dynamic>, массив — в List<dynamic>.
  final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
  final List<Map<String, dynamic>> movies = (decoded['movies'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  print('Первый фильм: ${movies.first['title']}');
}
// @JSON_END@

// ---------------------------------------------------------------------------
// 5. СЕРИАЛИЗАЦИЯ МОДЕЛИ: toJson И fromJson
// ---------------------------------------------------------------------------
// @MODEL@
class Movie {
  final String title;
  final int year;
  final double? rating;

  const Movie({required this.title, this.year = 0, this.rating});

  Map<String, Object?> toJson() => <String, Object?>{
    'title': title,
    'year': year,
    // Поле добавляется только если оно есть
    if (rating != null) 'rating': rating,
  };

  // Данные из файла и из сети — НЕДОВЕРЕННЫЕ. Каждое поле разбирается
  // так, чтобы выдержать пропуск, null и неверный тип.
  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
    title: json['title'] as String? ?? 'Без названия',
    year: (json['year'] as num?)?.toInt() ?? 0,
    rating: (json['rating'] as num?)?.toDouble(),
  );

  @override
  String toString() => '$title ($year)${rating == null ? '' : ', $rating'}';
}

void demoModel() {
  print('\n=== 5. Сериализация модели ===\n');

  const Movie movie = Movie(title: 'Дюна', year: 2021, rating: 8.1);
  print('В JSON: ${jsonEncode(movie.toJson())}');

  // Хороший случай
  print(Movie.fromJson(<String, dynamic>{'title': 'Довод', 'year': 2020}));

  // Год пришёл дробным — as int упал бы, а num?.toInt() выдержал
  print(Movie.fromJson(<String, dynamic>{'title': 'Тень', 'year': 2019.0}));

  // Полей нет вовсе
  print(Movie.fromJson(<String, dynamic>{}));
}
// @MODEL_END@

// ---------------------------------------------------------------------------
// 6. ОБРАБОТКА ИСКЛЮЧЕНИЙ
// ---------------------------------------------------------------------------
// @EXCEPT@
/// Собственное исключение — обычный класс, реализующий Exception.
class CatalogFormatException implements Exception {
  final String message;
  final int line;
  CatalogFormatException(this.message, this.line);

  @override
  String toString() => 'Ошибка в строке $line: $message';
}

Future<void> demoExceptions(Directory work) async {
  print('\n=== 6. Исключения ===\n');

  // Файла нет
  try {
    await File('${work.path}/нет-такого.json').readAsString();
  } on PathNotFoundException {
    print('Файл не найден — начинаем с пустого каталога');
  }

  // Файл есть, но внутри не JSON
  final File broken = File('${work.path}/broken.json');
  await broken.writeAsString('это совсем не json');
  try {
    jsonDecode(await broken.readAsString());
  } on FormatException catch (e) {
    print('Файл повреждён: ${e.message}');
  } finally {
    // finally выполняется всегда: и при ошибке, и без неё
    print('Попытка разбора завершена');
  }

  // Собственное исключение
  try {
    throw CatalogFormatException('ожидалось 3 поля, получено 2', 7);
  } on CatalogFormatException catch (e) {
    print('Перехвачено: $e');
  }
}
// @EXCEPT_END@
