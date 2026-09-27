import 'dart:io';

void main(List<String> arguments) {
  //Задание 1.
  print('Проект: BookShelf');
  print('Версия Dart: ${Platform.version}');
  print('Версия Операционной системы: ${Platform.operatingSystem}');
  print('');

  //Задание 2.
  stdout.write('Название: ');
  final String title = stdin.readLineSync() ?? '';

  stdout.write('Автор: ');
  final String author = stdin.readLineSync() ?? 'неизвестен';

  stdout.write('Год издания: ');
  final int year = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

  stdout.write('Количество страниц: ');
  final int pages = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

  stdout.write('Оценка(0-5): ');
  final double rating = double.tryParse(stdin.readLineSync() ?? '') ?? 0.0;

  stdout.write('Прочитана?:');
  final String readR = (stdin.readLineSync() ?? '').trim().toLowerCase();
  final bool isRead = readR == 'да';

  //Задание 3.
  final String category = pages < 150
      ? 'брошюра'
      : pages < 400
      ? 'книга'
      : 'том';
  final double hours = pages / 50.0;
  final int currentYear = DateTime.now().year;
  final int age = currentYear - year;

  final String initials = author
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}.')
      .join(' ');
  print('');
  print('=' * 44);
  print('«$title»');
  print('Авторы: $author');
  print('Инициалы: $initials');
  print('Год: $year (возраст: $age лет)');
  print('Страниц: $pages ($category)');
  print('Время чтения: ~${hours.toStringAsFixed(1)} ч');
  print('Оценка: ${rating.toStringAsFixed(1)}/5');
  print('Прочитана: ${isRead ? "да" : "нет"}');
  print('=' * 44);

  //Задание 4.
  final List<String> shelf = <String>[
    'Норвежский лес',
    'Кафка на пляже',
    'Охота на овец',
    'Хроники Заводной Птицы',
    '1Q84',
  ];
  print('\nПолка Мураками: $shelf');
  print('Длина: ${shelf.length}');
  print('Первая: ${shelf.first}');
  print('Последняя: ${shelf.last}');

  shelf.insert(0, 'Слушай песню ветра'); // в начало
  shelf.add('Мужчины без женщин'); //в конец
  shelf.remove('Охота на овец'); // удаление по значению
  print('После изменений: $shelf');

  stdout.write('\nЖанры через запятую: ');
  final String genresRaw = stdin.readLineSync() ?? '';
  final Set<String> genres = genresRaw
      .split(',')
      .map((g) => g.trim())
      .where((g) => g.isNotEmpty)
      .toSet();
  genres.add('магический реализм');
  genres.add('магический реализм'); //дубликат не добавится
  print('Жанры: $genres(уникальных: ${genres.length})');

  final Map<String, int> pagesByBook = <String, int>{
    'Норвежский лес': 416,
    'Кафка на пляже': 656,
    'Охота на овец': 384,
    'Хроника Заводной Птицы': 832,
    '1Q84': 1152,
  };

  pagesByBook.forEach((book, p) => print('$book - $p стр.'));

  String maxBook = '';
  int maxPages = 0;
  int total = 0;
  pagesByBook.forEach((book, p) {
    total += p;
    if (p > maxPages) {
      maxPages = p;
      maxBook = book;
    }
  });
  print('Самая толстая: $maxBook ($maxPages стр.)');
  print(
    'Всего: $total, в среднем:'
    '${(total / pagesByBook.length).toStringAsFixed(1)}',
  );

  final bool includeExtra = true;
  final List<String> all = <String>[
    'стартовая полка',
    ...shelf,
    if (includeExtra) 'бонусная книга',
    for (final g in genres) 'жанр: $g',
  ];
  print('all: $all');

  //Задание 5.
  print('\n   Операторы   ');
  print('7 / 2=${7 / 2}');
  print('7 ~/ 2=${7 ~/ 2}');
  print('7 % 2 = ${7 % 2}');

  bool sideEffect() {
    print(' sideEffect вызван ');
    return true;
  }

  print(false && sideEffect());
  print(true || sideEffect());
  print(true && sideEffect());

  String? maybeNull;
  print(maybeNull?.length);
  print(maybeNull ?? 'по умолчанию');
  maybeNull ??= 'заполнено';
  print(maybeNull);

  final List<int> finalList = [1, 2, 3];
  finalList.add(4);
  print('finalList: $finalList');

  const List<int> constList = [1, 2, 3];
  print('constList: $constList');

  final StringBuffer sb = StringBuffer()
    ..write('Book')
    ..write('Shelf')
    ..write('-')
    ..write('каталог книг');
  print(sb.toString());
}
