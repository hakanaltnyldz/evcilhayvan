// lib/features/pets/domain/models/pet_model.dart

// PetOwner sınıfı (GÜNCELLENDİ)
class PetOwner {
  final String id;
  final String name; // Artık 'null' gelse bile hata vermeyecek
  final String? avatarUrl;

  PetOwner({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  // --- GÜNCELLEME: ÇÖKMEYİ ÖNLEYEN KONTROL ---
  factory PetOwner.fromJson(Map<String, dynamic> json) {
    return PetOwner(
      id: json['_id'],
      // 'name' alanı null veya boş gelirse, varsayılan bir değer ata
      name: json['name'] ?? 'Bilinmeyen Kullanıcı', 
      avatarUrl: json['avatarUrl'],
    );
  }
  // --- GÜNCELLEME BİTTİ ---
}

// Ana Pet modelimizi güncelliyoruz
class Pet {
  final String id;
  final PetOwner? owner;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final int ageMonths;
  final String? bio; // Opsiyonel
  final List<String> photos;
  final bool vaccinated;
  final Map<String, dynamic> location;
  final bool isActive;

  Pet({
    required this.id,
    this.owner,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.ageMonths,
    this.bio,
    required this.photos,
    required this.vaccinated,
    required this.location,
    required this.isActive,
  });

  // 'fromJson' metodu (Zaten güvenliydi, çökme PetOwner'daydı)
  factory Pet.fromJson(Map<String, dynamic> json) {
    
    final Map<String, dynamic> defaultLocation = {
      'type': 'Point',
      'coordinates': [0.0, 0.0]
    };

    return Pet(
      id: json['_id'],
      
      // Bu satır artık PetOwner.fromJson'daki düzeltme sayesinde güvende
      owner: json['ownerId'] != null ? PetOwner.fromJson(json['ownerId']) : null,
      
      name: json['name'],
      species: json['species'],
      breed: json['breed'] ?? 'Bilinmiyor', // 'breed' null gelirse (eski veri vb.)
      gender: json['gender'],
      photos: List<String>.from(json['photos'] ?? []), // 'photos' null gelirse
      ageMonths: json['ageMonths'],
      bio: json['bio'],
      vaccinated: json['vaccinated'],
      location: json['location'] ?? defaultLocation, // 'location' null gelirse
      isActive: json['isActive'],
    );
  }
}