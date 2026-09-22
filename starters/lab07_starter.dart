// ===========================================================================
//  ЗАГОТОВКА к лабораторной работе №7
//  Рендеринг и виджеты: карточка книги, темы, адаптивность
// ===========================================================================
//
//  Как работать:
//  1. Скопируйте файл в lib/starters/ своего проекта.
//  2. Запустите и убедитесь, что он открывается:
//         flutter run -t lib/starters/lab07_starter.dart
//     Сразу после запуска вместо карточек будут серые заглушки — это норма.
//  3. Заполняйте помеченные TODO по одному, нажимая «r» в терминале после
//     каждой правки. Заглушка исчезает, как только вы написали код.
//  4. Когда всё готово — перенесите классы в свой проект:
//         BookCard      → lib/widgets/book_card.dart
//         DetailScreen  → lib/screens/detail_screen.dart
//         AppTheme      → lib/theme/app_theme.dart
//
//  Заготовка компилируется как есть. Если появилась ошибка — она ваша,
//  и это хорошо: чините сразу, не накапливая.
// ===========================================================================

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
//  Временная модель. Замените на свой класс Book из лабораторной работы №3.
// ---------------------------------------------------------------------------
class Book {
  final String title;
  final String author;
  final int year;
  final int pages;
  final String? coverUrl;

  const Book({
    required this.title,
    required this.author,
    this.year = 0,
    this.pages = 0,
    this.coverUrl,
  });
}

const List<Book> demoBooks = <Book>[
  Book(title: 'Основы Dart', author: 'С. А. Чернышев', year: 2024, pages: 521),
  Book(title: 'Flutter на практике', author: 'Ф. Заметти', year: 2020, pages: 328),
  Book(title: 'Базы данных', author: 'В. П. Агальцов', year: 2021, pages: 349),
];

/// Заглушка: показывает, что здесь ещё не написан код.
/// Удаляйте её по мере выполнения заданий.
class NotDoneYet extends StatelessWidget {
  final String what;
  final double height;
  const NotDoneYet(this.what, {super.key, this.height = 80});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    ),
    alignment: Alignment.center,
    child: Text('TODO: $what'),
  );
}

// ===========================================================================
//  ЗАДАНИЕ 5. Темы приложения
// ===========================================================================
class AppTheme {
  static const Color _seed = Color(0xFF3F51B5);

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // TODO 5.1: настройте appBarTheme — цвет фона возьмите из scheme
      //           (например, scheme.primaryContainer) и центрируйте заголовок.
      //
      // TODO 5.2: настройте cardTheme — скругление 12 и elevation 1.
      //
      // TODO 5.3: настройте textTheme — задайте titleMedium пожирнее
      //           (FontWeight.w600) и bodySmall с межстрочным height 1.35.
      //
      // Проверка: переключите тему кнопкой в AppBar. Ни один цвет
      // в ваших виджетах не должен быть написан константой.
    );
  }
}

void main() => runApp(const StarterApp());

class StarterApp extends StatefulWidget {
  const StarterApp({super.key});

  @override
  State<StarterApp> createState() => _StarterAppState();
}

class _StarterAppState extends State<StarterApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mode,
      home: HomeScreen(
        onToggleTheme: () => setState(() {
          _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        }),
      ),
    );
  }
}

// ===========================================================================
//  ЗАДАНИЕ 6. Адаптивная вёрстка
// ===========================================================================
class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя библиотека'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Светлая / тёмная тема',
            onPressed: onToggleTheme,
          ),
        ],
      ),
      // TODO 6.1: оберните тело в SafeArea.
      //
      // TODO 6.2: добавьте LayoutBuilder. Если constraints.maxWidth >= 700,
      //           покажите Row: слева SizedBox шириной 320 со списком,
      //           справа Expanded с карточкой выбранной книги.
      //           Иначе — только список.
      //           Проверьте поворотом экрана (Cmd+стрелка в симуляторе).
      body: ListView.builder(
        itemCount: demoBooks.length,
        itemBuilder: (BuildContext context, int index) =>
            BookCard(book: demoBooks[index]),
      ),
    );
  }
}

// ===========================================================================
//  ЗАДАНИЕ 2. Карточка книги
// ===========================================================================
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Пока ничего не написано — показываем заглушку.
    // Удалите эту строку, когда начнёте задание.
    return NotDoneYet('карточка книги «${book.title}»');

    // Устройство карточки (см. задание 2):
    //
    // TODO 2.1: корень — Card, внутри InkWell с onTap и скруглением 12.
    //
    // TODO 2.2: внутри InkWell — Padding(12), в нём Row с
    //           crossAxisAlignment: CrossAxisAlignment.start.
    //
    // TODO 2.3: слева обложка: ClipRRect(скругление 6) вокруг
    //           SizedBox(width: 56, height: 84). Если book.coverUrl == null,
    //           покажите Container цвета surfaceContainerHighest
    //           со значком Icons.menu_book; иначе Image.network.
    //
    // TODO 2.4: справа Expanded с Column:
    //           — название стилем titleMedium, maxLines: 2,
    //             overflow: TextOverflow.ellipsis;
    //           — автор стилем bodySmall;
    //           — Wrap с метками Chip: год и состояние прочтения.
    //
    // Все цвета и размеры шрифта берите из Theme.of(context) —
    // прямое указание Colors.white в этой работе не допускается.
  }
}

// ===========================================================================
//  ЗАДАНИЕ 3. Экран деталей книги
// ===========================================================================
class DetailScreen extends StatelessWidget {
  final Book book;
  const DetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title, overflow: TextOverflow.ellipsis)),
      body: ListView(
        children: <Widget>[
          // TODO 3.1: Stack — обложка на всю ширину, поверх неё
          //           Positioned(right: 8, top: 8) с полупрозрачной
          //           меткой года.
          const NotDoneYet('обложка со Stack и Positioned', height: 160),

          // TODO 3.2: название, автор, метки жанров.

          // TODO 3.3: Row с четырьмя характеристиками
          //           (объём, время чтения, состояние, оценка)
          //           и MainAxisAlignment.spaceEvenly.
          const NotDoneYet('строка характеристик', height: 60),

          // TODO 3.4: описание — несколько строк текста-заглушки.

          // TODO 3.5: внизу две кнопки: FilledButton «Отметить прочитанной»
          //           и OutlinedButton «Редактировать».
          const NotDoneYet('кнопки действий', height: 60),
        ],
      ),
    );
  }
}

// ===========================================================================
//  ЗАДАНИЕ 4 (дополнительно). Эксперименты с ограничениями
// ===========================================================================
//
//  Задание выполняется прямо здесь: раскомментируйте по одному примеру,
//  запустите, прочитайте текст ошибки, затем устраните её.
//
//  Пример А. Column внутри Column без Expanded.
//  Пример Б. ListView внутри Column — устраните ДВУМЯ способами
//            (Expanded и shrinkWrap: true) и объясните разницу.
//  Пример В. Длинное название в узком Row — устраните ТРЕМЯ способами
//            (Expanded, Flexible, FittedBox).
//
//  Снимок каждой ошибки приложите к отчёту: вы увидите их ещё не раз.
// ===========================================================================
