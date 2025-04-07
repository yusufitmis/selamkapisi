import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selamkapisi/models/user_model.dart';
import 'package:selamkapisi/profile/settings_section.dart';
import '../dashboard/components/main_scaffold.dart';
import '../service/user_service.dart';
import 'package:url_launcher/url_launcher.dart'; // URL launch için import

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

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _displayNameController = TextEditingController();
    _loadUserData();
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

  // URL'yi açan fonksiyon
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'URL açılamıyor: $url';
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
                icon: Icon(isEditing ? Icons.save : Icons.edit, color: _secondaryColor),
                onPressed: () {
                  if (isEditing) {
                    _updateProfile();
                  }
                  setState(() => isEditing = !isEditing);
                },
              ),
            ],
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _secondaryColor.withAlpha((255 * 0.2).round()),
                    backgroundImage: (_user.photoUrl != null && _user.photoUrl!.isNotEmpty && Uri.parse(_user.photoUrl!).isAbsolute)
                        ? NetworkImage(_user.photoUrl!)
                        : const AssetImage('assets/images/default_profile.jpg'),
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
                              color: _textColor.withAlpha((255 * 0.7).round()),
                            )
                        ),
                        style: TextStyle(color: _textColor),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Lütfen ad soyad giriniz' : null,
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
                    style: TextStyle(color: _textColor.withAlpha((255 * 0.7).round())),
                  ),
                  SizedBox(height: 30, ),
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
                        Future.microtask(() {
                          if (mounted) {
                            Navigator.of(context).pushReplacementNamed('/login');
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                  ),

                  // Gizlilik sözleşmesi ve kullanım koşulları card'ları
                  const SizedBox(height: 30),
                  Card(
                    color: _cardColor,
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        'Gizlilik Sözleşmesi',
                        style: TextStyle(color: _textColor),
                      ),
                      onTap: () {
                        _launchURL('https://github.com/yusufitmis/selam_kapisi/blob/main/privacy-policy.md');
                      },
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
                      onTap: () {
                        _launchURL('https://github.com/yusufitmis/selam_kapisi/blob/main/terms-of-service.md');
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: \${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }
}
