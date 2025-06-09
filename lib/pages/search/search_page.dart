import 'package:flutter/material.dart';

///
/// 搜索页面 (占位符)
///
class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索')),
      body: const Center(
        child: Text(
          '搜索页面',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 