// lib/features/messages/data/repositories/message_repository.dart

import 'package:dio/dio.dart';
import 'package:evcilhayvanmobil/core/http.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../domain/models/conservation.model.dart';
import '../../domain/models/message_model.dart'; // authProvider için

// 1. MessageRepository Provider'ı
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final dio = HttpClient().dio;
  return MessageRepository(dio);
});

// 2. Mesaj Listesi Provider'ı (Sohbet Odası Listesi)
final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final repo = ref.watch(messageRepositoryProvider);
  final currentUser = ref.watch(authProvider); // Kullanıcı ID'sini almak için
  
  // Kullanıcı giriş yapmamışsa listeyi çekme (güvenlik)
  if (currentUser == null) return [];

  return repo.getMyConversations(currentUser.id);
});

// 3. Tek Bir Sohbetin Mesajları Provider'ı
final messagesProvider = FutureProvider.autoDispose.family<List<Message>, String>((ref, conversationId) async {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.getMessages(conversationId);
});


// 4. Repository Sınıfı
class MessageRepository {
  final Dio _dio;
  MessageRepository(this._dio);

  // Sohbete ait tüm mesajları getir
  Future<List<Conversation>> getMyConversations(String currentUserId) async {
    try {
      final response = await _dio.get('/api/conversations/me');
      final List<dynamic> jsonList = response.data['conversations'];
      
      // Her bir sohbeti modelimize çevirirken currentUserId'yi yolluyoruz
      // ki 'otherParticipant'ı doğru bulabilelim.
      return jsonList.map((json) => Conversation.fromJson(json, currentUserId)).toList();

    } on DioException catch (e) {
      print('Error fetching conversations: $e');
      throw Exception('Sohbet listesi alınamadı: ${e.response?.data['message']}');
    }
  }

  // Belirli bir sohbetteki mesajları getir
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await _dio.get('/api/conversations/$conversationId');
      final List<dynamic> jsonList = response.data['messages'];
      return jsonList.map((json) => Message.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Mesajlar alınamadı: ${e.response?.data['message']}');
    }
  }

  // Yeni mesaj gönder
  Future<Message> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        '/api/conversations/$conversationId',
        data: { 'text': text },
      );
      return Message.fromJson(response.data['message']);
    } on DioException catch (e) {
      throw Exception('Mesaj gönderilemedi: ${e.response?.data['message']}');
    }
  }
}