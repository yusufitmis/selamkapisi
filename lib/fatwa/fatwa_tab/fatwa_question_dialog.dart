import 'package:flutter/material.dart';
import 'app_color.dart';

class FatwaQuestionDialog extends StatefulWidget {
  final Function(String) onSubmit;
  final int maxLength;

  const FatwaQuestionDialog({
    super.key,
    required this.onSubmit,
    required this.maxLength,
  });

  @override
  State<FatwaQuestionDialog> createState() => _FatwaQuestionDialogState();
}

class _FatwaQuestionDialogState extends State<FatwaQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  int _remainingChars = 200;

  @override
  void initState() {
    super.initState();
    _remainingChars = widget.maxLength;
    _questionController.addListener(() {
      setState(() {
        _remainingChars = widget.maxLength - _questionController.text.length;
      });
    });
  }

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

                Text(
                  'Dini konularda merak ettiğiniz soruları buradan sorabilirsiniz. '
                      'Maksimum ${widget.maxLength} karakter kullanabilirsiniz.',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Karakter sayacı
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Kalan karakter: $_remainingChars',
                    style: TextStyle(
                      color: _remainingChars < 20 ? Colors.red : AppColors.darkGray,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteText,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _questionController,
                    maxLines: 5,
                    maxLength: widget.maxLength,
                    style: TextStyle(color: AppColors.primaryBlack),
                    decoration: InputDecoration(
                      hintText: 'Örneğin: "Sigara içmek haram mıdır?"',
                      hintStyle: TextStyle(color: AppColors.darkGray.withOpacity(0.6)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(15),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir soru yazın';
                      }
                      if (value.length > widget.maxLength) {
                        return 'Maksimum ${widget.maxLength} karakter kullanabilirsiniz';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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