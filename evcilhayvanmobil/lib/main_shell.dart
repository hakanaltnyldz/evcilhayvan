import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';
import 'package:evcilhayvanmobil/core/theme/app_palette.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  static const List<String?> _routeNames = [
    'messages', // 0: Sohbetler
    'home', // 1: Sahiplen
    'connect', // 2: Bağlan
    null, // 3: Yeni ilan (FAB)
    'mating', // 4: Çiftleştir
    'profile', // 5: Profil
  ];

  void _onItemTapped(int index, BuildContext context) {
    final currentUser = ref.read(authProvider);
    final targetRoute = _routeNames[index];

    if (targetRoute == null) {
      return;
    }

    if (currentUser == null && (index == 0 || index == 2 || index == 4 || index == 5)) {
      context.goNamed('login');
      return;
    }

    context.goNamed(targetRoute);
  }

  void _updateCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/messages')) {
      _selectedIndex = 0;
    } else if (location.startsWith('/connect')) {
      _selectedIndex = 2;
    } else if (location.startsWith('/mating')) {
      _selectedIndex = 4;
    } else if (location.startsWith('/profile')) {
      _selectedIndex = 5;
    } else if (location == '/') {
      _selectedIndex = 1;
    } else {
      _selectedIndex = 1; // Varsayılan Sahiplen
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateCurrentIndex(context);
    final currentUser = ref.watch(authProvider);
    final theme = Theme.of(context);

    return SafeArea( // ✅ taşma önleyen katman
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 🔧 alt taşma uyarılarını da susturur
        body: widget.child,
        floatingActionButton: (currentUser != null)
            ? DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppPalette.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.secondary.withOpacity(0.32),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    context.pushNamed('create-pet');
                  },
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni İlan'),
                  elevation: 0,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppPalette.background.withOpacity(0.94),
                  theme.colorScheme.surfaceVariant.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: _selectedIndex,
                onTap: (index) => _onItemTapped(index, context),
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurfaceVariant,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline),
                    activeIcon: Icon(Icons.chat_bubble),
                    label: 'Sohbetler',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.pets_outlined),
                    activeIcon: Icon(Icons.pets),
                    label: 'Sahiplen',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_alt_outlined),
                    activeIcon: Icon(Icons.people_alt),
                    label: 'Bağlan',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add, color: Colors.transparent),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    activeIcon: Icon(Icons.favorite),
                    label: 'Çiftleştir',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
