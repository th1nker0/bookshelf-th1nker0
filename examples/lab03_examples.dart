// ===========================================================================
//  Разбор примеров к лабораторной работе №3
//  ООП в Dart: классы и объекты
// ===========================================================================
//
//  Предметная область — фильмы, а не книги: скопировать в работу не выйдет,
//  нужно понять приём и переложить на свою задачу.
//
//      dart run examples/lab03_examples.dart
// ===========================================================================

void main() {
  demoClass();
  demoConstructors();
  demoEncapsulation();
  demoInheritance();
  demoSpecialMethods();
  demoEnum();
  demoGeneric();
  demoInterfaceAndMixin();
}

// ---------------------------------------------------------------------------
// 1. КЛАСС: ПОЛЯ, КОНСТРУКТОР, МЕТОД, ГЕТТЕР
// ---------------------------------------------------------------------------
// @CLASS@
class Movie {
  // Поля: то, что объект ЗНАЕТ
  final String title;
  final String director;
  final int minutes;

  // Конструктор: this.поле сразу присваивает значение
  Movie({required this.title, required this.director, this.minutes = 0});

  // Метод: то, что объект УМЕЕТ. Вызывается со скобками.
  String describe() => '«$title» — $director';

  // Геттер: вычисляемое свойство. Читается БЕЗ скобок.
  double get hours => minutes / 60;

  bool get isLong => minutes > 150;
}

void demoClass() {
  print('\n=== 1. Класс и объект ===\n');

  final Movie a = Movie(title: 'Интерстеллар', director: 'Нолан', minutes: 169);
  final Movie b = Movie(title: 'Престиж', director: 'Нолан', minutes: 130);

  print(a.describe()); // метод — со скобками
  print('Длительность: ${a.hours.toStringAsFixed(1)} ч'); // геттер — без
  print('Длинный: ${a.isLong}, ${b.isLong}');

  // Два объекта одного класса живут независимо
  print('Это разные объекты: ${identical(a, b)}');
}
// @CLASS_END@

// ---------------------------------------------------------------------------
// 2. ВИДЫ КОНСТРУКТОРОВ
// ---------------------------------------------------------------------------
// @CTOR@
class Poster {
  final String title;
  final int year;

  // Обычный
  Poster(this.title, this.year);

  // Именованный: другой способ создать объект
  Poster.unknown() : title = 'Без названия', year = 0;

  // Фабричный: НЕ обязан создавать новый объект.
  // Здесь он разбирает данные, пришедшие из файла или из сети.
  factory Poster.fromMap(Map<String, Object?> data) => Poster(
    data['title'] as String? ?? 'Без названия',
    (data['year'] as num?)?.toInt() ?? 0,
  );

  @override
  String toString() => '$title ($year)';
}

void demoConstructors() {
  print('\n=== 2. Конструкторы ===\n');

  print(Poster('Довод', 2020));
  print(Poster.unknown());

  // Данные «извне» — с пропущенным и неверным полем
  print(Poster.fromMap(<String, Object?>{'title': 'Дюна', 'year': 2021}));
  print(Poster.fromMap(<String, Object?>{'year': null}));
}
// @CTOR_END@

// ---------------------------------------------------------------------------
// 3. ИНКАПСУЛЯЦИЯ: ПРАВИЛО, КОТОРОЕ ВСЕГДА ВЕРНО
// ---------------------------------------------------------------------------
// @ENCAP@
class Collection {
  // Подчёркивание делает член видимым только внутри своего файла
  final List<String> _titles = <String>[];

  // Наружу отдаём список, который нельзя изменить
  List<String> get titles => List<String>.unmodifiable(_titles);
  int get count => _titles.length;

  // Единственная точка изменения — значит, правило «без повторов»
  // нарушить невозможно
  bool add(String title) {
    if (_titles.contains(title)) {
      return false;
    }
    _titles.add(title);
    return true;
  }
}

void demoEncapsulation() {
  print('\n=== 3. Инкапсуляция ===\n');

  final Collection collection = Collection();
  print('Добавлен «Довод»: ${collection.add('Довод')}');
  print('Добавлен повторно: ${collection.add('Довод')}');
  print('В коллекции: ${collection.count}');

  // collection.titles.add('Дюна'); // ошибка выполнения: список неизменяем
  print('Список только для чтения: ${collection.titles}');
}
// @ENCAP_END@

// ---------------------------------------------------------------------------
// 4. НАСЛЕДОВАНИЕ: ОБЩЕЕ ВЫНОСИМ НАВЕРХ
// ---------------------------------------------------------------------------
// @INHERIT@
// abstract — класс только для наследования, объект создать нельзя
abstract class LibraryItem {
  final String title;
  LibraryItem(this.title);

  // Без тела: каждый потомок обязан описать по-своему
  String describe();

  // Обычный метод достаётся всем потомкам бесплатно
  void printCard() => print('--- ${describe()} ---');
}

class Film extends LibraryItem {
  final int minutes;
  Film(super.title, this.minutes);

  @override
  String describe() => '«$title», $minutes мин';
}

class Series extends LibraryItem {
  final int seasons;
  Series(super.title, this.seasons);

  @override
  String describe() => '«$title», сезонов: $seasons';
}

void demoInheritance() {
  print('\n=== 4. Наследование и полиморфизм ===\n');

  final List<LibraryItem> items = <LibraryItem>[
    Film('Интерстеллар', 169),
    Series('Тьма', 3),
  ];

  // Один цикл — разное поведение. Какой describe() вызовется,
  // определяется во время работы по фактическому типу объекта.
  for (final LibraryItem item in items) {
    item.printCard();
  }
}
// @INHERIT_END@

// ---------------------------------------------------------------------------
// 5. СПЕЦИАЛЬНЫЕ МЕТОДЫ: toString, ==, hashCode, compareTo
// ---------------------------------------------------------------------------
// @SPECIAL@
class Ticket implements Comparable<Ticket> {
  final String movie;
  final int row;

  const Ticket(this.movie, this.row);

  // Используется при print() и интерполяции
  @override
  String toString() => 'Ticket($movie, ряд $row)';

  // Равенство по содержимому, а не по тождеству объектов
  @override
  bool operator ==(Object other) =>
      other is Ticket && other.movie == movie && other.row == row;

  // Обязателен вместе с == : иначе Set и Map будут работать неверно
  @override
  int get hashCode => Object.hash(movie, row);

  // Позволяет вызывать sort() без аргумента
  @override
  int compareTo(Ticket other) => row.compareTo(other.row);
}

void demoSpecialMethods() {
  print('\n=== 5. toString, ==, hashCode, compareTo ===\n');

  const Ticket first = Ticket('Довод', 5);
  const Ticket same = Ticket('Довод', 5);

  print(first); // работает благодаря toString
  print('Равны по содержимому: ${first == same}');
  print('Это один объект: ${identical(first, same)}');

  // Благодаря == и hashCode дубликат в множестве не появится
  final List<Ticket> both = <Ticket>[first, same];
  final Set<Ticket> unique = both.toSet();
  print('Было элементов: ${both.length}, в множестве: ${unique.length}');

  final List<Ticket> tickets = <Ticket>[
    const Ticket('Довод', 7),
    const Ticket('Довод', 2),
  ];
  tickets.sort(); // работает благодаря compareTo
  print('После сортировки: $tickets');
}
// @SPECIAL_END@

// ---------------------------------------------------------------------------
// 6. ПЕРЕЧИСЛЕНИЕ С ПОЛЯМИ И МЕТОДАМИ
// ---------------------------------------------------------------------------
// @ENUM@
enum WatchStatus {
  planned('Запланирован'),
  watching('Смотрю'),
  finished('Просмотрен'),
  dropped('Брошен');

  final String label;
  const WatchStatus(this.label);

  bool get isDone => this == WatchStatus.finished;

  // Разбор значения, пришедшего строкой из файла
  static WatchStatus fromName(String name) => values.firstWhere(
    (WatchStatus s) => s.name == name,
    orElse: () => planned,
  );
}

void demoEnum() {
  print('\n=== 6. Перечисление ===\n');

  for (final WatchStatus status in WatchStatus.values) {
    print('${status.name} → ${status.label}');
  }
  print('finished завершённый: ${WatchStatus.finished.isDone}');
  print('Разбор «watching»: ${WatchStatus.fromName('watching').label}');
  print('Разбор мусора: ${WatchStatus.fromName('абв').label}');
}
// @ENUM_END@

// ---------------------------------------------------------------------------
// 7. ОБОБЩЁННЫЙ КЛАСС
// ---------------------------------------------------------------------------
// @GENERIC@
// <T extends LibraryItem> — хранилище принимает только элементы библиотеки
class Repository<T extends LibraryItem> {
  final List<T> _items = <T>[];

  void add(T item) => _items.add(item);
  int get count => _items.length;

  T? findByTitle(String title) {
    for (final T item in _items) {
      if (item.title == title) {
        return item;
      }
    }
    return null;
  }
}

void demoGeneric() {
  print('\n=== 7. Обобщённый класс ===\n');

  final Repository<Film> films = Repository<Film>();
  films.add(Film('Довод', 150));
  films.add(Film('Дюна', 155));

  print('Фильмов: ${films.count}');
  print('Поиск «Дюна»: ${films.findByTitle('Дюна')?.describe()}');
  print('Поиск «Нет такого»: ${films.findByTitle('Нет такого')?.describe()}');
}
// @GENERIC_END@

// ---------------------------------------------------------------------------
// 8. ИНТЕРФЕЙСЫ И МИКСИНЫ (дополнительно)
// ---------------------------------------------------------------------------
// @MIXIN@
// Интерфейс — контракт: что класс обязан уметь
abstract interface class Searchable {
  bool matches(String query);
}

// Миксин — переиспользуемое поведение без наследования
mixin Rateable {
  double _sum = 0;
  int _votes = 0;

  double get rating => _votes == 0 ? 0 : _sum / _votes;

  void vote(double value) {
    _sum += value;
    _votes++;
  }
}

class Documentary extends LibraryItem with Rateable implements Searchable {
  final String topic;
  Documentary(super.title, this.topic);

  @override
  String describe() => '«$title» — $topic';

  @override
  bool matches(String query) =>
      title.toLowerCase().contains(query.toLowerCase()) ||
      topic.toLowerCase().contains(query.toLowerCase());
}

void demoInterfaceAndMixin() {
  print('\n=== 8. Интерфейсы и миксины ===\n');

  final Documentary doc = Documentary('Планета Земля', 'природа');
  doc.vote(5);
  doc.vote(4);

  print(doc.describe());
  print('Средняя оценка: ${doc.rating}');
  print('Ищем «природ»: ${doc.matches('природ')}');
  print('Ищем «космос»: ${doc.matches('космос')}');
}

// @MIXIN_END@
