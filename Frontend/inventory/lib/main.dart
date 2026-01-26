import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/api/http_override.dart';
import 'package:inventory/routers/app_router.dart';





void main() {
  HttpOverrides.global = MyHttpOverrides(); //allow localhost HTTPS
  runApp(const ProviderScope(child: MainApp()));
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
        inputDecorationTheme: const InputDecorationTheme(
  hintStyle: TextStyle(
    fontSize: 11, //  same as your label size
    fontWeight: FontWeight.w400,
    color: Color(0xff909090), // light grey like figma
  ),
  labelStyle: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Color(0xff909090),
  ),
),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff909090),
          brightness: Brightness.light,
          primary: const Color.fromARGB(100, 144, 144, 144),
          secondary: const Color(0xff00599A),
        ),
        
        //
         outlinedButtonTheme: OutlinedButtonThemeData(
  style: ButtonStyle(
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 18),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    side: const WidgetStatePropertyAll(
      BorderSide(color: Color(0xff909090)), // looks like figma
    ),

    // text color
    foregroundColor: const WidgetStatePropertyAll(
      Color(0xffBDBDBD), // light grey text like screenshot
    ),

    textStyle: const WidgetStatePropertyAll(
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ButtonStyle(
    shadowColor: const WidgetStatePropertyAll(Colors.transparent),

    // button bg
    backgroundColor: const WidgetStatePropertyAll(Color(0xff00599A)),

    // text + icon color
    foregroundColor: const WidgetStatePropertyAll(Colors.white),

    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
),

 
        //

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

