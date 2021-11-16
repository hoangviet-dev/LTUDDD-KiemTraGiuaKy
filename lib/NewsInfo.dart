
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class anv extends StatefulWidget {
  const anv({Key? key}) : super(key: key);

  @override
  _anvState createState() => _anvState();
}

class _anvState extends State<anv> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class NewsInfo extends StatefulWidget {
  const NewsInfo(this.url, {Key? key}) : super(key: key);
  final String ?url;

  @override
  _NewsInfoState createState() => _NewsInfoState();
}

class _NewsInfoState extends State<NewsInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.lightBlue,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,

      )
    );
  }
}

