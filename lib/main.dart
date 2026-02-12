import 'package:flutter/material.dart';
import 'package:lifevault/presentation/views/record_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const RecordListScreen(),
    );
  }
}
