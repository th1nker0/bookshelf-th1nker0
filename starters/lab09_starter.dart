// ===========================================================================
//  ЗАГОТОВКА к лабораторной работе №9
//  Списки, анимация и кастомное рисование
// ===========================================================================
//
//      flutter run -t lib/starters/lab09_starter.dart
//
//  Заготовка запускается сразу: вместо невыполненных частей — заглушки.
//  Заполняйте TODO по одному и нажимайте «r» после каждой правки.
//
//  Готовое переносится так:
//      BookList           → lib/screens/home_screen.dart
//      ReadingDonutPainter → lib/widgets/reading_donut.dart
// ===========================================================================

import 'package:flutter/material.dart';

// Временная модель — замените на свой класс Book из ЛР №3.
// Обратите внимание на поле id: без устойчивого идентификатора
// не получится задать ключи в задании 2.
class Book {
  final int id;
  final String title;
  final String author;
  final bool isRead;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.isRead = false,
  });
}

/// Генератор большого каталога для задания 1.
List<Book> generateBooks(int count) => List<Book>.generate(
  count,
  (int i) => Book(
    id: i + 1,
    title: 'Книга ${i + 1}',
    author: 'Автор ${(i % 20) + 1}',
    isRead: i % 3 == 0,
  ),
);

class NotDoneYet extends StatelessWidget {
  final String what;
  final double height;
  const NotDoneYet(this.what, {super.key, this.height = 80});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    alignment: Alignment.center,
    child: Text('TODO: $what'),
  );
}

void main() => runApp(const StarterApp());

class StarterApp extends StatelessWidget {
  const StarterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Задание 1 требует 5000 книг. Начните с 20, чтобы было видно,
  // что происходит, и увеличьте, когда список заработает.
  final List<Book> _books = generateBooks(20);

  void _remove(Book book) => setState(() => _books.remove(book));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Списки и анимация'),
        actions: <Widget>[
          // TODO 4 (дополнительно): переключатель «список / плитка».
          //         В режиме плитки используйте GridView.builder
          //         с SliverGridDelegateWithMaxCrossAxisExtent.
          IconButton(icon: const Icon(Icons.grid_view), onPressed: () {}),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 180, child: StatsDonut(books: _books)),
          const Divider(height: 1),
          Expanded(child: BookList(books: _books, onRemove: _remove)),
        ],
      ),
    );
  }
}

// ===========================================================================
//  ЗАДАНИЯ 1–3. Список: ленивое построение, ключи, удаление жестом
// ===========================================================================
class BookList extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onRemove;

  const BookList({super.key, required this.books, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    // TODO 1.1: замените ListView на ListView.builder.
    //           Сравните время открытия экрана на 5000 книг до и после —
    //           числа нужны в отчёте.
    //
    // TODO 1.2: добавьте itemExtent: 72 и оцените плавность прокрутки.
    //
    // TODO 2.1: задайте каждому элементу key: ValueKey<int>(book.id).
    //           НЕ индекс: при удалении индексы сдвигаются.
    //
    // TODO 3.1: оберните элемент в Dismissible с
    //           direction: DismissDirection.endToStart.
    //
    // TODO 3.2: background — Container цвета errorContainer,
    //           выравнивание centerRight, значок Icons.delete_outline.
    //
    // TODO 3.3: confirmDismiss — покажите AlertDialog с подтверждением
    //           и верните результат (помните: коснулись мимо → null).
    //
    // TODO 3.4: onDismissed — вызовите onRemove(book) и покажите SnackBar
    //           с кнопкой «Отменить», возвращающей книгу на место.
    return ListView(
      children: books
          .map(
            (Book book) => ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(book.title),
              subtitle: Text(book.author),
            ),
          )
          .toList(),
    );
  }
}

// ===========================================================================
//  ЗАДАНИЕ 5. Анимации
// ===========================================================================
//
//  TODO 5.1 (неявная): оберните обложку в AnimatedContainer — при касании
//           карточка плавно увеличивается и меняет цвет фона.
//
//  TODO 5.2 (неявная): AnimatedOpacity — прочитанные книги показывайте
//           с прозрачностью 0.6.
//
//  TODO 5.3 (неявная): AnimatedSwitcher — плавная замена индикатора
//           загрузки списком книг.
//
//  TODO 5.4 (Hero): обложка «перелетает» на экран деталей.
//           Метка tag: 'cover_${book.id}' — одинаковая на обоих экранах.
//
//  TODO 5.5 (явная, дополнительно): AnimationController + Tween +
//           CurvedAnimation(curve: Curves.elasticOut) — «пульсация»
//           звезды при выставлении оценки.
//           Не забудьте SingleTickerProviderStateMixin и dispose().
// ===========================================================================

// ===========================================================================
//  ЗАДАНИЕ 6. Кольцевая диаграмма
// ===========================================================================
class StatsDonut extends StatelessWidget {
  final List<Book> books;
  const StatsDonut({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    // Удалите заглушку, когда напишете художника.
    return const NotDoneYet('кольцевая диаграмма', height: 160);

    // TODO 6.1: соберите данные — сколько книг прочитано, сколько нет.
    // TODO 6.2: верните CustomPaint(painter: ReadingDonutPainter(...),
    //           child: const SizedBox.expand()).
    // TODO 6.3 (дополнительно): оберните в AnimatedBuilder с
    //           AnimationController, чтобы диаграмма появлялась за 900 мс.
  }
}

class ReadingDonutPainter extends CustomPainter {
  final Map<String, int> data;
  final Map<String, Color> colors;
  final double progress;

  ReadingDonutPainter({
    required this.data,
    required this.colors,
    this.progress = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO 6.4: посчитайте сумму значений; если она равна нулю — выйдите.
    //
    // TODO 6.5: вычислите центр (size.center(Offset.zero)) и радиус
    //           (size.shortestSide / 2 - 16), постройте
    //           Rect.fromCircle(center: ..., radius: ...).
    //
    // TODO 6.6: создайте Paint со style: PaintingStyle.stroke
    //           и strokeWidth: 22.
    //
    // TODO 6.7: обойдите data и для каждой доли вызовите canvas.drawArc.
    //           ВАЖНО: начинайте с угла -math.pi / 2, иначе диаграмма
    //           окажется повёрнутой на четверть оборота: нулевой угол
    //           в drawArc — это «три часа», а не «двенадцать».
    //           Размах: 2 * math.pi * value / total * progress.
    //
    // TODO 6.8 (дополнительно): выведите в центре общее число книг
    //           через TextPainter — другого способа писать текст
    //           на холсте нет.
    //
    // Подсказка: math.pi живёт в dart:math — допишите вверху файла
    //           import 'dart:math' as math;
  }

  @override
  bool shouldRepaint(ReadingDonutPainter oldDelegate) {
    // TODO 6.9: верните честный ответ — сравните data и progress.
    //           Всегда true → перерисовка каждый кадр.
    //           Всегда false → диаграмма не обновится при смене данных.
    return true;
  }
}
