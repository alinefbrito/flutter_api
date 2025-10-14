// flutter_api/villain.dart
class Villain {
  final String name;

  Villain({required this.name});

  // Garante que o nome seja extraído e use um fallback se for null.
  Villain.fromJson(Map<String, dynamic> json)
      : name = (json['name'] as String?) ?? 'Vilão Desconhecido';
}