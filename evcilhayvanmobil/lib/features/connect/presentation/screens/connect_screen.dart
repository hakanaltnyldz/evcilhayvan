// lib/features/connect/presentation/screens/connect_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evcilhayvanmobil/core/http.dart'; // apiBaseUrl için

class ConnectScreen extends ConsumerWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Yeni 'allUsersProvider'ımızı izle
    final usersAsyncValue = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bağlan'),
      ),
      // 2. 'when' ile 3 durumu da yönet (yükleniyor, veri, hata)
      body: usersAsyncValue.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('Görünüşe göre senden başka kimse yok.'));
          }
          
          // 3. Kullanıcıları ListView.builder ile listele
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              
              // 4. İlham görselindeki gibi bir kart oluştur
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Profil Fotoğrafı
                      CircleAvatar(
                        radius: 30,
                        child: (user.avatarUrl != null)
                          ? ClipOval( 
                              child: CachedNetworkImage(
                                imageUrl: '${apiBaseUrl}${user.avatarUrl}', 
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.person),
                                fit: BoxFit.cover, width: 60, height: 60,
                              ),
                            )
                          : Text( 
                              user.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 24),
                            ),
                      ),
                      const SizedBox(width: 16),
                      
                      // İsim ve Şehir
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                            Text(user.city ?? 'Şehir belirtilmemiş'),
                            // TODO: 'Joined' tarihi eklenebilir
                          ],
                        ),
                      ),
                      
                      // Sohbet Butonu
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Mesajlaşma ekranına yönlendir
                          // context.pushNamed('chat', extra: user.id);
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Sohbet'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          // Bu, genellikle 401 (token yok/geçersiz) hatasıdır
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Kullanıcıları yüklemek için giriş yapmalısınız.\n\n($error)',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}