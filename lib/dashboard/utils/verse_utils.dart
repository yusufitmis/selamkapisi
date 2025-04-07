import 'package:flutter/material.dart';

class VerseUtils {
  static void showRandomVerse(BuildContext context) {
    const verses = [
      {
        'text': "Allah, kendisine karşı gelmekten sakınanlar ile beraberdir. (Bakara 194)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Sabret, şüphesiz Allah iyilik yapanların mükafatını zayi etmez. (Hud 115)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "İman etmedikçe cennete giremezsiniz, birbirinizi sevmedikçe de iman etmiş olamazsınız.",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Kim Allah'a ve ahiret gününe iman ediyorsa, ya hayır söylesin ya da sussun. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, adaletli davrananları sever. (Hucurat 9)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Şüphesiz ki Allah, tevbe edenleri ve temizlenenleri sever. (Bakara 222)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Namaz dinin direğidir. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Hiç ölmeyecekmiş gibi dünya için, yarın ölecekmiş gibi ahiret için çalış. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size kolaylık diler, zorluk dilemez. (Bakara 185)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Müminler ancak kardeştirler. (Hucurat 10)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Yalan söylemek kötülüğe, kötülük de cehenneme götürür. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah'ın rahmetinden ümit kesmeyin. (Zümer 53)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "İnsanlara teşekkür etmeyen, Allah'a da şükretmez. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, sabredenlerle beraberdir. (Bakara 153)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Komşusu açken tok yatan bizden değildir. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size şükrederseniz nimetlerini artırır. (İbrahim 7)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Temizlik imanın yarısıdır. (Müslim)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, güzel davrananları sever. (Bakara 195)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Müslüman, elinden ve dilinden emin olunan kimsedir. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatli, çok merhametlidir. (Nahl 18)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "İlim öğrenmek her Müslüman'a farzdır. (İbn Mace)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Kim bir hayra vesile olursa, onu yapanın ecri kadar ecir alır. (Müslim)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, sabredenleri mükafatlandıracaktır. (Zümer 10)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, aynı delikten iki defa sokulmaz. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, tövbe edenleri affeder. (Nur 31)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "İnsanların en hayırlısı, insanlara faydalı olandır. (Taberani)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Nisa 25)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, başkalarıyla iyi geçinir ve kendisiyle iyi geçinilir. (Taberani)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size olan nimetlerini hatırlayın. (Araf 69)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "İki günü eşit olan zarardadır. (Deylemi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatlidir. (Hadid 9)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, her durumda şükredendir. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok merhametlidir. (Nisa 29)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, güzel ahlakıyla gece ibadet eden, gündüz oruç tutan kimseye denk olur. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Ahzab 5)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, başkalarının kusurlarını araştırmaz. (Taberani)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatlidir. (Bakara 143)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, kendisi için istediğini başkası için de isteyendir. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok merhametlidir. (Nahl 7)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, her işinde Allah'ı hatırlayandır. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Nur 22)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'a güvenendir. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatlidir. (Hadid 28)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın verdiği her şeye razı olandır. (İbn Mace)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok merhametlidir. (Tevbe 117)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın emirlerine uyandır. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Nisa 110)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın yasaklarından kaçınandır. (Müslim)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatlidir. (Bakara 37)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın rızasını kazanmak için çalışandır. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok merhametlidir. (Nahl 18)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın verdiği nimetlere şükredendir. (İbn Mace)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Nur 31)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi helal yoldan kazanandır. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatlidir. (Ahzab 43)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi başkalarıyla paylaşandır. (Müslim)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok merhametlidir. (Bakara 178)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi doğru yolda kullanandır. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Nisa 25)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi yerli yerince kullanandır. (İbn Mace)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatlidir. (Hadid 9)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi başkalarının iyiliği için kullanandır. (Taberani)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok merhametlidir. (Nahl 7)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi doğru yolda harcayandır. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Ahzab 5)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi yerli yerince kullanandır. (Müslim)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatlidir. (Bakara 143)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi başkalarının iyiliği için kullanandır. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok merhametlidir. (Nahl 18)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi doğru yolda harcayandır. (İbn Mace)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Nur 22)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi yerli yerince kullanandır. (Taberani)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatlidir. (Hadid 28)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi başkalarının iyiliği için kullanandır. (Buhari)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok merhametlidir. (Tevbe 117)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi doğru yolda harcayandır. (Müslim)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Nisa 110)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi yerli yerince kullanandır. (Tirmizi)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok şefkatlidir. (Bakara 37)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi başkalarının iyiliği için kullanandır. (İbn Mace)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok merhametlidir. (Nahl 18)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi doğru yolda harcayandır. (Taberani)",
        'source': "Hadis-i Şerif"
      },
      {
        'text': "Allah, size karşı çok bağışlayıcıdır. (Nur 31)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Mümin, Allah'ın kendisine verdiği her şeyi yerli yerince kullanandır. (Buhari)",
        'source': "Hadis-i Şerif"
      },
    ];

    final randomVerse = verses[DateTime.now().second % verses.length];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          randomVerse['source'] as String,
          style: TextStyle(color: Colors.amber[300]),
        ),
        content: Text(
          randomVerse['text'] as String,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),

        ],
      ),
    );
  }
}