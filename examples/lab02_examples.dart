// ===========================================================================
//  Разбор примеров к лабораторной работе №2
//  Управление потоком выполнения и функции
// ===========================================================================
//
//  Предметная область — фильмы, а не книги: скопировать в работу не выйдет,
//  нужно понять приём и переложить на свою задачу.
//
//      dart run examples/lab02_examples.dart
// ===========================================================================

void main() {
  demoIf();
  demoSwitch();
  demoLoops();
  demoBreakContinue();
  demoIterable();
  demoParams();
  demoClosures();
}

// ---------------------------------------------------------------------------
// 1. УСЛОВНЫЕ КОНСТРУКЦИИ
// ---------------------------------------------------------------------------
// @IF@
void demoIf() {
  print('\n=== 1. if / else ===\n');

  const int rating = 78;

  if (rating >= 90) {
    print('Шедевр');
  } else if (rating >= 70) {
    print('Хороший фильм');
  } else if (rating >= 50) {
    print('На один раз');
  } else {
    print('Мимо');
  }

  // Условие обязано быть bool. Запись if (rating) — ошибка компиляции:
  // приведения числа к логическому типу в Dart нет.
  final bool worthWatching = rating >= 70;
  print('Стоит смотреть: $worthWatching');
}
// @IF_END@

// ---------------------------------------------------------------------------
// 2. SWITCH: ИНСТРУКЦИЯ И ВЫРАЖЕНИЕ
// ---------------------------------------------------------------------------
// @SWITCH@
void demoSwitch() {
  print('\n=== 2. switch ===\n');

  const String genre = 'фантастика';

  // Инструкция: ветви объединяются, «проваливание» запрещено языком
  switch (genre) {
    case 'фантастика':
    case 'фэнтези':
      print('Жанровое кино');
    case 'документальный':
      print('Неигровое кино');
    default:
      print('Жанр не определён');
  }

  // Выражение (Dart 3): короче, возвращает значение, break не нужен
  final String shelf = switch (genre) {
    'фантастика' || 'фэнтези' => 'Полка A',
    'документальный' => 'Полка B',
    _ => 'Полка C', // _ — все остальные значения
  };
  print('Полка: $shelf');

  // Образцы умеют сравнивать диапазоны
  const int minutes = 169;
  final String length = switch (minutes) {
    < 0 => 'ошибка',
    < 90 => 'короткий',
    < 150 => 'обычный',
    _ => 'длинный',
  };
  print('Длина: $length');
}
// @SWITCH_END@

// ---------------------------------------------------------------------------
// 3. ЦИКЛЫ
// ---------------------------------------------------------------------------
// @LOOPS@
void demoLoops() {
  print('\n=== 3. Циклы ===\n');

  // Цикл со счётчиком
  for (int i = 1; i <= 3; i++) {
    print('Часть $i');
  }

  // Перебор коллекции — предпочтительная форма
  const List<String> movies = <String>['Начало', 'Престиж', 'Довод'];
  for (final String movie in movies) {
    print('Фильм: $movie');
  }

  // while проверяет условие ДО тела: может не выполниться ни разу
  int countdown = 3;
  while (countdown > 0) {
    print('Осталось: $countdown');
    countdown--;
  }

  // do-while проверяет ПОСЛЕ: выполняется минимум один раз.
  // Именно поэтому он удобен для повторного ввода данных.
  int attempts = 0;
  do {
    attempts++;
  } while (attempts < 1);
  print('Тело do-while выполнилось $attempts раз');
}
// @LOOPS_END@

// ---------------------------------------------------------------------------
// 4. BREAK, CONTINUE И МЕТКИ
// ---------------------------------------------------------------------------
// @BREAK@
void demoBreakContinue() {
  print('\n=== 4. break и continue ===\n');

  const List<List<String>> shelves = <List<String>>[
    <String>['Начало', ''],
    <String>['Престиж', 'Довод'],
  ];

  // Метка позволяет выйти сразу из обоих циклов
  outer:
  for (final List<String> shelf in shelves) {
    for (final String movie in shelf) {
      if (movie.isEmpty) {
        continue; // пропускаем пустую запись, идём к следующей
      }
      print('Проверяем: $movie');
      if (movie == 'Престиж') {
        print('Нашли, выходим из обоих циклов');
        break outer;
      }
    }
  }
}
// @BREAK_END@

// ---------------------------------------------------------------------------
// 5. МЕТОДЫ ITERABLE
// ---------------------------------------------------------------------------
// @ITERABLE@
void demoIterable() {
  print('\n=== 5. Методы Iterable ===\n');

  const List<String> movies = <String>[
    'Интерстеллар',
    'Начало',
    'Престиж',
    'Довод',
  ];

  // where — отбор по условию, map — преобразование каждого элемента.
  // Оба ленивы: функция выполнится при переборе или вызове toList().
  final Iterable<String> long = movies.where((String m) => m.length > 6);
  final Iterable<String> upper = movies.map((String m) => m.toUpperCase());
  print('Длинные названия: ${long.toList()}');
  print('В верхнем регистре: ${upper.first}');

  // fold — свёртка последовательности в одно значение
  final int letters = movies.fold<int>(
    0,
    (int sum, String m) => sum + m.length,
  );
  print('Всего букв в названиях: $letters');

  // any — есть ли хотя бы один, every — все ли удовлетворяют
  print('Есть на «Д»: ${movies.any((String m) => m.startsWith('Д'))}');
  print('Все непустые: ${movies.every((String m) => m.isNotEmpty)}');

  // sort меняет список НА МЕСТЕ, поэтому сортируем копию
  final List<String> sorted = <String>[...movies]..sort();
  print('По алфавиту: $sorted');
  print('Исходный не тронут: $movies');
}
// @ITERABLE_END@

// ---------------------------------------------------------------------------
// 6. ФУНКЦИИ И ВИДЫ ПАРАМЕТРОВ
// ---------------------------------------------------------------------------
// @PARAMS@
/// Обязательный позиционный, обязательный именованный,
/// именованный со значением по умолчанию и необязательный именованный.
String describe(
  String title, {
  required String director,
  int year = 0,
  double? rating,
}) {
  final String y = year == 0 ? '' : ', $year';
  final String r = rating == null ? '' : ', оценка $rating';
  return '«$title» — $director$y$r';
}

void demoParams() {
  print('\n=== 6. Параметры функций ===\n');

  print(describe('Интерстеллар', director: 'Нолан', year: 2014));
  print(describe('Престиж', director: 'Нолан', rating: 8.5));

  // Порядок именованных аргументов произволен — это их главное удобство
  print(describe('Довод', year: 2020, director: 'Нолан'));
}
// @PARAMS_END@

// ---------------------------------------------------------------------------
// 7. АНОНИМНЫЕ ФУНКЦИИ И ЗАМЫКАНИЯ
// ---------------------------------------------------------------------------
// @CLOSURE@
/// Псевдоним функционального типа — делает сигнатуру читаемой.
typedef MoviePredicate = bool Function(String title);

List<String> filter(List<String> movies, MoviePredicate test) {
  final List<String> result = <String>[];
  for (final String movie in movies) {
    if (test(movie)) {
      result.add(movie);
    }
  }
  return result;
}

/// Возвращает замыкание: функцию, которая помнит свою переменную count.
int Function() makeCounter() {
  int count = 0;
  return () {
    count++;
    return count;
  };
}

void demoClosures() {
  print('\n=== 7. Функции как значения ===\n');

  const List<String> movies = <String>['Начало', 'Престиж', 'Интерстеллар'];

  // Функция передаётся в другую функцию как обычное значение
  print(filter(movies, (String m) => m.length > 7));

  final int Function() first = makeCounter();
  final int Function() second = makeCounter();
  print('первый счётчик: ${first()}, ${first()}');
  print('второй счётчик: ${second()}');
  print('счётчики независимы — у каждого своё окружение');
}

// @CLOSURE_END@
