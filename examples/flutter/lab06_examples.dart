// ===========================================================================
//  Разбор примеров к лабораторной работе №6
//  Введение во Flutter: устройство приложения
// ===========================================================================
//
//  Скопируйте файл в lib/examples/ вашего проекта и запустите так:
//      flutter run -t lib/examples/lab06_examples.dart
//
//  Править свой main.dart не нужно: ключ -t указывает, какой файл считать
//  точкой входа.
// ===========================================================================

import 'package:flutter/material.dart';

// @MAIN@
// runApp присоединяет корневой виджет к дереву и запускает отрисовку.
// Стрелочная запись — обычная функция из одного выражения.
void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  // Конструктор помечен const: такой виджет создаётся один раз
  // и переиспользуется при перерисовке.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp — каркас всего приложения: тема, маршруты, локализация
    return MaterialApp(
      title: 'Примеры к ЛР №6',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
// @MAIN_END@

// @SCAFFOLD@
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold — «скелет» ОДНОГО экрана. Не путайте с MaterialApp:
    // MaterialApp один на приложение, Scaffold — на каждом экране свой.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя фильмотека'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'О программе',
            onPressed: () {},
          ),
        ],
      ),
      body: const MovieList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Добавить',
        child: const Icon(Icons.add),
      ),
      drawer: const Drawer(child: Center(child: Text('Боковое меню'))),
    );
  }
}
// @SCAFFOLD_END@

// @LIST@
class MovieList extends StatelessWidget {
  const MovieList({super.key});

  // Данные пока «зашиты» в виджет — на занятии 11 они придут из базы
  static const List<(String, String, int)> _movies = <(String, String, int)>[
    ('Интерстеллар', 'Нолан', 2014),
    ('Начало', 'Нолан', 2010),
    ('Дюна', 'Вильнёв', 2021),
  ];

  @override
  Widget build(BuildContext context) {
    // ListView.builder создаёт только видимые элементы, а не все сразу
    return ListView.builder(
      itemCount: _movies.length,
      itemBuilder: (BuildContext context, int index) {
        final (String title, String director, int year) = _movies[index];
        return ListTile(
          leading: const Icon(Icons.movie_outlined),
          title: Text(title),
          subtitle: Text('$director, $year'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // SnackBar — короткое сообщение внизу экрана
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Выбрано: $title')));
          },
        );
      },
    );
  }
}
// @LIST_END@

// @STATEFUL@
/// Виджет с изменяемым состоянием: счётчик просмотренного.
/// Состояние живёт не в самом виджете, а в отдельном объекте State.
class WatchedCounter extends StatefulWidget {
  const WatchedCounter({super.key});

  @override
  State<WatchedCounter> createState() => _WatchedCounterState();
}

class _WatchedCounterState extends State<WatchedCounter> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    // Вызывается ОДИН раз при вставке виджета в дерево.
    // Здесь — подписки, контроллеры, первая загрузка данных.
    debugPrint('initState: виджет создан');
  }

  @override
  void dispose() {
    // Вызывается при удалении из дерева. Здесь — освобождение ресурсов.
    debugPrint('dispose: виджет удалён');
    super.dispose();
  }

  void _increment() {
    // setState помечает виджет как требующий перестроения.
    // Без него поле изменится, а экран нет.
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build: перестроение, счётчик = $_count');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Просмотрено: $_count'),
        const SizedBox(width: 12),
        FilledButton(onPressed: _increment, child: const Text('+1')),
      ],
    );
  }
}
// @STATEFUL_END@
