
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_tick/theme/theme.dart';
import 'package:tick_tick/theme/theme_manager.dart';

import 'auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setPrefix('');
  final themeManager = ThemeManager();
  await themeManager.loadTheme();




  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeManager),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Login(),
    );
  }
}