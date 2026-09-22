// ===========================================================================
//  Разбор примеров к лабораторной работе №9
//  Списки, анимация и кастомное рисование
// ===========================================================================
//
//      flutter run -t lib/examples/lab09_examples.dart
// ===========================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const DemoScreen(),
  );
}

class Movie {
  final int id;
  final String title;
  final int year;
  const Movie(this.id, this.title, this.year);
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final List<Movie> _movies = <Movie>[
    const Movie(1, 'Интерстеллар', 2014),
    const Movie(2, 'Начало', 2010),
    const Movie(3, 'Престиж', 2006),
    const Movie(4, 'Дюна', 2021),
    const Movie(5, 'Довод', 2020),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Списки, анимация, рисование')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          _title(context, '1. Список с ключами и свайпом'),
          SizedBox(
            height: 230,
            child: DismissibleList(
              movies: _movies,
              onRemove: (Movie m) => setState(() => _movies.remove(m)),
            ),
          ),
          const SizedBox(height: 16),
          _title(context, '2. Неявная анимация'),
          const ImplicitDemo(),
          const SizedBox(height: 16),
          _title(context, '3. Явная анимация'),
          const ExplicitDemo(),
          const SizedBox(height: 16),
          _title(context, '4. Кольцевая диаграмма'),
          SizedBox(height: 200, child: DonutDemo(count: _movies.length)),
        ],
      ),
    );
  }

  Widget _title(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

// @DISMISS@
class DismissibleList extends StatelessWidget {
  final List<Movie> movies;
  final ValueChanged<Movie> onRemove;

  const DismissibleList({
    super.key,
    required this.movies,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: movies.length,
      // itemExtent подсказывает высоту элемента: список не вычисляет её
      // заново при каждой прокрутке
      itemExtent: 64,
      itemBuilder: (BuildContext context, int index) {
        final Movie movie = movies[index];
        return Dismissible(
          // Ключ ОБЯЗАТЕЛЕН и должен быть устойчивым идентификатором.
          // ValueKey(index) не годится: при удалении индексы сдвигаются.
          key: ValueKey<int>(movie.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: scheme.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
          ),
          confirmDismiss: (DismissDirection d) async {
            final bool? ok = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Удалить «${movie.title}»?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Удалить'),
                  ),
                ],
              ),
            );
            return ok ?? false;
          },
          onDismissed: (DismissDirection d) => onRemove(movie),
          child: ListTile(
            leading: const Icon(Icons.movie_outlined),
            title: Text(movie.title),
            subtitle: Text('${movie.year}'),
          ),
        );
      },
    );
  }
}
// @DISMISS_END@

// @IMPLICIT@
class ImplicitDemo extends StatefulWidget {
  const ImplicitDemo({super.key});

  @override
  State<ImplicitDemo> createState() => _ImplicitDemoState();
}

class _ImplicitDemoState extends State<ImplicitDemo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    // Никакого контроллера: достаточно менять свойства и указать
    // длительность. Промежуточные кадры Flutter построит сам.
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: _expanded ? 160 : 72,
            height: 72,
            decoration: BoxDecoration(
              color: _expanded
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(_expanded ? 20 : 8),
            ),
            alignment: Alignment.center,
            child: const Text('нажмите'),
          ),
          const SizedBox(width: 12),
          AnimatedOpacity(
            opacity: _expanded ? 1 : 0.3,
            duration: const Duration(milliseconds: 350),
            child: const Text('AnimatedOpacity'),
          ),
        ],
      ),
    );
  }
}
// @IMPLICIT_END@

// @EXPLICIT@
class ExplicitDemo extends StatefulWidget {
  const ExplicitDemo({super.key});

  @override
  State<ExplicitDemo> createState() => _ExplicitDemoState();
}

// SingleTickerProviderStateMixin — источник «тиков» кадров для ОДНОГО
// контроллера. Для нескольких берут TickerProviderStateMixin.
class _ExplicitDemoState extends State<ExplicitDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: 1.6,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

  @override
  void dispose() {
    // Обязательно: иначе Ticker продолжит работу и возникнет утечка
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: () => _controller.forward(from: 0),
          icon: AnimatedBuilder(
            animation: _scale,
            // child создаётся ОДИН раз и передаётся готовым:
            // при каждом кадре он не пересоздаётся
            child: const Icon(Icons.star, color: Colors.amber, size: 32),
            builder: (BuildContext context, Widget? child) =>
                Transform.scale(scale: _scale.value, child: child),
          ),
        ),
        const Text('нажмите на звезду'),
      ],
    );
  }
}
// @EXPLICIT_END@

// @PAINTER@
class DonutPainter extends CustomPainter {
  final Map<String, int> data;
  final Map<String, Color> colors;
  final double progress; // 0..1 — для анимации появления

  DonutPainter({required this.data, required this.colors, this.progress = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final int total = data.values.fold<int>(0, (int a, int b) => a + b);
    if (total == 0) {
      return;
    }

    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 - 16;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;

    // Отсчёт углов начинаем сверху: -pi/2
    double start = -math.pi / 2;
    data.forEach((String key, int value) {
      final double sweep = 2 * math.pi * value / total * progress;
      paint.color = colors[key] ?? Colors.grey;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    });

    // Текст на холст выводят через TextPainter
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: '$total\nвсего',
        style: const TextStyle(
          fontSize: 18,
          height: 1.2,
          color: Colors.black87,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  // Честный ответ обязателен: всегда true — перерисовка каждый кадр,
  // всегда false — картинка не обновится при смене данных
  @override
  bool shouldRepaint(DonutPainter old) =>
      old.data != data || old.progress != progress;
}
// @PAINTER_END@

// @DONUT@
class DonutDemo extends StatefulWidget {
  final int count;
  const DonutDemo({super.key, required this.count});

  @override
  State<DonutDemo> createState() => _DonutDemoState();
}

class _DonutDemoState extends State<DonutDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Map<String, int> data = <String, int>{
      'Просмотрено': widget.count,
      'В планах': 3,
      'Брошено': 1,
    };

    // RepaintBoundary изолирует перерисовку: анимация диаграммы
    // не заставляет перерисовывать остальной экран
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) => CustomPaint(
          painter: DonutPainter(
            data: data,
            colors: <String, Color>{
              'Просмотрено': scheme.primary,
              'В планах': scheme.tertiary,
              'Брошено': scheme.error,
            },
            progress: Curves.easeOutCubic.transform(_controller.value),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
// @DONUT_END@
