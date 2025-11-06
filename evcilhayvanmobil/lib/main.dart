// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:evcilhayvanmobil/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const seedColor = Color(0xFF7C6CFF);
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return MaterialApp.router(
      title: 'Evcil Hayvan App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: baseColorScheme.copyWith(
          surface: const Color(0xFFFDFBFF),
          surfaceVariant: const Color(0xFFF0ECFF),
          secondary: const Color(0xFFFF8FAB),
          secondaryContainer: const Color(0xFFFFD6E8),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F6FF),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: baseColorScheme.onSurface,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          centerTitle: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 2,
            shadowColor: baseColorScheme.primary.withOpacity(0.2),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: baseColorScheme.primary.withOpacity(0.08),
            foregroundColor: baseColorScheme.primary,
          ),
        ),
        cardTheme: CardTheme(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 10,
          shadowColor: baseColorScheme.primary.withOpacity(0.18),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: baseColorScheme.primary,
          contentTextStyle: TextStyle(
            color: baseColorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
          behavior: SnackBarBehavior.floating,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(
            color: baseColorScheme.onSurfaceVariant,
          ),
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF1F1A3D),
              displayColor: const Color(0xFF1F1A3D),
            ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      routerConfig: router,
    );
  }
}
