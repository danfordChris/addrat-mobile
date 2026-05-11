import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pesa_lending/services/database_manager.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/shared/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseManager.init();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(
    MultiProvider(
      providers: providers,
      child: const PesaApp(),
    ),
  );
}

class PesaApp extends StatelessWidget {
  const PesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child:




      MaterialApp.router(
      title: 'Pesa Lending',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(context)
              .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2),
        ),
        child: child!,
      ),
    ));
  }
}
