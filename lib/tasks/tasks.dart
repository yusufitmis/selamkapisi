import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../dashboard/components/main_scaffold.dart';
import 'components/header_section.dart';
import 'components/social_media_interface.dart';
import 'components/social_task.dart';
import 'components/task_card.dart';
import 'components/reward_dialog.dart';
import 'components/faith_message_dialog.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // Color Scheme
  final Color _primaryColor = const Color(0xFF121212); // Dark background
  final Color _secondaryColor = const Color(0xFFD4AF37); // Gold
  final Color _accentColor = const Color(0xFF64B5F6); // Light blue
  final Color _textColor = Colors.white;
  final Color _cardColor = const Color(0xFF1E1E1E);

  // Social Media Integration
  final List<String> _socialPlatforms = ['Twitter', 'Instagram', 'Telegram'];
  String _selectedPlatform = 'Twitter';
  bool _addNationalFlag = true;
  bool _scheduleForPrimeTime = false;
  DateTime? _scheduledTime;
  String _selectedContentType = 'Ayet'; // 'Ayet', 'Hadis', 'Milli'

  // Task System
  List<SocialTask> tasks = [
    SocialTask('10 Ayet Paylaş', 0, 10, reward: 'Sinema Bileti', rewardImage: 'assets/rewards/cinema_ticket.png'),
    SocialTask('5 Hadis Paylaş', 0, 5, reward: 'Kitap Hediye Çeki', isVip: true, rewardImage: 'assets/rewards/gift_card.png'),
    SocialTask('3 Milli Paylaşım', 0, 3, reward: 'Kültür Gezisi', rewardImage: 'assets/rewards/culture_tour.png'),
  ];

  // Content Pools
  final List<String> _versePool = [];
  final List<String> _hadithPool = [];
  final List<String> _nationalContentPool = [];

  @override
  void initState() {
    super.initState();
    _initializeContentPools();
  }

  void _initializeContentPools() {
    _versePool.addAll(List.generate(1000, (i) => "📖 Ayet ${i+1}: \"...\" #İslam #Kuran"));
    _hadithPool.addAll(List.generate(1000, (i) => "🕌 Hadis ${i+1}: \"...\" #Sünnet #Peygamber"));
    _nationalContentPool.addAll(List.generate(1000, (i) => "🇹🇷 Milli İçerik ${i+1}: \"...\" #Türkiye #MilliDuygu"));
  }

  DateTime _calculatePrimeTime() {
    final now = DateTime.now();
    // Set prime time to 8 PM today
    return DateTime(now.year, now.month, now.day, 20, 0);
  }

  Future<void> _shareNow() async {
    final content = _getRandomContent();
    await Share.share(content);

    // Update task progress
    setState(() {
      for (var task in tasks) {
        if (_selectedContentType == 'Ayet' && task.title.contains('Ayet')) {
          task.completed++;
        } else if (_selectedContentType == 'Hadis' && task.title.contains('Hadis')) {
          task.completed++;
        } else if (_selectedContentType == 'Milli' && task.title.contains('Milli')) {
          task.completed++;
        }
      }
    });
  }

  void _schedulePost() {
    final content = _getRandomContent();
    final time = _scheduleForPrimeTime ? _calculatePrimeTime() : DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text('Paylaşım Planlandı', style: TextStyle(color: _textColor)),
        content: Text('"${content.substring(0, 20)}..." içeriği $_selectedPlatform için planlandı: ${time.hour}:${time.minute}',
            style: TextStyle(color: _textColor.withOpacity(0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('TAMAM', style: TextStyle(color: _secondaryColor)),
          ),
        ],
      ),
    );
  }

  String _getRandomContent() {
    String content = '';
    final random = DateTime.now().millisecond;

    if (_selectedContentType == 'Ayet') {
      content = _versePool[random % _versePool.length];
    } else if (_selectedContentType == 'Hadis') {
      content = _hadithPool[random % _hadithPool.length];
    } else {
      content = _nationalContentPool[random % _nationalContentPool.length];
    }

    if (_addNationalFlag) {
      content += ' 🇹🇷';
    }

    return content;
  }

  void _showReward(SocialTask task) {
    showDialog(
      context: context,
      builder: (context) => RewardDialog(
        task: task,
        cardColor: _cardColor,
        secondaryColor: _secondaryColor,
        textColor: _textColor,
        primaryColor: _primaryColor,
      ),
    );
  }

  void _showFaithMessage() {
    showDialog(
      context: context,
      builder: (context) => FaithMessageDialog(
        cardColor: _cardColor,
        secondaryColor: _secondaryColor,
        textColor: _textColor,
        primaryColor: _primaryColor,
        onSharePressed: _shareNow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((t) => t.completed >= t.target).length;
    final totalProgress = tasks.isEmpty ? 0.0 :
    tasks.fold(0.0, (sum, task) => sum + task.progress) / tasks.length;

    return MainScaffold(
      currentIndex: 3,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderSection(
              completedTasks: completedTasks,
              totalTasks: tasks.length,
              totalProgress: totalProgress,
              primaryColor: _primaryColor,
              secondaryColor: _secondaryColor,
              textColor: _textColor,
              cardColor: _cardColor,
              onFaithMessagePressed: _showFaithMessage,
            ),
            SocialMediaInterface(
              secondaryColor: _secondaryColor,
              textColor: _textColor,
              cardColor: _cardColor,
              primaryColor: _primaryColor,
              accentColor: _accentColor,
              socialPlatforms: _socialPlatforms,
              selectedPlatform: _selectedPlatform,
              selectedContentType: _selectedContentType,
              addNationalFlag: _addNationalFlag,
              scheduleForPrimeTime: _scheduleForPrimeTime,
              onPlatformChanged: (value) => setState(() => _selectedPlatform = value),
              onContentTypeChanged: (value) => setState(() => _selectedContentType = value),
              onNationalFlagChanged: (value) => setState(() => _addNationalFlag = value),
              onScheduleChanged: (value) => setState(() {
                _scheduleForPrimeTime = value;
                if (value) _scheduledTime = _calculatePrimeTime();
              }),
              onShareNow: _shareNow,
              onSchedulePost: _schedulePost,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) => TaskCard(
                task: tasks[index],
                primaryColor: _primaryColor,
                secondaryColor: _secondaryColor,
                textColor: _textColor,
                accentColor: _accentColor,
                cardColor: _cardColor,
                onTap: () => _showReward(tasks[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}