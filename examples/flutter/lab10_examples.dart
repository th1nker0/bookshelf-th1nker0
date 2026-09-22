// ===========================================================================
//  Разбор примеров к лабораторной работе №10
//  Взаимодействие с пользователем: жесты, формы, валидация
// ===========================================================================
//
//      flutter run -t lib/examples/lab10_examples.dart
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      useMaterial3: true,
    ),
    home: const FormScreen(),
  );
}

enum WatchStatus {
  planned('Запланирован'),
  watching('Смотрю'),
  finished('Просмотрен');

  final String label;
  const WatchStatus(this.label);
}

// @FORM@
class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // Ключ связывает форму с кодом, который запускает проверку
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _year = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  bool _saving = false;

  @override
  void dispose() {
    // Контроллеры и узлы фокуса ОБЯЗАТЕЛЬНО освобождать,
    // иначе это утечка памяти
    _title.dispose();
    _year.dispose();
    _titleFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // validate() запускает все validator формы разом
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Сохранено: ${_title.text}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Форма с проверкой')),
      // Касание по пустому месту убирает клавиатуру
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          // Проверка начинается после первого ввода, а не сразу:
          // пользователь не видит ошибок на пустой форме
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // ListView, а не Column: иначе при появлении клавиатуры
          // получим «bottom overflowed by N pixels»
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                decoration: const InputDecoration(
                  labelText: 'Название *',
                  hintText: 'Например, Интерстеллар',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _yearFocus.requestFocus(),
                validator: (String? v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Введите название';
                  }
                  if (v.trim().length < 2) {
                    return 'Слишком короткое название';
                  }
                  return null; // null означает «ошибок нет»
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _year,
                focusNode: _yearFocus,
                decoration: const InputDecoration(
                  labelText: 'Год выхода',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                // Ограничение ввода прямо при наборе
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (String? v) {
                  if (v == null || v.isEmpty) {
                    return null; // поле необязательное
                  }
                  final int? year = int.tryParse(v);
                  if (year == null) {
                    return 'Только цифры';
                  }
                  if (year < 1895 || year > DateTime.now().year + 1) {
                    return 'Год вне допустимого диапазона';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const FieldsDemo(),
              const SizedBox(height: 16),
              SaveButton(saving: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
// @FORM_END@

// @FIELDS@
class FieldsDemo extends StatefulWidget {
  const FieldsDemo({super.key});

  @override
  State<FieldsDemo> createState() => _FieldsDemoState();
}

class _FieldsDemoState extends State<FieldsDemo> {
  WatchStatus _status = WatchStatus.planned;
  double _rating = 0;
  bool _favourite = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DropdownButtonFormField<WatchStatus>(
          initialValue: _status,
          decoration: const InputDecoration(
            labelText: 'Состояние',
            border: OutlineInputBorder(),
          ),
          items: WatchStatus.values
              .map(
                (WatchStatus s) => DropdownMenuItem<WatchStatus>(
                  value: s,
                  child: Text(s.label),
                ),
              )
              .toList(),
          onChanged: (WatchStatus? v) => setState(() => _status = v!),
        ),
        const SizedBox(height: 12),
        Text('Оценка: ${_rating.toStringAsFixed(1)}'),
        Slider(
          value: _rating,
          max: 10,
          divisions: 20,
          label: _rating.toStringAsFixed(1),
          onChanged: (double v) => setState(() => _rating = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('В избранном'),
          value: _favourite,
          onChanged: (bool v) => setState(() => _favourite = v),
        ),
        const RatingStars(),
      ],
    );
  }
}
// @FIELDS_END@

// @STARS@
/// Оценка звёздами. Повторное нажатие на текущую звезду сбрасывает оценку.
class RatingStars extends StatefulWidget {
  const RatingStars({super.key});

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int i) {
        final bool filled = i < _value;
        return Semantics(
          button: true,
          label: 'Оценка ${i + 1} из 5',
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() {
              _value = _value == i + 1 ? 0 : i + 1;
            }),
            icon: Icon(
              filled ? Icons.star : Icons.star_border,
              color: filled ? Colors.amber.shade700 : null,
            ),
          ),
        );
      }),
    );
  }
}
// @STARS_END@

// @BUTTON@
class SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onPressed;

  const SaveButton({super.key, required this.saving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      // onPressed: null полностью отключает кнопку и делает её серой.
      // Без этого быстрый двойной тап создаст две записи.
      onPressed: saving ? null : onPressed,
      icon: saving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(saving ? 'Сохранение…' : 'Сохранить'),
    );
  }
}
// @BUTTON_END@

// @FEEDBACK@
/// Удаление с возможностью отмены — приём, который стоит знать наизусть.
Future<void> deleteWithUndo(
  BuildContext context,
  List<String> items,
  String item,
) async {
  final int index = items.indexOf(item);
  items.remove(item);

  ScaffoldMessenger.of(context)
    // Убираем предыдущее сообщение, иначе они выстроятся в очередь
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('«$item» удалён'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () => items.insert(index, item),
        ),
      ),
    );
}

/// Выбор из списка вариантов — панель снизу, а не диалог.
Future<WatchStatus?> pickStatus(BuildContext context) =>
    showModalBottomSheet<WatchStatus>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: WatchStatus.values
              .map(
                (WatchStatus s) => ListTile(
                  title: Text(s.label),
                  onTap: () => Navigator.of(context).pop(s),
                ),
              )
              .toList(),
        ),
      ),
    );
// @FEEDBACK_END@
