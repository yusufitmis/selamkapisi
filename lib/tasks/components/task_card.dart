import 'package:flutter/material.dart';
import 'package:selamkapisi/tasks/components/social_task.dart';

class TaskCard extends StatelessWidget {
  final SocialTask task;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color accentColor;
  final Color cardColor;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.accentColor,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (task.isVip)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: secondaryColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: secondaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'VIP',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${task.completed}/${task.target}',
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: task.progress,
                backgroundColor: primaryColor,
                color: task.isVip ? secondaryColor : accentColor,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.card_giftcard, size: 16, color: secondaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Ödül: ${task.reward}',
                    style: TextStyle(color: textColor.withOpacity(0.8)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: secondaryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${task.target - task.completed} kaldı',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}