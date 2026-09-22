// ===========================================================================
//  Разбор примеров к лабораторной работе №7
//  Рендеринг и виджеты: компоновка, темы, адаптивность
// ===========================================================================
//
//      flutter run -t lib/examples/lab07_examples.dart
//
//  Каждый раздел — отдельная карточка на экране. Меняйте значения,
//  сохраняйте файл и смотрите на горячую перезагрузку.
// ===========================================================================

import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

// @THEME@
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.light;

  // Обе темы строятся из ОДНОГО исходного цвета. Все оттенки —
  // фон, текст, границы — Flutter подбирает сам и согласованно.
  ThemeData _theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3F51B5),
      brightness: brightness,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _mode,
      home: DemoScreen(
        onToggleTheme: () => setState(() {
          _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        }),
      ),
    );
  }
}
// @THEME_END@

// @ADAPTIVE@
class DemoScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const DemoScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Виджеты и компоновка'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Светлая / тёмная тема',
            onPressed: onToggleTheme,
          ),
        ],
      ),
      // SafeArea отодвигает содержимое от выреза и системных панелей
      body: SafeArea(
        // LayoutBuilder даёт ограничения КОНКРЕТНОГО места в дереве,
        // а не размер всего экрана. Поэтому решение о компоновке
        // принимают по нему, а не по MediaQuery.
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 600;
            return ListView(
              padding: const EdgeInsets.all(12),
              children: <Widget>[
                Text(
                  wide
                      ? 'Широкий экран: ${constraints.maxWidth.round()} px'
                      : 'Узкий экран: ${constraints.maxWidth.round()} px',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const ContainerDemo(),
                const SizedBox(height: 12),
                const RowColumnDemo(),
                const SizedBox(height: 12),
                const StackDemo(),
                const SizedBox(height: 12),
                const ConstraintsDemo(),
              ],
            );
          },
        ),
      ),
    );
  }
}
// @ADAPTIVE_END@

// @CONTAINER@
class ContainerDemo extends StatelessWidget {
  const ContainerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Цвета берём из темы, а не константами: иначе в тёмной теме
    // получится белый текст на белом фоне.
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '1. Container и его замены',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: 140,
              height: 60,
              // margin — отступ СНАРУЖИ, padding — ВНУТРИ
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.primary),
              ),
              child: Text(
                'Container',
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ),
            const Text('Нужен только отступ — берите Padding.'),
            const Text('Только размер — SizedBox. Только центр — Center.'),
          ],
        ),
      ),
    );
  }
}
// @CONTAINER_END@

// @ROWCOLUMN@
class RowColumnDemo extends StatelessWidget {
  const RowColumnDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '2. Row, Column, Expanded',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Icon(Icons.movie_outlined),
                const SizedBox(width: 12),
                // Expanded забирает всё свободное место по главной оси.
                // Без него длинный текст вызовет переполнение.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Очень длинное название фильма, которое не помещается',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        'Нолан, 2014',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 12),
            // flex распределяет место пропорционально
            Row(
              children: <Widget>[
                Expanded(flex: 2, child: _bar(context, '2')),
                const SizedBox(width: 4),
                Expanded(child: _bar(context, '1')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(BuildContext context, String label) => Container(
    height: 32,
    alignment: Alignment.center,
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Text('flex: $label'),
  );
}
// @ROWCOLUMN_END@

// @STACK@
class StackDemo extends StatelessWidget {
  const StackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '3. Stack и Positioned',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Stack накладывает виджеты друг на друга.
            // Positioned задаёт положение относительно краёв.
            SizedBox(
              height: 90,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    color: scheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Text('обложка'),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      color: scheme.primary,
                      child: Text(
                        '2014',
                        style: TextStyle(color: scheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// @STACK_END@

// @CONSTRAINTS@
class ConstraintsDemo extends StatelessWidget {
  const ConstraintsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '4. Правило ограничений',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Родитель передаёт ограничения вниз.'),
            const Text('Ребёнок выбирает размер и сообщает наверх.'),
            const Text('Положение задаёт родитель.'),
            const SizedBox(height: 8),
            // Список внутри Column обязан получить конечную высоту:
            // либо Expanded, либо shrinkWrap с ограничением по высоте.
            SizedBox(
              height: 90,
              child: ListView(
                shrinkWrap: true,
                children: const <Widget>[
                  ListTile(dense: true, title: Text('Вложенный список 1')),
                  ListTile(dense: true, title: Text('Вложенный список 2')),
                  ListTile(dense: true, title: Text('Вложенный список 3')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// @CONSTRAINTS_END@
