import 'package:flutter/material.dart';
import 'package:selamkapisi/dashboard/components/daily_quote_banner.dart';
import 'dashboard/components/main_scaffold.dart';
import 'dashboard/components/personel_info_panel.dart';
import 'dashboard/components/preacher_section.dart';
import 'dashboard/components/qucik_access_buttons.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _currentIndex,

      body: SingleChildScrollView(
        child: Column(
          children: [
            DailyQuoteBanner(
              onAskQuestion: _showQuestionDialog,
              onShowSchedule: _showPreacherSchedule,
            ),
            PersonalInfoPanel(
              currentIndex: _currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            const QuickAccessButtons(),
            const PreachersSection(),
          ],
        ),
      ),
    );
  }

  void _showQuestionDialog() {
    // ... (Aynı dialog kodu)
  }

  void _showPreacherSchedule() {
    // ... (Aynı dialog kodu)
  }
}