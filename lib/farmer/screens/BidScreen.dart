import 'package:flutter/material.dart';
import 'package:krishfarm/farmer/screens/webSceens/chatScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BidScreen extends StatelessWidget {
  final String userId;
  final String urlType;

  const BidScreen({super.key, required this.userId, required this.urlType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Bid",
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 22,
            color: Colors.black.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black.withOpacity(0.8),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.help,
        //       color: Colors.black.withOpacity(0.8),
        //     ),
        //     onPressed: () => Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (ctx) => VideoScreen(title, videoUrl),
        //       ),
        //     ),
        //   )
        // ],
      ),
      backgroundColor: Colors.white,
      body: WebViewsWidget(
          url: "https://ameya-sih.netlify.app/${urlType}/${userId}"),
    );
  }
}
