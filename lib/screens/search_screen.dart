import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qiita_handson/models/article.dart';
import 'package:qiita_handson/models/user.dart';
import 'package:qiita_handson/widgets/article_container.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Article> articles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qiita Search'),
      ),
      body: Column(
        children: [
          // 検索ボックス
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 36,
            ),
            child: TextField(
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: InputDecoration( // プレースホルダー
                hintText: 'キーワードを入力してください',
              ),
              onSubmitted: (String value) async { // サブミットされたときに呼ばれる
                final results = await searchQiita(value);
                setState(() => articles = results);
              },
            ),
          ),
          // const ArticleContainer(),
          ArticleContainer(
            article: Article(
              title: 'test',
              user: User(
                id: 'test',
                profileImageUrl: 'https://firebasestorage.googleapis.com/v0/b/gs-expansion-test.appspot.com/o/unknown_person.png?alt=media',
              ),
              createdAt: DateTime.now(),
              tags: ['dart', 'flutter'],
              url: 'https://example.com',
            ),
          ),
        ],
        ),
      );
  }
}

Future<List<Article>> searchQiita(String keyword) async {
  // 1. http通信に必要なデータを準備をする
  // 1-1. URLとクエリパラメータを作成
  final uri = Uri.https('qiita.com', 'api/v2/items', {
    'query': 'title:$keyword',
    'per_page': '10',
  });
  // 1-2. アクセストークンの取得
  final String token = dotenv.env['QIITA_ACCESS_TOKEN'] ?? '';

  // 2. Qiita APIにリクエストを送る
  final http.Response res = await http.get(uri, headers: {
    'Authorization': 'Bearer $token',
  });

  // 3. 戻り値をArticleクラスの配列に変換
  // 4. 変換したArticleクラスの配列を返す(returnする)
  if (res.statusCode == 200) {
    // レスポンスをモデルクラスへ変換
    final List<dynamic> json = jsonDecode(res.body);
    return json.map((article) => Article.fromJson(article)).toList();
  } else {
    return [];
  }
}