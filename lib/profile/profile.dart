import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selamkapisi/profile/profile_stats.dart';
import 'package:selamkapisi/profile/settings_section.dart';
import 'package:selamkapisi/profile/stat_card.dart';
import '../dashboard/components/main_scaffold.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Color Scheme
  final Color _primaryColor = const Color(0xFF121212); // Dark background
  final Color _secondaryColor = const Color(0xFFD4AF37); // Gold
  final Color _accentColor = const Color(0xFF64B5F6); // Light blue
  final Color _textColor = Colors.white;
  final Color _cardColor = const Color(0xFF1E1E1E);

  final user = FirebaseAuth.instance.currentUser;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  String displayName = '';
  final ProfileStats _stats = ProfileStats(
    prayerCount: 5,
    quranPages: 35,
    charityAmount: 150,
    socialPoints: 1200,
    totalScore: 2500,
  );

  @override
  void initState() {
    super.initState();
    displayName = user?.displayName ?? '';
  }

  String _getTitleBasedOnScore() {
    if (_stats.totalScore > 2000) return 'Sen bir İslam Savaşçısısın!';
    if (_stats.totalScore > 1000) return 'Mücahid Kardeşimiz';
    return 'İman Yolcusu';
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 4,
      title: 'Profilim',
      titleStyle: TextStyle(color: _textColor),
      actions: [
        IconButton(
          icon: Icon(isEditing ? Icons.save : Icons.edit, color: _secondaryColor),
          onPressed: () {
            if (isEditing) {
              final formState = _formKey.currentState;
              if (formState != null && formState.validate()) {
                _updateProfile();
              }
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
              backgroundColor: _secondaryColor.withOpacity(0.2),
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
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
                  initialValue: displayName,
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad',
                    labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _secondaryColor),
                    ),
                  ),
                  style: TextStyle(color: _textColor),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Lütfen ad soyad giriniz' : null,
                  onChanged: (value) => displayName = value,
                ),
              )
            else
              Text(
                displayName,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'Email yok',
              style: TextStyle(color: _textColor.withOpacity(0.7)),
            ),
            const Divider(height: 32, color: Colors.grey),
            Text(
              'İstatistikler',
              style: TextStyle(
                color: _textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StatCard(
              title: 'Günlük Namaz',
              value: '${_stats.prayerCount}/5',
              backgroundColor: _cardColor,
              textColor: _textColor,
            ),
            StatCard(
              title: 'Haftalık Kuran',
              value: '${_stats.quranPages} sayfa',
              backgroundColor: _cardColor,
              textColor: _textColor,
            ),
            StatCard(
              title: 'Aylık Sadaka',
              value: '${_stats.charityAmount} TL',
              backgroundColor: _cardColor,
              textColor: _textColor,
            ),
            StatCard(
              title: 'Sosyal Puan',
              value: _stats.socialPoints.toString(),
              backgroundColor: _cardColor,
              textColor: _textColor,
            ),
            StatCard(
              title: 'Toplam Sevap Puanı',
              value: _stats.totalScore.toString(),
              backgroundColor: _secondaryColor.withOpacity(0.2),
              textColor: _secondaryColor,
            ),
            SettingsSection(
              cardColor: _cardColor,
              textColor: _textColor,
              secondaryColor: _secondaryColor,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Çıkış Yap',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    try {
      await user?.updateDisplayName(displayName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil güncellendi'),
          backgroundColor: _secondaryColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }
}