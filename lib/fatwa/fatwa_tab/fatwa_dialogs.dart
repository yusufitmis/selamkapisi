import 'package:flutter/material.dart';

import 'app_color.dart';

class FatwaResponseDialog extends StatelessWidget {
  final Map<String, dynamic> fatwa;

  const FatwaResponseDialog({
    super.key,
    required this.fatwa,
  });

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                children: [
                  Icon(
                    fatwa['status'] == 'under_review'
                        ? Icons.warning
                        : Icons.verified_user,
                    color: fatwa['status'] == 'under_review'
                        ? Colors.orange
                        : AppColors.goldAccent,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Fetva Cevabı',
                    style: TextStyle(
                      color: AppColors.primaryBlack,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Soru
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.whiteText,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  fatwa['question'] ?? 'Soru yok',
                  style: TextStyle(
                    color: AppColors.primaryBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Durum Uyarısı
              if (fatwa['status'] == 'under_review')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: (0.2 * 255)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bu cevap denetim için işaretlenmiştir. '
                              'Kesinleşmemiş bilgi içerebilir.',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Cevap
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.whiteText,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  fatwa['answer'] ?? 'Cevap bulunamadı',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 20),

              // Referanslar
              if (fatwa['references'] != null && (fatwa['references'] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referanslar:',
                      style: TextStyle(
                        color: AppColors.primaryBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.whiteText.withValues(alpha: (0.8 * 255)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (fatwa['references'] as List).map((ref) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.arrow_forward_ios,
                                  color: AppColors.goldAccent, size: 12),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ref.toString(),
                                  style: TextStyle(
                                    color: AppColors.darkGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Kapat Butonu
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'KAPAT',
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
        ),
      ),
    );
  }
}