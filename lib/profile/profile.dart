import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard/components/main_scaffold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  String displayName = '';
  int _currentIndex = 4; // Profil sayfası indexi

  @override
  void initState() {
    super.initState();
    displayName = user?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _currentIndex,

      title: 'Profilim',
      actions: [
        IconButton(
          icon: Icon(isEditing ? Icons.save : Icons.edit),
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
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            const SizedBox(height: 16),
            if (isEditing)
              Form(
                key: _formKey,
                child: TextFormField(
                  initialValue: displayName,
                  decoration: const InputDecoration(labelText: 'Ad Soyad'),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Lütfen ad soyad giriniz' : null,
                  onChanged: (value) => displayName = value,
                ),
              )
            else
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            const SizedBox(height: 8),
            Text(user?.email ?? 'Email yok'),
            const Divider(height: 32),
            const Text('İstatistikler', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            _buildStatCard('Günlük Namaz', '5/5'),
            _buildStatCard('Haftalık Kuran', '35 sayfa'),
            _buildStatCard('Aylık Sadaka', '150 TL'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
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
        const SnackBar(content: Text('Profil güncellendi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }
}