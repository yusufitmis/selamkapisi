import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class QuestionDialog extends StatefulWidget {
  final DocumentSnapshot preacher;

  const QuestionDialog({required this.preacher, super.key});

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final _questionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  late GenerativeModel _aiModel;
  String _selectedLength = 'medium'; // 'short', 'medium', 'detailed'

  // Karakter sınırları
  final Map<String, int> _lengthLimits = {
    'short': 300,    // Kısa cevaplar için 200 karakter
    'medium': 500,   // Orta uzunlukta cevaplar için 400 karakter
    'detailed': 700, // Detaylı cevaplar için 600 karakter
  };

  // Renk şeması
  final Color _primaryColor = const Color(0xFF121212);
  final Color _secondaryColor = const Color(0xFFD4AF37);
  final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);
  final Color _hintColor = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    try {
      const apiKey = 'AIzaSyANwdtOCm00cz88rAYGgULcS3_rj6i5ufE';
      _aiModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
    } catch (e) {
      debugPrint('AI initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('AI servisi başlatılamadı'),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preacherData = widget.preacher.data() as Map<String, dynamic>? ?? {};
    final preacherName = preacherData['name'] ?? 'Vaiz';
    final preacherImage = preacherData['imageUrl'] ?? '';

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vaiz bilgileri
              Row(
                children: [
                  if (preacherImage.isNotEmpty)
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: _accentColor.withAlpha((255 * 0.1).round()),
                      backgroundImage: NetworkImage(preacherImage),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$preacherName\'a Soru Sor',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sorunuzu yazın, size cevap verelim',
                          style: TextStyle(
                            color: _hintColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Soru giriş alanı
              Container(
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _secondaryColor, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _questionController,
                    maxLines: 5,
                    minLines: 3,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Sorunuzu buraya yazınız...',
                      hintStyle: TextStyle(
                        color: _hintColor,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cevap uzunluğu seçimi
              Text(
                'Cevap Uzunluğu:',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildLengthOption(
                      'Kısa',
                      'short',
                      Icons.short_text,
                      '300 karakter (2-3 cümle)',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLengthOption(
                      'Orta',
                      'medium',
                      Icons.text_snippet,
                      '500 karakter (1 paragraf)',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLengthOption(
                      'Detaylı',
                      'detailed',
                      Icons.article,
                      '700 karakter (detaylı)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: Text(
                        'VAZGEÇ',
                        style: TextStyle(
                          color: _backgroundColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _secondaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _submitQuestion,
                      child: Text(
                        'GÖNDER',
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Yükleme göstergesi
              if (_isLoading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  minHeight: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(_secondaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cevap hazırlanıyor...',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLengthOption(String title, String value, IconData icon, String description) {
    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _selectedLength = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selectedLength == value
              ? _secondaryColor.withAlpha((255 * 0.2).round())
              : _backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedLength == value ? _secondaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: _selectedLength == value ? _secondaryColor : _primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: _selectedLength == value ? _secondaryColor : _primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _hintColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lütfen bir soru yazınız'),
            backgroundColor: Colors.orange[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final preacherData = widget.preacher.data() as Map<String, dynamic>? ?? {};
      final preacherName = preacherData['name'] ?? 'İslam Alimi';
      final preacherEra = preacherData['era'] ?? '';
      final preacherStyle = preacherData['style'] ?? '';

      final aiAnswer = await _generateAIResponse(
        _questionController.text,
        preacherName,
        preacherEra,
        preacherStyle,
      );

      final limitedAnswer = _limitAnswerLength(aiAnswer, _selectedLength);

      await _firestore.collection('questions').add({
        'preacherId': widget.preacher.id,
        'preacherName': preacherName,
        'question': _questionController.text,
        'answer': limitedAnswer,
        'userId': _auth.currentUser?.uid ?? 'anonymous',
        'userEmail': _auth.currentUser?.email ?? 'anonymous',
        'date': Timestamp.now(),
        'isAnswered': true,
        'isAIResponse': true,
        'responseLength': _selectedLength,
        'wordCount': limitedAnswer.split(' ').length,
        'charCount': limitedAnswer.length,
        'preacherEra': preacherEra,
        'preacherStyle': preacherStyle,
      });

      if (mounted) {
        Navigator.pop(context); // Önce mevcut dialog'u kapat

        // Sonra yeni dialog'u göster
        showDialog(
          context: context,
          builder: (context) => AnswerDialog(
            question: _questionController.text,
            answer: limitedAnswer,
            preacherName: preacherName,
            primaryColor: _primaryColor,
            secondaryColor: _secondaryColor,
            backgroundColor: _backgroundColor,
            textColor: _textColor,
            borderColor: Color(0xFFD4AF37),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$preacherName tarzında cevap oluşturuldu (${limitedAnswer.length} karakter)'),
            backgroundColor: _primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error submitting question: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  String _limitAnswerLength(String answer, String lengthType) {
    final maxLength = _lengthLimits[lengthType] ?? 400;
    return answer.length > maxLength
        ? answer.substring(0, maxLength)
        : answer;
  }

  Future<String> _generateAIResponse(
      String question,
      String preacherName,
      String preacherEra,
      String preacherStyle,
      ) async {
    try {
      final prompt = _generatePrompt(question, preacherName, preacherEra, preacherStyle);
      final response = await _aiModel.generateContent([Content.text(prompt)]);
      return response.text ?? "Cevap oluşturulamadı";
    } catch (e) {
      debugPrint('AI generation error: $e');
      return "Hata: Cevap oluşturulamadı";
    }
  }

  String _generatePrompt(
      String question,
      String preacherName,
      String preacherEra,
      String preacherStyle,
      ) {
    final lengthSettings = {
      'short': {
        'instruction': 'Maksimum 300 karakterlik (2-3 cümle) öz cevap ver',
        'structure': '1. Direkt cevap\n2. ${preacherName.split(' ').first} dedi ki: ...',
        'tone': 'kısa ve öz'
      },
      'medium': {
        'instruction': '500 karakteri geçmeyecek şekilde (1 paragraf) cevap ver',
        'structure': '1. Kısa açıklama\n2. Temel referans\n3. Pratik tavsiye',
        'tone': 'açıklayıcı'
      },
      'detailed': {
        'instruction': '700 karakter sınırında detaylı cevap ver',
        'structure': '1. Giriş\n2. Ayet/hadisler\n3. Tarihsel bağlam\n4. Günümüz yorumu\n5. Sonuç',
        'tone': 'derinlemesine'
      },
    };

    final settings = lengthSettings[_selectedLength] ?? lengthSettings['medium']!;
    final charLimit = _lengthLimits[_selectedLength] ?? 400;

    return '''
    Sen $preacherName ($preacherEra) gibi davranan bir İslam alimisin. 
    Üslubun: $preacherStyle
    
    Aşağıdaki soruyu ${settings['tone']} üslupla ve MAKSİMUM $charLimit KARAKTERİ geçmeyecek şekilde cevapla:
    
    Soru: "$question"
    
    Cevap formatı:
    ${settings['structure']}
    
    ${settings['instruction']}
    Dini referansları ayet ve hadis numaralarıyla belirt.
    ${_selectedLength == 'detailed' ? 'En az 3 paragraf halinde yaz.' : ''}
    Cevaplarken $preacherName'nin karakteristik özelliklerini yansıt.
    KESİNLİKLE ${charLimit} KARAKTERİ GEÇME!
    ''';
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
class AnswerDialog extends StatelessWidget {
  final String question;
  final String answer;
  final String preacherName;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const AnswerDialog({
    super.key,
    required this.question,
    required this.answer,
    required this.preacherName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$preacherName Cevabı:',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                question,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: borderColor),
              const SizedBox(height: 16),
              Text(
                answer,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'TAMAM',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}