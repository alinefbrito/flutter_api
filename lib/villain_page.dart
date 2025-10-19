import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'villain.dart';

class VillainPage extends StatefulWidget {
  const VillainPage({super.key});

  @override
  State<VillainPage> createState() => _VillainPageState();
}

class _VillainPageState extends State<VillainPage> {
  Villain? villain = Villain.empty();
  final textStyle = const TextStyle(color: Colors.white, fontSize: 16);
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  // Novos estados para controlar visibilidade
  bool _loading = false;
  bool _hasError = false;
  String? _errorMessage;
 

  Future<void> getVillain(String villainUrl) async {
    setState(() {
      _loading = true;
      _hasError = false;
      _errorMessage = null;
    });

    if (villainUrl.trim().isEmpty) {
      setState(() {
        villain = null;
        _loading = false;
        _hasError = true;
        _errorMessage = 'Url não fornecida';
      });
      debugPrint('villainUrl não fornecida');
      return;
    }

    try {
      final response = await http.get(Uri.parse(villainUrl));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final Map<String, dynamic> source = (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : <String, dynamic>{});

        final v = Villain.fromJson(source);
        setState(() {
          villain = v;
          _loading = false;
          _hasError = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          villain = null;
          _loading = false;
          _hasError = true;
          _errorMessage = 'Erro HTTP ao buscar vilão: ${response.statusCode}';
        });
        debugPrint('Erro HTTP ao buscar vilão: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        villain = null;
        _loading = false;
        _hasError = true;
        _errorMessage = 'Erro ao buscar vilão: $e';
      });
      debugPrint('Erro ao buscar vilão: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // ModalRoute.of(context) não está disponível em initState; pega após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? villainUrl;
      if (args is String) {
        villainUrl = args;
      } else if (args is Map) {
        villainUrl = (args['villainUrl'] as String?) ?? (args['url'] as String?);
      }

      if (villainUrl != null && villainUrl.isNotEmpty) {
        getVillain(villainUrl);
      } else {
        debugPrint('villainUrl não fornecida via navegação');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = villain ?? Villain.empty();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        centerTitle: true,
        elevation: 6,
        backgroundColor: Colors.black,
        title: const Text('Detalhes do Vilão', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.black, Colors.red.shade900.withOpacity(0.18)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: _loading,
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              Visibility(
                visible: _hasError,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_errorMessage ?? 'Erro desconhecido', style: textStyle),
                    const SizedBox(height: 12),
                   
                  ],
                ),
              ),
              Visibility(
                visible: !_loading && !_hasError,
                child: Card(
                  color: const Color(0xFF1B1B1D),
                  elevation: 12,
                  shadowColor: Colors.red.shade900.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade900.withOpacity(0.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.name?? 'Nome Desconhecido',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Gênero: ${v.gender ?? 'N/A'}', style: textStyle),
                          Text('Status: ${v.status ?? 'N/A'}', style: textStyle),
                          const SizedBox(height: 8),
                          Text('Notas:', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                          Text(v.notes!.isEmpty ? 'Nenhuma' : v.notes!.join(', '), style: textStyle),
                          const SizedBox(height: 8),
Text(
  'Criado em: ${v.createdAt != null ? dateFormat.format(v.createdAt!) : "N/A"}',
  style: textStyle,
),                          const SizedBox(height: 12),
                          Text('Livros relacionados:', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                          if (v.books!.isEmpty)
                            Text('Nenhum', style: textStyle)
                          else
                            ...v.books!.map((b) => Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(b.title ?? 'Unknown', style: textStyle.copyWith(color: Colors.white70)),
                                )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}