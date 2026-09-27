// ===========================================================================
//  Разбор примеров к лабораторной работе №5
//  Асинхронное и сетевое программирование
// ===========================================================================
//
//  Предметная область — фильмы, а не книги.
//
//      dart run examples/lab05_examples.dart
//
//  Последний раздел обращается в сеть. Если интернета нет, пример не
//  падает, а показывает, как такую ситуацию обрабатывают.
// ===========================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  demoOrder();
  await Future<void>.delayed(const Duration(milliseconds: 300));
  await demoFuture();
  await demoAwait();
  await demoParallel();
  await demoStream();
  await demoController();
  await demoNetwork();
}

// ---------------------------------------------------------------------------
// 1. ПОРЯДОК ВЫПОЛНЕНИЯ
// ---------------------------------------------------------------------------
// @ORDER@
void demoOrder() {
  print('\n=== 1. Порядок выполнения ===\n');

  print('1 — синхронный код');

  // Макрозадача: попадёт в очередь событий
  Future<void>(() => print('5 — макрозадача'));

  // Таймер с нулевой задержкой — тоже макрозадача
  Timer.run(() => print('6 — таймер'));

  // Микрозадача: очередь микрозадач имеет приоритет
  Future<void>.value().then((_) => print('3 — микрозадача (then)'));
  scheduleMicrotask(() => print('4 — микрозадача (scheduleMicrotask)'));

  print('2 — синхронный код');

  // Правило: сначала весь синхронный код, затем ПОЛНОСТЬЮ очередь
  // микрозадач, и только потом ОДНО событие из очереди событий.
}
// @ORDER_END@

// ---------------------------------------------------------------------------
// 2. FUTURE И СТИЛЬ ОБРАТНЫХ ВЫЗОВОВ
// ---------------------------------------------------------------------------
// @FUTURE@
/// Изображает обращение к медленному источнику данных.
Future<String> loadTitle({bool fail = false}) => Future<String>.delayed(
  const Duration(milliseconds: 200),
  () => fail ? throw StateError('источник недоступен') : 'Интерстеллар',
);

Future<void> demoFuture() async {
  print('\n=== 2. Future: then / catchError ===\n');

  await loadTitle()
      .then((String title) => print('Получено: $title'))
      .catchError((Object e) => print('Ошибка: $e'))
      .whenComplete(() => print('Запрос завершён'));

  await loadTitle(fail: true)
      .then((String title) => print('Получено: $title'))
      .catchError((Object e) => print('Ошибка: $e'))
      .whenComplete(() => print('Запрос завершён'));
}
// @FUTURE_END@

// ---------------------------------------------------------------------------
// 3. ASYNC / AWAIT
// ---------------------------------------------------------------------------
// @AWAIT@
Future<void> demoAwait() async {
  print('\n=== 3. async / await ===\n');

  // Тот же код, что в разделе 2, но читается сверху вниз,
  // а ошибки ловятся обычным try-catch
  try {
    final String title = await loadTitle();
    print('Получено: $title');
  } on StateError catch (e) {
    print('Ошибка: ${e.message}');
  } finally {
    print('Запрос завершён');
  }

  try {
    final String title = await loadTitle(fail: true);
    print('Получено: $title');
  } on StateError catch (e) {
    print('Ошибка: ${e.message}');
  } finally {
    print('Запрос завершён');
  }
}
// @AWAIT_END@

// ---------------------------------------------------------------------------
// 4. ПАРАЛЛЕЛЬНОЕ ОЖИДАНИЕ И ТАЙМ-АУТ
// ---------------------------------------------------------------------------
// @PARALLEL@
Future<String> slow(String name, int ms) =>
    Future<String>.delayed(Duration(milliseconds: ms), () => name);

Future<void> demoParallel() async {
  print('\n=== 4. Параллельное ожидание ===\n');

  final Stopwatch watch = Stopwatch()..start();
  await slow('A', 200);
  await slow('B', 200);
  print('Последовательно: ${watch.elapsedMilliseconds} мс');

  watch.reset();
  final List<String> both = await Future.wait<String>(<Future<String>>[
    slow('A', 200),
    slow('B', 200),
  ]);
  print('Параллельно: ${watch.elapsedMilliseconds} мс, результат $both');

  // Ограничение времени ожидания
  try {
    await slow('медленный', 500).timeout(const Duration(milliseconds: 100));
  } on TimeoutException {
    print('Не дождались за 100 мс — это TimeoutException');
  }
}
// @PARALLEL_END@

// ---------------------------------------------------------------------------
// 5. ПОТОКИ
// ---------------------------------------------------------------------------
// @STREAM@
/// async* + yield — генератор потока значений.
Stream<int> countdown(int from) async* {
  for (int i = from; i > 0; i--) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    yield i;
  }
}

Future<void> demoStream() async {
  print('\n=== 5. Stream ===\n');

  // Способ 1: await for — самый читаемый
  await for (final int tick in countdown(3)) {
    print('Осталось: $tick');
  }

  // Способ 2: подписка. Даёт возможность отменить приём.
  final StreamSubscription<int> subscription = countdown(10).listen(
    (int value) => print('Значение: $value'),
    onDone: () => print('Поток закрыт'),
  );
  await Future<void>.delayed(const Duration(milliseconds: 120));
  await subscription.cancel(); // отписка обязательна
  print('Подписка отменена досрочно');

  // Преобразования потока — те же, что у Iterable
  final List<int> even = await countdown(6).where((int v) => v.isEven).toList();
  print('Чётные: $even');
}
// @STREAM_END@

// ---------------------------------------------------------------------------
// 6. StreamController — СОБСТВЕННЫЙ ИСТОЧНИК СОБЫТИЙ
// ---------------------------------------------------------------------------
// @CONTROLLER@
class CatalogEvents {
  // broadcast — допускает несколько подписчиков; обычный только одного
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Stream<String> get onChange => _controller.stream;

  void added(String title) => _controller.add('Добавлен: $title');
  void removed(String title) => _controller.add('Удалён: $title');

  Future<void> dispose() => _controller.close();
}

Future<void> demoController() async {
  print('\n=== 6. StreamController ===\n');

  final CatalogEvents events = CatalogEvents();
  final StreamSubscription<String> sub = events.onChange.listen(
    (String message) => print('  событие: $message'),
  );

  events.added('Довод');
  events.removed('Тень');

  // Даём событиям дойти до подписчика
  await Future<void>.delayed(Duration.zero);

  // Незакрытый контроллер и неотменённая подписка — утечка памяти
  await sub.cancel();
  await events.dispose();
  print('Подписка отменена, контроллер закрыт');
}
// @CONTROLLER_END@

// ---------------------------------------------------------------------------
// 7. СЕТЕВОЙ ЗАПРОС
// ---------------------------------------------------------------------------
// @NETWORK@
Future<void> demoNetwork() async {
  print('\n=== 7. Сетевой запрос ===\n');

  // В лабораторной работе используется пакет http. Здесь взят встроенный
  // HttpClient из dart:io, чтобы пример запускался без установки
  // зависимостей. Идея одна и та же.
  final HttpClient client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 5);

  final Uri uri = Uri.https('openlibrary.org', '/search.json', <String, String>{
    'q': 'interstellar',
    'limit': '3',
    'fields': 'title,first_publish_year',
  });

  try {
    final HttpClientRequest request = await client.getUrl(uri);
    final HttpClientResponse response = await request.close().timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      throw HttpException('сервис вернул ${response.statusCode}');
    }

    // Кириллицу декодируем явно как UTF-8, иначе получим «кракозябры»
    final String body = await response.transform(utf8.decoder).join();
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    final List<dynamic> docs = (json['docs'] as List<dynamic>?) ?? <dynamic>[];

    print('Найдено записей: ${docs.length}');
    for (final dynamic doc in docs) {
      final Map<String, dynamic> item = doc as Map<String, dynamic>;
      print('  ${item['title']} (${item['first_publish_year']})');
    }
  } on SocketException {
    print('Нет соединения с сетью — работаем с локальными данными');
  } on TimeoutException {
    print('Сервис не ответил за 10 секунд');
  } on FormatException {
    print('Сервис вернул не JSON');
  } on HttpException catch (e) {
    print('Ошибка протокола: ${e.message}');
  } finally {
    client.close();
  }
}
// @NETWORK_END@
