import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/routers/app_router.dart';


void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return MaterialApp.router(
      routerConfig: appRouter.config(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff909090),
          brightness: Brightness.light,
          secondary: const Color(0xff00599A),
        ),
        checkboxTheme: CheckboxThemeData(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xff585858)),
            borderRadius: BorderRadiusGeometry.circular(3),
          ),
        ),
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            fontFamily: 'FiraSans',
            color: Color(0xff000000),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: Color(0xff8A8A8A), fontSize: 11),
          titleSmall: TextStyle(
            fontFamily: 'FiraSans',
            color: Color(0xff585858),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
