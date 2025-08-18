import 'package:flutter/material.dart';
import 'package:vision_x_flutter/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vision X',
      theme: ThemeData(
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}