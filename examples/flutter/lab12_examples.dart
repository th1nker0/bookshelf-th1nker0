// ===========================================================================
//  Разбор примеров к лабораторной работе №12
//  Dart Event Loop, изоляты и производительность
// ===========================================================================
//
//      flutter run -t lib/examples/lab12_examples.dart
//
//  Главный опыт этого разбора — две кнопки: одна считает в потоке
//  интерфейса, другая в отдельном изоляте. Следите за индикатором.
// ===========================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    ),
    home: const DemoScreen(),
  );
}

// @HEAVY@
/// Тяжёлое вычисление. Функция ОБЫЧНАЯ, не асинхронная: пока она
/// работает, изолят занят и ничего другого делать не может.
int heavySum(int limit) {
  int sum = 0;
  for (int i = 0; i < limit; i++) {
    sum += i % 7;
  }
  return sum;
}

/// Ошибка, которую делают почти все: добавить async и await,
/// надеясь, что интерфейс перестанет замирать. Не перестанет:
/// асинхронность — это переключение задач, а не параллелизм.
Future<int> heavySumAsync(int limit) async {
  return heavySum(limit); // await тут ничего не изменит
}
// @HEAVY_END@

// @COMPUTE@
/// Функция для изолята должна быть верхнего уровня или статической:
/// замыкание передать нельзя, у изолята своя память.
int _isolateSum(int limit) => heavySum(limit);

/// compute создаёт изолят, выполняет функцию и возвращает результат.
/// Поток интерфейса при этом свободен.
Future<int> heavySumInIsolate(int limit) => compute(_isolateSum, limit);
// @COMPUTE_END@

// @PARSE@
/// Разбор большой выгрузки — типичная задача для изолята.
/// Функция верхнего уровня, принимает и возвращает простые данные.
List<String> parseTitles(String raw) {
  final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
  final List<String> titles = <String>[];
  for (final dynamic item in list) {
    final Map<String, dynamic> map = item as Map<String, dynamic>;
    final String? title = map['title'] as String?;
    if (title != null && title.isNotEmpty) {
      titles.add(title);
    }
  }
  titles.sort();
  return titles;
}

Future<List<String>> parseInIsolate(String raw) => compute(parseTitles, raw);
// @PARSE_END@

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  static const int _limit = 300000000;

  String _status = 'Нажмите кнопку и следите за индикатором';
  bool _busy = false;

  Future<void> _runOnUiThread() async {
    setState(() {
      _busy = true;
      _status = 'Считаю в потоке интерфейса…';
    });
    // Даём кадру отрисоваться, чтобы стало видно замирание
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final Stopwatch watch = Stopwatch()..start();
    final int result = await heavySumAsync(_limit);
    watch.stop();

    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _status =
          'В потоке интерфейса: $result за ${watch.elapsedMilliseconds} мс '
          '— индикатор замирал';
    });
  }

  Future<void> _runInIsolate() async {
    setState(() {
      _busy = true;
      _status = 'Считаю в отдельном изоляте…';
    });

    final Stopwatch watch = Stopwatch()..start();
    final int result = await heavySumInIsolate(_limit);
    watch.stop();

    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _status =
          'В изоляте: $result за ${watch.elapsedMilliseconds} мс '
          '— индикатор крутился';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Изоляты и производительность')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Индикатор ниже вращается постоянно. Он и покажет, '
            'занят ли поток интерфейса.',
          ),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _runOnUiThread,
            child: const Text('Считать в потоке интерфейса'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _busy ? null : _runInIsolate,
            child: const Text('Считать в изоляте'),
          ),
          const SizedBox(height: 16),
          Text(_status, style: Theme.of(context).textTheme.bodyMedium),
          const Divider(height: 32),
          const OptimizationDemo(),
        ],
      ),
    );
  }
}

// @OPTIMIZE@
class OptimizationDemo extends StatefulWidget {
  const OptimizationDemo({super.key});

  @override
  State<OptimizationDemo> createState() => _OptimizationDemoState();
}

class _OptimizationDemoState extends State<OptimizationDemo> {
  // ValueNotifier обновляет ТОЛЬКО подписанный виджет.
  // setState перестроил бы весь метод build целиком.
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build всего блока — выполняется один раз');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Точечное обновление',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // const-виджет создаётся один раз и переиспользуется
        const Text('Эта строка помечена const и не пересоздаётся'),

        ValueListenableBuilder<int>(
          valueListenable: _counter,
          builder: (BuildContext context, int value, Widget? child) {
            debugPrint('перестроился только счётчик: $value');
            return Text('Значение: $value');
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _counter.value++,
          child: const Text('Увеличить'),
        ),
      ],
    );
  }
}
// @OPTIMIZE_END@

// @IMAGES@
/// Обложка 1200x1800 в памяти занимает около 8 МБ независимо от того,
/// какого размера её показывают. Сто таких изображений исчерпают
/// память устройства.
///
/// cacheWidth заставляет декодировать картинку сразу уменьшенной.
Widget cover(String url) => Image.network(
  url,
  width: 56,
  height: 84,
  fit: BoxFit.cover,
  // Декодировать в 112 px (двойная ширина для плотных экранов),
  // а не в исходные 1200
  cacheWidth: 112,
  loadingBuilder:
      (BuildContext context, Widget child, ImageChunkEvent? progress) =>
          progress == null
          ? child
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
      const Icon(Icons.broken_image_outlined),
);
// @IMAGES_END@

// @LAZY@
/// Постраничная подгрузка: следующая порция запрашивается,
/// когда до конца списка осталось меньше 400 пикселей.
mixin LazyLoading<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  bool loading = false;

  void initLazyLoading(Future<void> Function() loadNext) {
    scrollController.addListener(() {
      final bool nearEnd =
          scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 400;
      if (nearEnd && !loading) {
        loading = true;
        loadNext().whenComplete(() => loading = false);
      }
    });
  }

  @override
  void dispose() {
    // Контроллер прокрутки тоже нужно освобождать
    scrollController.dispose();
    super.dispose();
  }
}
// @LAZY_END@
