// ignore_for_file: strict_top_level_inference


import 'package:flutter_api/book.dart';
class Villain {
   String? name;
   String? url;
   int? id;
   String? gender;
   String? status;
   int? typesId;
   List<String>? notes;
   DateTime? createdAt;
   List<Book>? books;
   List<String>? shorts;

  Villain(url, id, gender, status, typesId, notes, createdAt, books, shorts,  name);

Villain.url(nome,link)
{
  id = null;
  name = nome;
  url = link;
  gender = null;
  status = null; 
  typesId = null;
  notes = [];
  createdAt = DateTime.now();
  books = [];
  shorts = [];
  
}

  Villain.empty()
  {
    id = null;
  name = '';
  url = '';
  gender = null;
  status = null; 
  typesId = null;
  notes = [];
  createdAt = DateTime.now();
  books = [];
  shorts = [];   

  }
      
      
Villain.fromJsonNameUrl(Map<String, dynamic> json): 
        name = (json['name'] as String?) ?? 'Vilão Desconhecido',
        url = (json['url'] as String?) ?? (json['link'] as String?);


  // Garante que o nome e demais campos sejam extraídos e trata nulos de forma segura.
  Villain.fromJson(Map<String, dynamic> json)
      : id = json['id'] is int
            ? json['id'] as int
            : (json['id'] is String ? int.tryParse(json['id'] as String) : null),
        name = (json['name'] as String?) ?? 'Vilão Desconhecido',
        url = (json['url'] as String?) ?? (json['link'] as String?),
        gender = (json['gender'] as String?),
        status = (json['status'] as String?),
        typesId = json['types_id'] is int
            ? json['types_id'] as int
            : (json['types_id'] is String
                ? int.tryParse(json['types_id'] as String)
                : (json['typesId'] is int
                    ? json['typesId'] as int
                    : (json['typesId'] is String ? int.tryParse(json['typesId'] as String) : null))),
        notes = (json['notes'] is List) ? List<String>.from(json['notes']) : <String>[],
        createdAt = (json['created_at'] != null)
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        books = (json['books'] is List)
            ? (json['books'] as List).map((b) {
                if (b is Map<String, dynamic>) {
                  try {
                    return Book.fromJsonResumido(b);
                  } catch (_) {
                    return Book.empty();
                  }
                }
                return Book.empty();
              }).toList()
            : <Book>[],
        shorts = (json['shorts'] is List) ? List<String>.from(json['shorts']) : <String>[];
}