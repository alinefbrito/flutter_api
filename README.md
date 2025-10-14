# Flutter - Acesso a dados via API

Este projeto Flutter é um exemplo de como consumir dados de uma API REST, processar o JSON recebido e exibir as informações em uma interface estilizada. 
---

## 1. Conexão HTTP

Para buscar dados de uma API, usamos o pacote [`http`](https://pub.dev/packages/http). O método principal é o `http.get`, que faz uma requisição GET para a URL desejada. O resultado é um objeto `Response` que contém o status e o corpo da resposta.

**Exemplo:**
```dart
var response = await http.get(Uri.parse(url));
if (response.statusCode == 200) {
  // sucesso
}
```

---

## 2. Parse do JSON

A resposta da API geralmente vem em formato JSON. Para transformar esse texto em objetos utilizáveis no Dart, usamos o `jsonDecode` da biblioteca `dart:convert`. Depois, mapeamos os dados para nossas classes de modelo (no caso, `Book`).

**Exemplo:**
```dart
final responseData = jsonDecode(response.body);
final Map<String, dynamic>? bookData = responseData['data'];
if (bookData != null) {
  book = Book.fromJson(bookData);
}
```

---

## 3. Exibição com Card

Para mostrar as informações do livro de forma organizada e visualmente agradável, usamos o widget `Card` do Flutter. Ele permite agrupar e destacar os dados, além de aplicar estilos como cor de fundo, borda arredondada e sombra.

**Exemplo:**
```dart
Card(
  color: Colors.grey[900],
  elevation: 16,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Text(book.title, style: TextStyle(...)),
        // outros campos do livro
      ],
    ),
  ),
)
```

---

## 4. Formatação de Datas

Para exibir datas no padrão brasileiro, usamos o pacote [`intl`](https://pub.dev/packages/intl`). Com ele, formatamos objetos `DateTime` para o formato `dd/MM/yyyy`.

**Exemplo:**
```dart
final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
Text('Criado em: ${dateFormat.format(book.createdAt)}');
```

---

## 5. Tratamento de Erros

O app verifica se a resposta da API foi bem-sucedida e se os dados estão no formato esperado. Caso contrário, exibe uma mensagem de erro amigável ao usuário.


