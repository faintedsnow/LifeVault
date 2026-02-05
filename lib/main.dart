import 'package:flutter/material.dart';

void main() {
  runApp(const LifeVaultApp());
}

class LifeVaultApp extends StatelessWidget {
  const LifeVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const Scaffold(
        body: Center(child: Text('LifeVault', style: TextStyle(fontSize: 24))),
      ),
    );
  }
}
