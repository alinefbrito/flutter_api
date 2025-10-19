import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_api/book.dart';
import 'package:flutter_api/villain_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Adicione este import

void main() {
  runApp( const MaterialApp (title: "App",
      home: MainApp(),));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool bookVisible = false;
  bool errorVisible = false;
  Book book = Book.empty();

  Future<void> getBook() async {
    try {
      Random random = Random();
      int randomId = random.nextInt(63) + 1;
      var url = 'https://stephen-king-api.onrender.com/api/book/$randomId';
      var response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // CORREÇÃO CRÍTICA: Extração segura do objeto aninhado "data"
        final Map<String, dynamic>? bookData = (responseData is Map<String, dynamic>) 
            ? responseData['data'] as Map<String, dynamic>? 
            : null;

        if (bookData != null) {
          book = Book.fromJson(bookData);
          setState(() {
            bookVisible = true;
            errorVisible = false;
          });
        } else {
          // Trata status 200, mas JSON malformado (sem "data")
          debugPrint("Erro de formato JSON: Chave 'data' faltando ou nula.");
          setState(() {
            bookVisible = false;
            errorVisible = true;
          });
        }
      } else {
        // Trata erros de status HTTP (e.g., 404, 500)
        setState(() {
          bookVisible = false;
          errorVisible = true;
        });
      }
    } catch (e) {
      // Captura erros de rede ou exceções durante jsonDecode/fromJson
      debugPrint('Erro na requisição ou processamento: $e');
      setState(() {
        bookVisible = false;
        errorVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Contraste melhorado: textos claros em fundo escuro
    final textStyle = const TextStyle(color: Colors.white, fontSize: 18);
    final labelStyle = const TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold);

    // Formatação de data no padrão brasileiro
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF181818),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Stephen King Books",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.red,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          centerTitle: true,
          elevation: 10,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: getBook,
                  icon: const Icon(Icons.menu_book_rounded, size: 28, color: Colors.white),
                  label: const Text('Buscar Livro'),
                ),
                const SizedBox(height: 32),
                // Exibição de Erro
                Visibility(
                  visible: errorVisible,
                  child: Column(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        "Falha na requisição. Tente novamente.",
                        style: labelStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Exibição do Livro
                Visibility(
                  visible: bookVisible,
                  child: Card(
                    color: Colors.grey[900],
                    elevation: 16,
                    shadowColor: Colors.red.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            book.title ?? 'Untitled',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text('Ano: ${book.year ?? 'N/A'}', style: textStyle),
                          Text('Editora: ${book.publisher}', style: textStyle),
                          Text('ISBN: ${book.isbn}', style: textStyle),
                          Text('Páginas: ${book.pages ?? 'N/A'}', style: textStyle),
                          const Divider(color: Colors.redAccent, height: 24),
                          Text(
                            'Notas: ${book.notes!.join(", ")}',
                            style: textStyle.copyWith(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.red[100]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Criado em: ${book.createdAt != null ? dateFormat.format(book.createdAt!) : "N/A"}', // <-- Aqui está a data formatada
                            style: textStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          // Vilões como links navegáveis para VillainPage (envia a URL via arguments)
                          book.villains!.isEmpty
                              ? Text('Vilões: Nenhum', style: textStyle.copyWith(fontSize: 16, color: Colors.redAccent))
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: <Widget>[
                                      Text('Vilões:', style: textStyle.copyWith(fontSize: 16, color: Colors.redAccent)),
                                      ...book.villains!.map((v) {
                                        final hasUrl = v.url != null && v.url!.isNotEmpty;
                                        return GestureDetector(
                                          onTap: hasUrl
                                              ? () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => const VillainPage(),
                                                      settings: RouteSettings(arguments: v.url),
                                                    ),
                                                  );
                                                }
                                              : null,
                                          child: MouseRegion(
                                            cursor: hasUrl ? SystemMouseCursors.click : SystemMouseCursors.basic,
                                            child: Text(
                                              v.name?? 'Unknown',
                                              style: textStyle.copyWith(
                                                fontSize: 16,
                                                color: hasUrl ? Colors.redAccent : Colors.white70,
                                                decoration: hasUrl ? TextDecoration.underline : TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}