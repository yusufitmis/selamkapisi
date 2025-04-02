import 'package:flutter/material.dart';

class FatwaQuestionDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const FatwaQuestionDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<FatwaQuestionDialog> createState() => _FatwaQuestionDialogState();
}

class _FatwaQuestionDialogState extends State<FatwaQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fetva Sorusu Sor'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sorunuzu detaylı şekilde yazın:'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _questionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Örneğin: "Kadınların iş hayatında çalışması caiz midir?"',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir soru yazın';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[800],
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(_questionController.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('Gönder'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}