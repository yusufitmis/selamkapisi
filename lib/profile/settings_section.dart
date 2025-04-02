import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color secondaryColor;

  const SettingsSection({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Ayarlar',
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 16),
        _buildSettingSwitch(
          title: 'Bildirimler',
          value: true,
          onChanged: (v) {},
        ),
        _buildSettingSwitch(
          title: 'Sosyal Medya Bağlantıları',
          value: false,
          onChanged: (v) {},
        ),
        _buildSettingItem(
          title: 'Gizlilik Politikası',
          onTap: () {},
        ),
        _buildSettingItem(
          title: 'Veri Yönetimi',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(color: textColor)),
        value: value,
        onChanged: onChanged,
        activeColor: secondaryColor,
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: Icon(Icons.chevron_right, color: secondaryColor),
        onTap: onTap,
      ),
    );
  }
}