import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeView(),
    );
  }
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Arch Lint Example'),
      ),
      body: const Center(
        child: Text('Hello, Clean Arch Lint!'),
      ),
    );
  }
}
