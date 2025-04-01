import 'package:flutter/material.dart';

import '../dashboard/components/main_scaffold.dart';

class FatwaPage extends StatefulWidget {
  const FatwaPage({super.key});

  @override
  State<FatwaPage> createState() => _FatwaPageState();
}

class _FatwaPageState extends State<FatwaPage> {
  List<String> fatwaList = [];
  bool isLoading = true;
  String searchQuery = '';
  int _currentIndex = 1; // Fetva sayfası indexi

  @override
  void initState() {
    super.initState();
    _fetchFetvas();
  }

  Future<void> _fetchFetvas() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      fatwaList = [
        'Namaz kılarken okunacak dualar',
        'Oruç tutarken dikkat edilecekler',
        'Zekat hesaplama yöntemleri',
        'Hac ibadeti ile ilgili sorular'
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredFetvas = fatwaList.where((fetva) =>
        fetva.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();

    return MainScaffold(
      currentIndex: _currentIndex,

      title: 'Fetva Soru-Cevap',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _fetchFetvas,
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Fetva ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredFetvas.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: const Icon(Icons.library_books),
                    title: Text(filteredFetvas[index]),
                    onTap: () {
                      // Fetva detay sayfasına git
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}