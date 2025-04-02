import 'package:flutter/material.dart';

import 'app_color.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightBlue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldAccent, width: 2),
        ),
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık
                Row(
                  children: [
                    Icon(Icons.live_help, color: AppColors.goldAccent, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      'Fetva Sorusu Sor',
                      style: TextStyle(
                        color: AppColors.primaryBlack,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Açıklama
                Text(
                  'Dini konularda merak ettiğiniz soruları buradan sorabilirsiniz. '
                      'Sorunuzu mümkün olduğunca detaylı yazınız.',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Soru Giriş Alanı
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteText,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: (0.1 * 255)),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _questionController,
                    maxLines: 5,
                    style: TextStyle(color: AppColors.primaryBlack),
                    decoration: InputDecoration(
                      hintText: 'Örneğin: "Kadınların iş hayatında çalışması caiz midir?"',
                      hintStyle: TextStyle(color: AppColors.darkGray.withValues(alpha: (0.6 * 255))),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir soru yazın';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 25),

                // Butonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // İptal Butonu
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: AppColors.goldAccent, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'VAZGEÇ',
                          style: TextStyle(
                            color: AppColors.goldAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Gönder Butonu
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.onSubmit(_questionController.text.trim());
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'GÖNDER',
                          style: TextStyle(
                            color: AppColors.primaryBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}