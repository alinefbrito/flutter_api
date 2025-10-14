// flutter_api/book.dart
import 'package:flutter_api/villain.dart';

class Book {
  // Campos anuláveis (podem ser null)
  final int? id;
  final int? year;
  final int? pages;

  // Campos não-anuláveis (sempre terão um valor, com fallback no fromJson)
  final String title;
  final String handle;
  final String publisher;
  final String isbn;
  final List<String> notes;
  final DateTime createdAt;
  final List<Villain> villains;

  Book({
    this.id,
    this.year,
    required this.title,
    required this.handle,
    required this.publisher,
    required this.isbn,
    this.pages,
    required this.notes,
    required this.createdAt,
    required this.villains,
  });

  // Construtor Book.empty() para inicialização segura
  Book.empty()
      : id = 0,
        year = 0,
        title = '',
        handle = '',
        publisher = '',
        isbn = '',
        pages = 0,
        notes = const [],
        createdAt = DateTime.now(),
        villains = const [];

  // Construtor ajustado para leitura do JSON (espera o MAP do livro, não o JSON completo)
  Book.fromJson(Map<String, dynamic> data)
      : id = data['id'] as int?,
        year = data['Year'] as int?,
        title = (data['Title'] as String?) ?? '',
        handle = (data['handle'] as String?) ?? '',
        
        // CORREÇÃO CRÍTICA: Mapeamento invertido de Publisher e ISBN
        publisher = (data['Publisher'] as String?) ?? '', 
        isbn = (data['ISBN'] as String?) ?? '', 
        
        pages = data['Pages'] as int?,
        notes = (data['Notes'] is List)
            ? List<String>.from(data['Notes'])
            : <String>[],
        createdAt = (data['created_at'] != null)
            ? DateTime.parse(data['created_at'])
            : DateTime.now(),
        villains = (data['villains'] is List)
            ? (data['villains'] as List)
                .map((v) => Villain.fromJson(v as Map<String, dynamic>))
                .toList()
            : <Villain>[];
}