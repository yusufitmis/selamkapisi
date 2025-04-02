import 'package:flutter/material.dart';
import 'package:selamkapisi/dashboard/components/main_scaffold.dart';
import 'package:selamkapisi/fatwa/preacher_tab/preachers_tab.dart';
import 'fatwa_tab/fatwa_tab.dart';

class FatwaPage extends StatefulWidget {
  const FatwaPage({super.key});

  @override
  State<FatwaPage> createState() => _FatwaPageState();
}

class _FatwaPageState extends State<FatwaPage> {
  int _currentIndex = 1;
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _currentIndex,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => setState(() {}),
        ),
      ],
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTab == 0
                ? const FatwaTab()
                : const PreachersTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 48,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Fetva Sor'),
                ),
              ),
              ButtonSegment(
                value: 1,
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Vaizler'),
                ),
              ),
            ],
            selected: {_selectedTab},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() => _selectedTab = newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              selectedBackgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
              selectedForegroundColor: Colors.black,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}