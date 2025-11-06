// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';

import '../../domain/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final email = _emailController.text;
      final user = await authRepo.login(email, _passwordController.text);
      
      // --- GÜNCELLEME BURADA (KİLİTLENME HATASI ÇÖZÜMÜ) ---
      // SADECE state'i güncelle. Yönlendirmeyi 'ref.listen' yapacak.
      ref.read(authProvider.notifier).loginSuccess(user);
      // --- GÜNCELLEME BİTTİ ---

    } on VerificationRequiredException catch (e) {
      setState(() { _errorMessage = e.message; });
      if (mounted) context.pushNamed('verify-email', extra: e.email);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loginAsGuest() {
    context.goNamed('home');
  }

  void _goToRegister() {
    context.pushNamed('register');
  }

  void _goToForgotPassword() {
    context.pushNamed('forgot-password');
  }


  @override
  Widget build(BuildContext context) {
    // --- YENİ EKLENEN KISIM (STATE DİNLEYİCİ) ---
    // Bu, donma hatasını çözer.
    // authProvider'ı dinler.
    ref.listen<User?>(authProvider, (previous, next) {
      // Eğer state 'null' değilse (yani bir kullanıcıya dönüştüyse)
      if (next != null) {
        // Ana sayfaya ('/') git.
        // pushReplacementNamed kullanarak login ekranını yığından kaldır.
        context.pushReplacementNamed('home');
      }
    });
    // --- DİNLEYİCİ BİTTİ ---

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column( 
            children: [
              const SizedBox(height: 60),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _goToForgotPassword,
                        child: const Text('Şifremi Unuttum?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Giriş Yap', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60), 
              Column(
                children: [
                  const Text("veya"),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _loginAsGuest,
                      child: const Text('Misafir olarak giriş yap'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _goToRegister,
                    child: const Text('Hesabın yok mu? Üye Ol'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}