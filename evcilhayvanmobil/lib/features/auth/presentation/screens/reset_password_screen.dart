// lib/features/auth/presentation/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});
  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        email: widget.email,
        code: _codeController.text,
        newPassword: _passwordController.text,
      );
      if (mounted) {
        context.goNamed('login');
        // TODO: Login ekranına "Şifre değişti" mesajı yolla
      }
    } catch (e) {
      setState(() { _errorMessage = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Şifre Belirle'),
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
                  '${widget.email} adresine gönderilen 6 haneli kodu ve yeni şifrenizi girin.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Doğrulama Kodu', border: OutlineInputBorder(), counterText: ""),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  validator: (value) => (value?.length != 6) ? 'Kod 6 haneli olmalı' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Yeni Şifre', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => ((value?.length ?? 0) < 6) ? 'Şifre min 6 karakter olmalı' : null,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Şifreyi Güncelle'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // --- ÇÖZÜM BİTTİ ---
    );
  }
}