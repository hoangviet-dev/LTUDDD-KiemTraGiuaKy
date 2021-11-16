import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'NewsInfo.dart';

class AppNews extends StatelessWidget {
  const AppNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HVietNews(),
    );
  }
}

class HVietNews extends StatefulWidget {
  const HVietNews({Key? key}) : super(key: key);

  @override
  _HVietNewsState createState() => _HVietNewsState();
}

class _HVietNewsState extends State<HVietNews> {
  late List<Type> lsType;
  late Future<News> newsData;

  @override
  void initState() {
    lsType = [];
    lsType.add(new Type(title: "Apple", value: "apple", url: "https://images.pexels.com/photos/3652898/pexels-photo-3652898.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"));
    lsType.add(new Type(title: "Banana", value: "banana", url: "https://images.pexels.com/photos/5966630/pexels-photo-5966630.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"));
    lsType.add(new Type(title: "Strawberry", value: "strawberry", url: "https://images.pexels.com/photos/2209382/pexels-photo-2209382.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"));
    lsType.add(new Type(title: "Pineapple", value: "pineapple", url: "https://images.pexels.com/photos/6157056/pexels-photo-6157056.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"));
    lsType.add(new Type(title: "Blueberry", value: "blueberry", url: "https://images.pexels.com/photos/1395958/pexels-photo-1395958.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"));
    newsData = News.fetchData("Apple");
  }

  Widget renderNews(Article article) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsInfo(article.url))
        );
      },
      child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(article.urlToImage??"",
                  width: double.maxFinite,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                child: Text(article.title??"None title",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 10),
                child: Text(article.content??"",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'HViet',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Text(
              'News',
              style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 5, right: 20, left: 20, bottom: 5),
              decoration: BoxDecoration(
                  color: Colors.white,
              ),
              child: CarouselSlider(
                items: lsType.map((t) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              newsData = News.fetchData(t.value);
                            });
                            print(t.value);
                          },
                          child: Stack(
                            children: [
                              Center(child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(t.url, width: 200, fit: BoxFit.cover))
                              ),
                              Center(child: Text(t.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                                )
                              ),)
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 100,
                  aspectRatio: 2.0,
                  viewportFraction: 0.56
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: newsData,
                builder: (context, AsyncSnapshot<dynamic> snapshot){
                  if (snapshot.hasData) {
                    var news = snapshot.data as News;
                    var data = news.articles;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        Article ar = data[index];
                        return renderNews(ar);
                      },
                    );
                  } else {
                    return Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(color: Colors.lightBlue,)
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Type {
  String title;
  String value;
  String url;
  Type({required this.title, required this.value, required this.url});
}

class News {
  News({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  String status;
  int totalResults;
  List<Article> articles;

  static Future<News> fetchData(String type) async {
    String url = "https://newsapi.org/v2/everything?q="+type+"&from=2021-10-16&sortBy=publishedAt&apiKey=fa5fd672f12946aa8c2be55b6a1c2cb2";
    var client = http.Client();
    var response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var result = response.body;
      var jsonData = jsonDecode(result);
      String status = jsonData["status"];
      int totalResults = jsonData["totalResults"];
      List<Article> articles = [];
      for (var item in jsonData["articles"]) {
        Source ?source = Source(id: item["source"]["id"], name: item["source"]["name"]);
        String ?author = item["author"];
        String ?content = item["content"];
        String ?description = item["description"];
        DateTime ?publishedAt = DateTime.parse(item["publishedAt"]);
        String ?title = item["title"];
        String ?url = item["url"];
        String ?urlToImage = item["urlToImage"];
        Article a = Article(
          source: source,
          author: author,
          content: content,
          description: description,
          publishedAt: publishedAt,
          title: title,
          url: url,
          urlToImage: urlToImage
        );
        articles.add(a);
      }
      News news = News(status: status, totalResults: totalResults, articles: articles);
      return news;
    } else {
      throw Exception("Lỗi lấy dữ liệu. Chi tiết: ${response.statusCode}");
    }
  }
}

class Article {
  Article({
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  Source ?source;
  String ?author;
  String ?title;
  String ?description;
  String ?url;
  String ?urlToImage;
  DateTime ?publishedAt;
  String ?content;
}

class Source {
  Source({
    required this.id,
    required this.name,
  });

  String ?id;
  String ?name;
}
