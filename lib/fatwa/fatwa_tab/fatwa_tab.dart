import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../google_ads.dart';
import 'app_color.dart';
import 'fatwa_dialogs.dart';
import 'fatwa_question_dialog.dart';

class FatwaTab extends StatefulWidget {
  const FatwaTab({super.key,});

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

  final GoogleAds googleAds = GoogleAds();


  @override
  void dispose() {
    googleAds.bannerAd?.dispose();
    googleAds.interstitialAd?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  final int _maxQuestionLength = 200;
  final int _maxAnswerLength = 1300;

  @override
  void initState() {
    super.initState();
    _initializeGenerativeAI();
    googleAds.loadInterstitialAd();
    googleAds.loadBannerAd(adLoaded: () {
      setState(() {

      });
    },);
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
          SnackBar(
            content: const Text('AI servisi başlatılamadı'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  Stream<QuerySnapshot> _getFatwas() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('fatwas')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _deleteFatwa(String fatwaId) async {
    try {
      await _firestore.collection('fatwas').doc(fatwaId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fetva başarıyla silindi'),
            backgroundColor: Colors.green[800],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme işlemi başarısız: ${e.toString()}'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  Future<void> _deleteAllMyFatwas() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('fatwas')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silinecek fetva bulunamadı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${querySnapshot.docs.length} fetva başarıyla silindi'),
            backgroundColor: Colors.green[800],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Toplu silme işlemi başarısız: ${e.toString()}'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(String fatwaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightBlue,
        title: Text(
          'Fetvayı Sil',
          style: TextStyle(color: AppColors.primaryBlack),
        ),
        content: Text(
          'Bu fetvayı silmek istediğinizden emin misiniz?',
          style: TextStyle(color: AppColors.darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'VAZGEÇ',
              style: TextStyle(color: AppColors.goldAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldAccent,
            ),
            onPressed: () {
              _deleteFatwa(fatwaId);
              Navigator.pop(context);
            },
            child: Text(
              'SİL',
              style: TextStyle(color: AppColors.primaryBlack),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightBlue,
        title: Text(
          'Tüm Fetvaları Sil',
          style: TextStyle(color: AppColors.primaryBlack),
        ),
        content: Text(
          'Tüm fetvalarınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(color: AppColors.darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'VAZGEÇ',
              style: TextStyle(color: AppColors.goldAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800]!,
            ),
            onPressed: () {
              _deleteAllMyFatwas();
              Navigator.pop(context);
            },
            child: const Text(
              'TÜMÜNÜ SİL',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: Column(
        children: [
          // Arama ve Yeni Soru Bölümü
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlack,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.3).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Arama Kutusu
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteText,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.3).round()),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Fetva ara...',
                      hintStyle: TextStyle(
                          color: AppColors.darkGray.withAlpha((255 * 0.3).round())),
                      prefixIcon: Icon(Icons.search, color: AppColors.goldAccent),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: AppColors.goldAccent),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(height: 16),
                // Butonlar
                Row(
                  children: [
                    // Yeni Soru Butonu

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add_circle, color: AppColors.primaryBlack),
                        label: Text('YENİ SORU',
                          style: TextStyle(
                            color: AppColors.primaryBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          // Reklamı göster ve sonra dialogu aç
                          googleAds.interstitialAd?.show().then((_) {
                            _showAskFatwaDialog(context);
                          }).catchError((error) {
                            // Reklam gösterilemezse direkt dialogu aç
                            _showAskFatwaDialog(context);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          shadowColor: AppColors.goldAccent.withAlpha((255 * 0.3).round()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tümünü Sil Butonu
                    if (currentUser != null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[800],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _showDeleteAllConfirmationDialog,
                        child: Icon(Icons.delete_forever, color: Colors.white),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Fetva Listesi
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFatwas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.goldAccent),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 50),
                          const SizedBox(height: 20),
                          Text(
                            'Fetvalar yüklenirken hata oluştu',
                            style: TextStyle(
                              color: AppColors.primaryBlack,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Lütfen internet bağlantınızı kontrol edip tekrar deneyin',
                            style: TextStyle(
                              color: AppColors.darkGray,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredFatwas = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final question = data['question']?.toString().toLowerCase() ?? '';
                    return question.contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (filteredFatwas.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, color: AppColors.goldAccent, size: 50),
                          const SizedBox(height: 20),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Henüz fetva eklenmemiş'
                                : 'Aramanızla eşleşen fetva bulunamadı',
                            style: TextStyle(
                              color: AppColors.primaryBlack,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: filteredFatwas.length,
                    itemBuilder: (context, index) {
                      final doc = filteredFatwas[index];
                      final fatwa = doc.data() as Map<String, dynamic>;
                      final question = fatwa['question']?.toString() ?? 'Soru yok';
                      final answer = fatwa['answer']?.toString() ?? '';
                      final truncatedAnswer = answer.length > 80
                          ? '${answer.substring(0, 80)}...'
                          : answer;
                      final isMyFatwa = currentUser?.uid == fatwa['userId'];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.whiteText,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((255 * 0.1).round()),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                question,
                                style: TextStyle(
                                  color: AppColors.primaryBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  truncatedAnswer,
                                  style: TextStyle(
                                    color: AppColors.darkGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              trailing: fatwa['status'] == 'under_review'
                                  ? Icon(Icons.verified, color: Colors.orange)
                                  : Icon(Icons.verified_user, color: AppColors.goldAccent),
                              onTap: () => _showFatwaResponse(context, fatwa),
                            ),
                            if (isMyFatwa)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red[800]),
                                  onPressed: () => _showDeleteConfirmationDialog(doc.id),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAskFatwaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FatwaQuestionDialog(
        maxLength: _maxQuestionLength,
        onSubmit: (question) => _submitQuestion(question),
      ),
    );
  }

  void _showFatwaResponse(BuildContext context, Map<String, dynamic> fatwa) {
    // Önce reklamı göster, sonra dialogu aç
    googleAds.interstitialAd?.show().then((_) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => FatwaResponseDialog(fatwa: fatwa),
        );
      }
    }).catchError((error) {
      // Reklam gösterilemezse direkt dialogu aç
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => FatwaResponseDialog(fatwa: fatwa),
        );
      }
    });
  }

  Future<void> _submitQuestion(String question) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Lütfen giriş yapın'),
              backgroundColor: Colors.red[800],
            ),
          );
        }
        return;
      }

      if (question.length > _maxQuestionLength) {
        throw Exception('Soru maksimum $_maxQuestionLength karakter olmalıdır');
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

      // Yeni eklenen kısım: Cevap oluştuktan sonra otomatik göster
      if (mounted) {
        setState(() => _isLoading = false);

        // Önce snackbar göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fetva başarıyla oluşturuldu'),
            backgroundColor: Colors.green[800],
          ),
        );

        // Sonra dialog göster
        final fatwaData = {
          'question': question,
          'answer': verifiedResponse['answer'],
          'references': _extractReferences(verifiedResponse['answer']),
          'status': verifiedResponse['complianceCheck'] == "Approved"
              ? "approved"
              : "under_review",
          'userId': user.uid,
        };

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFatwaResponse(context, fatwaData);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  Future<String> _generateAIResponse(String question) async {
    try {
      const islamicComplianceRules = [
        "Kuran ayetleri",
        "Sahih hadisler",
        "Dört mezhep görüşleri",
        "Fıkıh kitapları",
        "Alimlerin icması"
      ];

      final prompt = '''
      Sen bir İslam alimisin ve dini konularda kısa, öz fetvalar veriyorsun.
      Lütfen aşağıdaki soruyu en fazla $_maxAnswerLength karakterle yanıtla.
      Yanıtını şu sırayla ve kısa tut:
      1. Sorunun özeti (1 cümle)
      2. Varsa ilgili Kuran ayetleri (sure ve ayet isimleriyle numaralarıyla) ayetin kendisini de yaz
      3. Varsa sahih hadisler (kaynağıyla) hadisi yaz.
      4. Dört büyük mezhebin (Hanefi, Şafii, Maliki, Hanbeli) kısaca her birinden bir cümle
      5. Diğer güvenilir fıkıh kaynakları/icmalar (varsa) açıkla
      6. Sonuç ve tavsiye (1-2 cümle)
      
      CEVAP TOPLAMDA $_maxAnswerLength KARAKTERİ GEÇMEMELİ!
      
      Soru: "$question"
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final fullResponse = response.text ?? "Cevap oluşturulamadı";

      return fullResponse.length > _maxAnswerLength
          ? fullResponse.substring(0, _maxAnswerLength)
          : fullResponse;
    } catch (e) {
      debugPrint('AI generation error: $e');
      throw Exception('Fetva oluşturulamadı: $e');
    }
  }

  Map<String, dynamic> _verifyCompliance(String response) {
    const forbiddenTerms = ["küfür olan kelimeler", "islama hakaret edilen şeyler"];
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


}