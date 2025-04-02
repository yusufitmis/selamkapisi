import 'package:flutter/material.dart';

class SmartSuggestions extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Function(String) onSuggestionAction;

  const SmartSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: suggestions.map((suggestion) =>
          SuggestionCard(
            icon: suggestion['icon'],
            color: suggestion['color'],
            title: suggestion['title'],
            description: suggestion['description'],
            actionText: suggestion['action'],
            points: suggestion['points'],
            onPressed: () => onSuggestionAction(suggestion['title']),
          ),
      ).toList(),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String actionText;
  final String points;
  final VoidCallback onPressed;

  const SuggestionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.actionText,
    required this.points,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            _buildTextContent(),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildTextContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Column(
      children: [
        Text(
          points,
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(actionText),
        ),
      ],
    );
  }
}