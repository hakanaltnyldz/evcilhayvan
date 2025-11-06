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
    final baseColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);

    return MaterialApp.router(
      title: 'Evcil Hayvan App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: baseColorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F9),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: baseColorScheme.onSurface,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: baseColorScheme.primary.withOpacity(0.2),
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF2D3142),
              displayColor: const Color(0xFF2D3142),
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
