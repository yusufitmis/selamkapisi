import 'package:flutter/material.dart';

class SocialMediaInterface extends StatefulWidget {
  final Color secondaryColor;
  final Color textColor;
  final Color cardColor;
  final Color primaryColor;
  final Color accentColor;
  final List<String> socialPlatforms;
  final String selectedPlatform;
  final String selectedContentType;
  final bool addNationalFlag;
  final bool scheduleForPrimeTime;
  final ValueChanged<String> onPlatformChanged;
  final ValueChanged<String> onContentTypeChanged;
  final ValueChanged<bool> onNationalFlagChanged;
  final ValueChanged<bool> onScheduleChanged;
  final VoidCallback onShareNow;
  final VoidCallback onSchedulePost;

  const SocialMediaInterface({
    super.key,
    required this.secondaryColor,
    required this.textColor,
    required this.cardColor,
    required this.primaryColor,
    required this.accentColor,
    required this.socialPlatforms,
    required this.selectedPlatform,
    required this.selectedContentType,
    required this.addNationalFlag,
    required this.scheduleForPrimeTime,
    required this.onPlatformChanged,
    required this.onContentTypeChanged,
    required this.onNationalFlagChanged,
    required this.onScheduleChanged,
    required this.onShareNow,
    required this.onSchedulePost,
  });

  @override
  State<SocialMediaInterface> createState() => _SocialMediaInterfaceState();
}

class _SocialMediaInterfaceState extends State<SocialMediaInterface> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: widget.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: widget.secondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Otomatik Paylaşım',
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.selectedPlatform,
              dropdownColor: widget.cardColor,
              items: widget.socialPlatforms.map((platform) =>
                  DropdownMenuItem<String>(
                    value: platform,
                    child: Text(
                      platform,
                      style: TextStyle(color: widget.textColor),
                    ),
                  )).toList(),
              onChanged: (value) => widget.onPlatformChanged(value!),
              decoration: InputDecoration(
                labelText: 'Platform Seçin',
                labelStyle: TextStyle(color: widget.textColor.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.secondaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.textColor.withOpacity(0.3)),
                ),
              ),
              style: TextStyle(color: widget.textColor),
              icon: Icon(Icons.arrow_drop_down, color: widget.secondaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'İçerik Türü:',
              style: TextStyle(
                color: widget.textColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Ayet', 'Hadis', 'Milli'].map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: widget.selectedContentType == type,
                  onSelected: (selected) {
                    widget.onContentTypeChanged(selected ? type : 'Ayet');
                  },
                  selectedColor: widget.secondaryColor,
                  backgroundColor: widget.cardColor,
                  labelStyle: TextStyle(
                    color: widget.selectedContentType == type ? widget.primaryColor : widget.textColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: widget.selectedContentType == type
                          ? widget.secondaryColor
                          : widget.textColor.withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildOptionSwitch(
                  value: widget.addNationalFlag,
                  onChanged: widget.onNationalFlagChanged,
                  icon: Icons.flag,
                  label: 'Bayrak Efekti',
                  secondaryColor: widget.secondaryColor,
                  textColor: widget.textColor,
                ),
                const Spacer(),
                _buildOptionSwitch(
                  value: widget.scheduleForPrimeTime,
                  onChanged: widget.onScheduleChanged,
                  icon: Icons.schedule,
                  label: 'Prime Time',
                  secondaryColor: widget.secondaryColor,
                  textColor: widget.textColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.send, color: widget.primaryColor),
                    label: Text(
                      'Şimdi Paylaş',
                      style: TextStyle(color: widget.primaryColor),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: widget.onShareNow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.schedule, color: widget.textColor),
                    label: Text('Planla', style: TextStyle(color: widget.textColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.secondaryColor.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: widget.secondaryColor),
                      ),
                    ),
                    onPressed: widget.onSchedulePost,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required String label,
    required Color secondaryColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: value ? secondaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? secondaryColor : textColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: value ? secondaryColor : textColor.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: value ? secondaryColor : textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}