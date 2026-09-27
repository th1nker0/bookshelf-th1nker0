// ===========================================================================
//  ЗАГОТОВКА к лабораторной работе №10
//  Формы, ввод данных и обратная связь
// ===========================================================================
//
//      flutter run -t lib/starters/lab10_starter.dart
//
//  Заготовка запускается сразу. Одно поле формы («Название») написано
//  целиком как образец — остальные делайте по его подобию.
//  Заполняйте TODO по одному и нажимайте «r» после каждой правки.
//
//  ВНИМАНИЕ: пока не выполнено TODO 3.1, кнопка «Сохранить» сохраняет
//  даже пустую форму — проверка ещё не подключена. Это не поломка
//  заготовки, а исходная точка задания 3.
//
//  Готовое переносится так:
//      EditScreen  → lib/screens/edit_screen.dart
//      RatingStars → lib/widgets/rating_stars.dart
// ===========================================================================

import 'package:flutter/material.dart';

// Временная модель — замените на свой класс Book из ЛР №3.
enum ReadingStatus { planned, reading, finished }

String statusTitle(ReadingStatus s) => switch (s) {
  ReadingStatus.planned => 'В планах',
  ReadingStatus.reading => 'Читаю',
  ReadingStatus.finished => 'Прочитано',
};

class Book {
  final String title;
  final String author;
  final int? year;
  final ReadingStatus status;
  final int rating;

  const Book({
    required this.title,
    required this.author,
    this.year,
    this.status = ReadingStatus.planned,
    this.rating = 0,
  });
}

class NotDoneYet extends StatelessWidget {
  final String what;
  final double height;
  const NotDoneYet(this.what, {super.key, this.height = 64});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    margin: const EdgeInsets.symmetric(vertical: 8),
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
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}

// ===========================================================================
//  Экран-подложка: отсюда открывается форма и сюда возвращается результат
// ===========================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Book> _books = <Book>[];

  Future<void> _openEditor([Book? book]) async {
    final Book? result = await Navigator.of(context).push<Book>(
      MaterialPageRoute<Book>(builder: (_) => EditScreen(book: book)),
    );
    if (result == null) return; // пользователь нажал «назад»
    if (!mounted) return;
    setState(() {
      if (book == null) {
        _books.add(result);
      } else {
        _books[_books.indexOf(book)] = result;
      }
    });
  }

  void _delete(Book book) {
    final int index = _books.indexOf(book);
    setState(() => _books.removeAt(index));

    // TODO 5.1: покажите SnackBar с действием «Отменить»,
    //           возвращающим книгу на позицию index.
    // TODO 5.2: перед показом нового сообщения скройте предыдущее —
    //           ScaffoldMessenger.of(context).hideCurrentSnackBar().
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Формы и ввод'),
        // TODO 5.5: снабдите значки в AppBar подсказками tooltip.
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        child: const Icon(Icons.add),
      ),
      body: _books.isEmpty
          ? const Center(child: Text('Пока пусто — нажмите «+»'))
          : ListView.builder(
              itemCount: _books.length,
              itemBuilder: (BuildContext context, int i) {
                final Book b = _books[i];
                return ListTile(
                  key: ValueKey<String>('${b.title}/${b.author}'),
                  title: Text(b.title),
                  subtitle: Text('${b.author} · ${statusTitle(b.status)}'),
                  onTap: () => _openEditor(b),
                  // TODO 5.3: по нажатию на значок корзины покажите
                  //           AlertDialog с подтверждением и вызовите
                  //           _delete только при положительном ответе.
                  //           Касание мимо диалога возвращает null —
                  //           обработайте это как «нет»: result ?? false.
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(b),
                  ),
                  // TODO 5.4: долгое нажатие открывает showModalBottomSheet
                  //           со списком ReadingStatus.values для быстрой
                  //           смены состояния книги.
                );
              },
            ),
    );
  }
}

// ===========================================================================
//  ЗАДАНИЯ 2–3. Экран редактирования
// ===========================================================================
class EditScreen extends StatefulWidget {
  final Book? book; // null — режим добавления

  const EditScreen({super.key, this.book});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Контроллеры объявляются здесь и освобождаются в dispose().
  final TextEditingController _title = TextEditingController();
  final TextEditingController _author = TextEditingController();
  // TODO 2.1: добавьте контроллеры _year, _pages, _genres, _notes.

  ReadingStatus _status = ReadingStatus.planned;
  int _rating = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final Book? b = widget.book;
    if (b == null) return;
    _title.text = b.title;
    _author.text = b.author;
    _status = b.status;
    _rating = b.rating;
    // TODO 2.2: подставьте в поля остальные значения редактируемой книги.
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    // TODO 2.3: освободите добавленные контроллеры.
    //           Пропуск — утечка памяти, видная во вкладке Memory DevTools.
    super.dispose();
  }

  Book _buildBook() => Book(
    title: _title.text.trim(),
    author: _author.text.trim(),
    // TODO 2.4: соберите остальные поля. Год — int.tryParse(_year.text).
    status: _status,
    rating: _rating,
  );

  Future<void> _save() async {
    // TODO 3.1: прервите сохранение, если форма не проходит проверку:
    //           if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final Book book = _buildBook();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.of(context).pop(book);
    } finally {
      // Экран мог быть уже закрыт — проверка mounted обязательна.
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Новая книга' : 'Редактирование'),
      ),
      body: Form(
        key: _formKey,
        // TODO 2.5: включите autovalidateMode:
        //           AutovalidateMode.onUserInteraction.
        //           Тогда ошибка появится сразу после правки поля,
        //           а не только при нажатии «Сохранить».
        //
        // Форма лежит в ListView: при появлении клавиатуры содержимое
        // прокручивается, а не переполняется.
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            // ----- ОБРАЗЕЦ: полностью готовое поле --------------------
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Укажите название';
                }
                if (value.trim().length < 2) {
                  return 'Не менее 2 символов';
                }
                return null; // ошибок нет
              },
            ),
            const SizedBox(height: 12),
            // ----------------------------------------------------------

            // TODO 2.6: поле «Автор» — по образцу выше, обязательное.
            const NotDoneYet('поле «Автор»'),

            // TODO 2.7: поле «Год издания». Добавьте
            //           keyboardType: TextInputType.number и
            //           inputFormatters: [   // из material.dart
            //             FilteringTextInputFormatter.digitsOnly,
            //             LengthLimitingTextInputFormatter(4),
            //           ]
            //           Проверка: пусто — допустимо (return null),
            //           иначе число от 1450 до DateTime.now().year + 1.
            const NotDoneYet('поле «Год издания»'),

            // TODO 2.8: поле «Объём» — только цифры, больше 0, не более 10000.
            const NotDoneYet('поле «Объём»'),

            // TODO 2.9: поле «Жанры» — необязательное, значения через запятую.
            const NotDoneYet('поле «Жанры»'),

            // TODO 2.10: DropdownButtonFormField<ReadingStatus> по
            //            ReadingStatus.values; подписи берите у statusTitle.
            //            В onChanged не забудьте setState.
            const NotDoneYet('выбор состояния'),

            // TODO 4 (дополнительно): виджет RatingStars вместо Slider —
            //         пять значков, повторное нажатие сбрасывает оценку
            //         в ноль, при onChanged == null виджет только
            //         показывает оценку, метка Semantics «Оценка N из 5».
            Slider(
              value: _rating.toDouble(),
              max: 5,
              divisions: 5,
              label: '$_rating',
              onChanged: (double v) => setState(() => _rating = v.round()),
            ),

            // TODO 2.11: поле «Заметки» — maxLines: 4,
            //            LengthLimitingTextInputFormatter(500),
            //            textInputAction: TextInputAction.newline.
            const NotDoneYet('поле «Заметки»'),

            const SizedBox(height: 24),

            // ЗАДАНИЕ 3. Кнопка блокируется на время сохранения.
            FilledButton(
              // TODO 3.2: замените на _saving ? null : _save.
              //           Сначала проверьте, что будет без блокировки:
              //           быстро нажмите кнопку дважды и опишите
              //           наблюдаемое поведение в отчёте.
              onPressed: _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
//  ЗАДАНИЕ 1. Жесты (дополнительно)
// ===========================================================================
//
//  TODO 1.1: GestureDetector с onTap, onDoubleTap, onLongPress —
//            выведите в консоль, какой жест сработал, и объясните
//            в отчёте задержку между onTap и onDoubleTap.
//  TODO 1.2: InkWell вместо GestureDetector — сравните отклик
//            (чернильная волна есть только у InkWell).
//
// ===========================================================================
//  ЗАДАНИЕ 6. Фокус и клавиатура (дополнительно)
// ===========================================================================
//
//  TODO 6.1: заведите FocusNode для каждого поля и в onFieldSubmitted
//            передавайте фокус следующему:
//            FocusScope.of(context).requestFocus(_authorFocus).
//            FocusNode тоже освобождается в dispose().
//  TODO 6.2: касание по пустой области скрывает клавиатуру —
//            оберните тело в GestureDetector с
//            onTap: () => FocusScope.of(context).unfocus().
// ===========================================================================
