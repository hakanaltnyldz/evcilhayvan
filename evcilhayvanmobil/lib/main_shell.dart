import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  static const List<String> _routeNames = [
    'home', // 0: Sahiplen
    'connect', // 1: Bağlan
    'create-pet', // 2: Yeniden
    'mating', // 3: Çiftleştir
    'profile', // 4: Profil
  ];

  void _onItemTapped(int index, BuildContext context) {
    final currentUser = ref.read(authProvider);
    if (index == 2) return;

    if (currentUser == null && (index == 1 || index == 3 || index == 4)) {
      context.goNamed('login');
      return;
    }

    context.goNamed(_routeNames[index]);
  }

  void _updateCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/connect')) {
      _selectedIndex = 1;
    } else if (location.startsWith('/mating')) {
      _selectedIndex = 3;
    } else if (location.startsWith('/profile')) {
      _selectedIndex = 4;
    } else if (location == '/') {
      _selectedIndex = 0;
    } else {
      _selectedIndex = 0; // Varsayılan
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
            ? FloatingActionButton.extended(
                onPressed: () {
                  context.pushNamed('create-pet');
                },
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                icon: const Icon(Icons.add),
                label: const Text('Yeni İlan'),
                elevation: 6,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface.withOpacity(0.92),
                  theme.colorScheme.surfaceVariant.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  blurRadius: 26,
                  offset: const Offset(0, 16),
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
                    label: 'Yeniden', // boşluk için
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
