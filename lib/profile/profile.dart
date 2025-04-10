import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:selamkapisi/models/user_model.dart';
import 'package:selamkapisi/profile/settings_section.dart';
import '../dashboard/components/main_scaffold.dart';
import '../google_ads.dart';
import '../service/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _secondaryColor = const Color(0xFFD4AF37);
  final Color _textColor = Colors.white;
  final Color _cardColor = const Color(0xFF1E1E1E);

  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late UserService _userService;
  late UserModel _user;
  final GoogleAds googleAds = GoogleAds();


  @override
  void dispose() {
    googleAds.bannerAd?.dispose();
    googleAds.interstitialAd?.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _displayNameController = TextEditingController();
    _loadUserData();
    googleAds.loadInterstitialAd();
    googleAds.loadBannerAd(adLoaded: () {
      setState(() {

      });
    },);
  }

  Future<void> _loadUserData() async {
    _user = await _userService.getUserData();
    _displayNameController.text = _user.displayName ?? '';
    setState(() {});
  }

  String _getTitleBasedOnScore() {
    if (_user.totalScore > 2000) return 'Sen bir İslam Savaşçısısın!';
    if (_user.totalScore > 1000) return 'Mücahid Kardeşimiz';
    return 'İman Yolcusu';
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _userService.updateProfile(
          _displayNameController.text,
          _user.photoUrl,
        );
        await _loadUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil güncellendi'),
              backgroundColor: _secondaryColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // URL açmak için güvenli yöntem
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank', // For web
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open $url")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening URL: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _showAdThenLaunchURL(String url) async {
    if (googleAds.interstitialAd != null) {
      googleAds.interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              googleAds.loadInterstitialAd(); // Reklamı tekrar yükle
              _launchURL(url); // Reklam kapandıktan sonra URL'yi aç
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              googleAds.loadInterstitialAd(); // Hata olursa tekrar yükle
              _launchURL(url); // Yine de URL’yi aç
            },
          );

      googleAds.interstitialAd!.show();
      googleAds.interstitialAd = null;
    } else {
      // Eğer reklam yoksa direkt URL'yi aç
      _launchURL(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _userService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _user = snapshot.data!;
          _displayNameController.text = _user.displayName ?? '';

          return MainScaffold(
            currentIndex: 3,
            title: 'Profilim',
            titleStyle: TextStyle(color: _textColor),
            actions: [
              IconButton(
                icon: Icon(
                  isEditing ? Icons.save : Icons.edit,
                  color: _secondaryColor,
                ),
                onPressed: () async {
                  if (isEditing) {
                    _updateProfile();
                    setState(() => isEditing = false);
                  } else {
                    if (googleAds.interstitialAd != null) {
                      googleAds.interstitialAd!.fullScreenContentCallback =
                          FullScreenContentCallback(
                            onAdDismissedFullScreenContent: (ad) {
                              ad.dispose();
                              googleAds.loadInterstitialAd();
                              setState(() => isEditing = true); // Reklamdan sonra düzenleme moduna geç
                            },
                            onAdFailedToShowFullScreenContent: (ad, error) {
                              ad.dispose();
                              googleAds.loadInterstitialAd();
                              setState(() => isEditing = true);
                            },
                          );
                      googleAds.interstitialAd!.show();
                      googleAds.interstitialAd = null;
                    } else {
                      // Reklam hazır değilse doğrudan düzenleme moduna geç
                      setState(() => isEditing = true);
                    }
                  }
                },

              ),
            ],
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _secondaryColor.withOpacity(0.2),
                    backgroundImage: (_user.photoUrl != null &&
                        _user.photoUrl!.isNotEmpty &&
                        Uri.tryParse(_user.photoUrl!)?.isAbsolute == true)
                        ? NetworkImage(_user.photoUrl!)
                        : const AssetImage('assets/images/default_profile.jpg')
                    as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getTitleBasedOnScore(),
                    style: TextStyle(
                      color: _secondaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isEditing)
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: 'Ad Soyad',
                          labelStyle: TextStyle(
                            color: _textColor.withOpacity(0.7),
                          ),
                        ),
                        style: TextStyle(color: _textColor),
                        validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Lütfen ad soyad giriniz'
                            : null,
                      ),
                    )
                  else
                    Text(
                      _user.displayName ?? 'Misafir',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _user.email ?? 'Email yok',
                    style: TextStyle(color: _textColor.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 30),
                  const Divider(height: 32, color: Colors.grey),

                  SettingsSection(
                    cardColor: _cardColor,
                    textColor: _textColor,
                    secondaryColor: _secondaryColor,
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.of(context)
                            .pushReplacementNamed('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Gizlilik sözleşmesi ve kullanım koşulları
                  Card(
                    color: _cardColor,
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        'Gizlilik Sözleşmesi',
                        style: TextStyle(color: _textColor),
                      ),
                      onTap: () => _showAdThenLaunchURL(
                        'https://github.com/yusufitmis/selam_kapisi/blob/main/privacy-policy.md',
                      ),

                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: _cardColor,
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        'Kullanım Koşulları',
                        style: TextStyle(color: _textColor),
                      ),
                      onTap: () => _showAdThenLaunchURL(
                        'https://github.com/yusufitmis/selam_kapisi/blob/main/terms-of-service.md',
                      ),

                    ),
                  ),
                  SizedBox(height:120),
                  if (googleAds.bannerAd != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade300, Colors.amber.shade700], // Altın renkli degrade arka plan
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16), // Yuvarlatılmış köşeler
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4), // Gölgeli 3D etkisi
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey, // Koyu altın rengi border
                          width: 3, // Daha belirgin border
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12), // Padding değerini arttırdım
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 15), // Üst ve alt margin
                      child: SizedBox(
                        width: googleAds.bannerAd!.size.width.toDouble(),
                        height: googleAds.bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: googleAds.bannerAd!),
                      ),
                    ),
                ],

              ),

            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }


}
