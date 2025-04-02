import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'fatwa_dialogs.dart';
import 'fatwa_question_dialog.dart';

class FatwaTab extends StatefulWidget {
  const FatwaTab({super.key});

  @override
  State<FatwaTab> createState() => _FatwaTabState();
}

class _FatwaTabState extends State<FatwaTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = '';
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _initializeGenerativeAI();
  }

  Future<void> _initializeGenerativeAI() async {
    try {
      const apiKey = 'AIzaSyANwdtOCm00cz88rAYGgULcS3_rj6i5ufE';
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
    } catch (e) {
      debugPrint('AI initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI servisi başlatılamadı')),
        );
      }
    }
  }

  Stream<QuerySnapshot> _getFatwas() {
    return _firestore
        .collection('fatwas')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _submitQuestion(String question) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen giriş yapın')),
          );
        }
        return;
      }

      setState(() => _isLoading = true);

      final docRef = _firestore.collection('fatwaRequests').doc();
      await docRef.set({
        'question': question,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': user.email,
        'status': 'processing',
      });

      final aiResponse = await _generateAIResponse(question);
      final verifiedResponse = _verifyCompliance(aiResponse);
      await _saveFinalResponse(docRef.id, question, verifiedResponse, user.uid);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fetva başarıyla oluşturuldu')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }

  Future<String> _generateAIResponse(String question) async {
    try {
      const islamicComplianceRules = [
        "Kuran ayetleri",
        "Sahih hadisler",
        "Fıkıh kitapları",
        "Alimlerin icması"
      ];

      final prompt = '''
      Sen bir İslam alimisin ve dini konularda fetva veriyorsun.
      Lütfen aşağıdaki soruyu yanıtlarken şu kaynaklara dayan:
      ${islamicComplianceRules.join(", ")}.
      
      Soru: "$question"
      
      Cevabını şu şekilde ver:
      1. Önce soruyu anladığını gösteren kısa bir giriş
      2. Detaylı ve referanslı cevap (ayet ve hadis numaralarıyla)
      3. Sonuç ve tavsiyeler
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Cevap oluşturulamadı";
    } catch (e) {
      debugPrint('AI generation error: $e');
      throw Exception('Fetva oluşturulamadı: $e');
    }
  }

  Map<String, dynamic> _verifyCompliance(String response) {
    const forbiddenTerms = ["haram", "küfür", "bid'at"];
    final warnings = forbiddenTerms.where((term) =>
        response.toLowerCase().contains(term.toLowerCase())
    ).toList();

    return {
      'answer': response,
      'complianceCheck': warnings.isNotEmpty ? "ManualReviewNeeded" : "Approved",
      'warnings': warnings,
      'checkedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> _saveFinalResponse(
      String requestId,
      String question,
      Map<String, dynamic> verifiedResponse,
      String userId,
      ) async {
    try {
      final references = _extractReferences(verifiedResponse['answer']);

      await _firestore.collection('fatwas').doc(requestId).set({
        'question': question,
        'answer': verifiedResponse['answer'],
        'references': references,
        'status': verifiedResponse['complianceCheck'] == "Approved"
            ? "approved"
            : "under_review",
        'complianceReport': verifiedResponse,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Save response error: $e');
      throw Exception('Fetva kaydedilemedi: $e');
    }
  }

  List<String> _extractReferences(String text) {
    final references = <String>[];
    final verseRegex = RegExp(r'([A-Za-züğşöçıİĞÜŞÖÇ]+ \d+:\d+)');
    references.addAll(verseRegex.allMatches(text).map((m) => m.group(0)!));

    final hadithRegex = RegExp(r'(Buhari|Müslim|Tirmizi|Ebu Davud|Nesai|İbn Mâce)[\w\s]*No:?\s?\d+', caseSensitive: false);
    references.addAll(hadithRegex.allMatches(text).map((m) => m.group(0)!));

    return references;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Fetva ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Yeni Fetva Sorusu Sor'),
              onPressed: () => _showAskFatwaDialog(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8.0),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getFatwas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }

              final filteredFatwas = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final question = data['question']?.toString().toLowerCase() ?? '';
                return question.contains(_searchQuery.toLowerCase());
              }).toList();

              return ListView.builder(
                itemCount: filteredFatwas.length,
                itemBuilder: (context, index) {
                  final fatwa = filteredFatwas[index].data() as Map<String, dynamic>;
                  final answer = fatwa['answer']?.toString() ?? '';
                  final truncatedAnswer = answer.length > 50
                      ? '${answer.substring(0, 50)}...'
                      : answer;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      title: Text(fatwa['question']?.toString() ?? 'Soru yok'),
                      subtitle: Text(truncatedAnswer),
                      trailing: fatwa['status'] == 'under_review'
                          ? const Icon(Icons.warning, color: Colors.orange)
                          : null,
                      onTap: () => _showFatwaResponse(context, fatwa),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAskFatwaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FatwaQuestionDialog(
        onSubmit: (question) => _submitQuestion(question),
      ),
    );
  }

  void _showFatwaResponse(BuildContext context, Map<String, dynamic> fatwa) {
    showDialog(
      context: context,
      builder: (context) => FatwaResponseDialog(fatwa: fatwa),
    );
  }
}