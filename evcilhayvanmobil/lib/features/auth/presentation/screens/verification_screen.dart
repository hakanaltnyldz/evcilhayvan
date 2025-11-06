// lib/features/auth/presentation/screens/verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';

import '../../domain/user_model.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});
  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.verifyEmail(
        email: widget.email,
        code: _codeController.text,
      );
      ref.read(authProvider.notifier).loginSuccess(user);
    } catch (e) {
      setState(() { _errorMessage = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    ref.listen<User?>(authProvider, (previous, next) {
      if (next != null) { context.pushReplacementNamed('home'); }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabı Doğrula'),
      ),
      // --- ÇÖZÜM: SingleChildScrollView eklendi ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60), // Üstten boşluk
                Text(
                  '${widget.email} adresine gönderilen 6 haneli doğrulama kodunu girin.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Doğrulama Kodu', border: OutlineInputBorder(), counterText: ""),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 12),
                  validator: (value) => (value?.length != 6) ? 'Lütfen 6 haneli kodu girin' : null,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyCode,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Doğrula ve Giriş Yap', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () { /* TODO: Kodu tekrar gönder */ },
                  child: const Text('Kodu tekrar gönder'),
                ),
                const SizedBox(height: 60), // Alttan boşluk
              ],
            ),
          ),
        ),
      ),
      // --- ÇÖZÜM BİTTİ ---
    );
  }
}