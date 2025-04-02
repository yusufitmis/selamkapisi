import 'package:flutter/material.dart';
import 'package:selamkapisi/service/auth.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final String? title;
  final TextStyle? titleStyle;  // Added parameter
  final List<Widget>? actions;
  final bool showAppBar;
  final bool showBottomBar;

  const MainScaffold({
    super.key,
    required this.body,
    this.currentIndex = 0,
    this.title,
    this.titleStyle,  // Added parameter
    this.actions,
    this.showAppBar = true,
    this.showBottomBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final authMethods = AuthMethods();

    void _handleTabChange(int index) {
      if (currentIndex == index) return;

      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/dashboard');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/fatwa');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/coach');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/tasks');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: showAppBar
          ? AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        elevation: 0,
        title: title != null
            ? Text(title!, style: titleStyle)  // Apply titleStyle here
            : Container(
          alignment: Alignment.centerLeft,
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.amber,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/images/selam_kapisi_logo.png',
              height: 60,
            ),
          ),
        ),
        actions: [
          if (actions != null) ...actions!,
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.amber,
                size: 30,
              ),
              onPressed: () => authMethods.signOut(context),
            ),
          ),
        ],
      )
          : null,
      body: body,
      bottomNavigationBar: showBottomBar
          ? BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: currentIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: _handleTabChange,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Fetva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Koç',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      )
          : null,
    );
  }
}