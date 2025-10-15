import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/main_scaffold.dart';
import 'core/auth/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthState.I.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buscadog',
      theme: AppTheme.light, // Tema centralizado
      home: const MainScaffold(), // Shell con BottomNav + IndexedStack
    );
  }
}
