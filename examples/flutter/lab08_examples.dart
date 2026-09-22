// ===========================================================================
//  Разбор примеров к лабораторной работе №8
//  Навигация и передача данных
// ===========================================================================
//
//      flutter run -t lib/examples/lab08_examples.dart
// ===========================================================================

import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

// @ROUTES@
/// Все маршруты собраны в одном месте. Имена — константы, чтобы
/// опечатку поймал компилятор, а не пользователь.
abstract final class Routes {
  static const String home = '/';
  static const String detail = '/movie';
  static const String edit = '/movie/edit';

  static Route<Object?>? generate(RouteSettings settings) {
    switch (settings.name) {
      case detail:
        // Аргумент приходит как Object? — приводим к нужному типу
        final Movie movie = settings.arguments! as Movie;
        return MaterialPageRoute<String>(
          builder: (BuildContext context) => DetailScreen(movie: movie),
        );
      case edit:
        return MaterialPageRoute<Movie>(
          builder: (BuildContext context) =>
              EditScreen(movie: settings.arguments as Movie?),
          // fullscreenDialog меняет анимацию и рисует крестик вместо стрелки
          fullscreenDialog: true,
        );
      default:
        return null;
    }
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: Routes.home,
      routes: <String, WidgetBuilder>{
        Routes.home: (BuildContext context) => const MainScreen(),
      },
      // Маршруты с параметрами статической таблицей не описать
      onGenerateRoute: Routes.generate,
      onUnknownRoute: (RouteSettings settings) => MaterialPageRoute<void>(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(title: const Text('Маршрут не найден')),
          body: Center(child: Text('Нет маршрута ${settings.name}')),
        ),
      ),
    );
  }
}
// @ROUTES_END@

class Movie {
  final String title;
  final String director;
  final int year;
  const Movie(this.title, this.director, this.year);
}

// @BOTTOM@
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  // IndexedStack держит ВСЕ вкладки в дереве и показывает одну.
  // Благодаря этому позиция прокрутки и введённый текст не теряются
  // при переключении. Запись _screens[_index] их бы потеряла.
  static const List<Widget> _screens = <Widget>[
    LibraryTab(),
    SearchTab(),
    StatsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Фильмотека')),
      drawer: const AppDrawer(),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Фильмы',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Поиск'),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Статистика',
          ),
        ],
      ),
    );
  }
}
// @BOTTOM_END@

// @DRAWER@
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text('Фильмотека', style: TextStyle(fontSize: 22)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Импорт и экспорт'),
            onTap: () {
              // Сначала закрываем меню, потом переходим — иначе оно
              // останется открытым под новым экраном
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Здесь был бы импорт')),
              );
            },
          ),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'Примеры к ЛР №8',
          ),
        ],
      ),
    );
  }
}
// @DRAWER_END@

// @TABS@
class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  static const List<Movie> _movies = <Movie>[
    Movie('Интерстеллар', 'Нолан', 2014),
    Movie('Начало', 'Нолан', 2010),
    Movie('Дюна', 'Вильнёв', 2021),
  ];

  @override
  Widget build(BuildContext context) {
    // DefaultTabController раздаёт состояние вкладок вниз по дереву
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          const TabBar(
            tabs: <Widget>[
              Tab(text: 'Все'),
              Tab(text: 'Просмотренные'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                MovieList(movies: _movies),
                const MovieList(movies: <Movie>[]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// @TABS_END@

// @PUSH@
class MovieList extends StatelessWidget {
  final List<Movie> movies;
  const MovieList({super.key, required this.movies});

  Future<void> _openDetail(BuildContext context, Movie movie) async {
    // push возвращает Future: он завершится, когда экран закроют
    final Object? result = await Navigator.of(context)
        .pushNamed(Routes.detail, arguments: movie);

    // За время ожидания виджет мог быть удалён из дерева
    if (!context.mounted) {
      return;
    }
    if (result != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Экран вернул: $result')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(child: Text('Пока пусто'));
    }
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (BuildContext context, int index) {
        final Movie movie = movies[index];
        return ListTile(
          title: Text(movie.title),
          subtitle: Text('${movie.director}, ${movie.year}'),
          onTap: () => _openDetail(context, movie),
        );
      },
    );
  }
}
// @PUSH_END@

// @DIALOG@
class DetailScreen extends StatelessWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  Future<void> _confirmDelete(BuildContext context) async {
    // Диалог — это тоже маршрут: он закрывается тем же pop
    // и умеет возвращать значение
    final bool? answer = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Удалить фильм?'),
        content: Text('«${movie.title}» будет удалён безвозвратно.'),
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

    // null означает, что пользователь коснулся вне диалога
    if ((answer ?? false) && context.mounted) {
      Navigator.of(context).pop('удалён');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Редактировать',
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.edit, arguments: movie),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалить',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Режиссёр: ${movie.director}'),
            Text('Год: ${movie.year}'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop('изменён'),
              child: const Text('Вернуться с результатом'),
            ),
          ],
        ),
      ),
    );
  }
}
// @DIALOG_END@

// @POPSCOPE@
class EditScreen extends StatefulWidget {
  final Movie? movie;
  const EditScreen({super.key, this.movie});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  bool _changed = false;

  Future<bool> _confirmLeave() async {
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Выйти без сохранения?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Остаться'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // PopScope перехватывает возврат: и кнопку «назад» Android,
    // и жест «свайп назад» на iOS. WillPopScope устарел.
    return PopScope<Object?>(
      canPop: !_changed,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool leave = await _confirmLeave();
        if (leave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Редактирование')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Фильм: ${widget.movie?.title ?? 'новый'}'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Есть несохранённые изменения'),
                value: _changed,
                onChanged: (bool v) => setState(() => _changed = v),
              ),
              const Text(
                'Включите переключатель и попробуйте выйти — появится '
                'запрос подтверждения.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// @POPSCOPE_END@

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Вкладка поиска'));
}

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Вкладка статистики'));
}
