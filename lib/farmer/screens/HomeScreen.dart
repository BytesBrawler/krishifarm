import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:krishfarm/basic_utitlities.dart';
import 'package:krishfarm/data/Repository.dart';
import 'package:krishfarm/data/api_exception.dart';
import 'package:krishfarm/farmer/routing/RouteHandler.dart';
import 'package:krishfarm/farmer/screens/CalenderScreen/screens/AddCropFieldScreen.dart';
import 'package:krishfarm/farmer/screens/CalenderScreen/screens/FieldScreen.dart';
import 'package:krishfarm/farmer/screens/CalenderScreen/screens/MyCropFieldScreen.dart';
import 'package:krishfarm/farmer/screens/ProductsScreen/MyProductsScreen.dart';
import 'package:krishfarm/farmer/screens/VideoScreen.dart';
import 'package:krishfarm/farmer/screens/WeatherScreen/WeatherScreen.dart';
import 'package:krishfarm/farmer/screens/areaToolScreen.dart';
import 'package:krishfarm/farmer/screens/farmers_home_screen.dart';
import 'package:krishfarm/farmer/screens/orderScreen.dart';
import 'package:krishfarm/farmer/screens/playlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:krishfarm/farmer/screens/webSceens/chatBot.dart';
import 'package:krishfarm/farmer/screens/webSceens/chatHistoryScreen.dart';
import 'package:krishfarm/farmer/screens/webSceens/chatScreen.dart';
import 'package:krishfarm/screens/edit_product/edit_product_screen.dart';
import 'package:krishfarm/services/database/product_database_helper.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import './MenuScreen.dart';
import './MandiScreen/MandiScreen.dart';
import './MandiScreen/state/MandiBloc.dart';
import './ProductsScreen/ProductsScreen.dart';
import '../services/LocalizationProvider.dart';
import './ProductsScreen/state/ProductsBloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    print("HomeScreen");
    _pages = [
      FarmerHomeScreen(),
      const Playlist(),
      // Provider<MandiBloc>(
      //   create: (context) => MandiBloc(),
      //   dispose: (context, bloc) => bloc.dispose(),
      //   child: MandiScreen(),
      // ),
    ];
    initSpeechToText();
    initTextToSpeech();
  }

  final flutterTts = FlutterTts();

  String lastWords = '';
  // late stt.SpeechToText _speech;

  final speechToText = SpeechToText();

  ApiRepo _api = ApiRepo();
  bool _isListening = false;
  // String _command = "";

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();

    flutterTts.stop();
    _pageController.dispose();
  }

  Future<void> initTextToSpeech() async {
    print("intializing text to speech");
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  // Future<String> convertor(String oldString, language) async {
  //   var translation = await translator.translate(oldString, to: language);
  //   return translation.toString();
  // }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    print("speech initialized");
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    print("onSpeechResult  " + result.recognizedWords);
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
    setState(() {});
  }

  Future<void> systemStop() async {
    await flutterTts.stop();
    setState(() {});
  }

  Future<void> startListening() async {
    print("listening");
    _isListening = true;
    await speechToText.listen(
      onResult: onSpeechResult,
    );
    setState(() {
      _isListening = true;
    });
  }

  // Future<void> stopListening() async {
  //   print("stop listening");
  //   await speechToText.stop();
  //   setState(() {
  //     _isListening = false;
  //   });
  //   await _sendToAI(lastWords);
  // }

  Future<void> _processAIResponse(Map response) async {
    String type = response["action"]["type"];
    String text = response["action"]["text"];
    //  String target = response["action"]["target"];
    print(text);
    //  print(target);
    print(type);
    //["AddProduct", "EditProduct", "MyOrders", "search" , "chatbot"]
    if (type == "AddProduct") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProductScreen(),
          ));
    } else if (type == "EditProduct") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyProductsScreen(),
          ));
    } else if (type == "OrdersScreen") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderScreen(),
          ));
    } else if (type == "AddCropScreen") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCropFieldScreen(),
          ));
    } else if (type == "MyCropsScreen") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldScreen(),
          ));
    } else if (type == "WheatherScreen") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherScreen(),
          ));
    } else if (type == "ChatScreen") {
      final user = Provider.of<User?>(context);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatHistoryScreen(userId: user!.uid),
          ));
    } else if (type == "ChatBotScreen") {
      final user = Provider.of<User?>(context);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatbotScreen(userId: user!.uid),
          ));
    } else if (type == "CalculateArea") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Areatoolscreen(),
          ));
    } else if (type == "VideoScreen") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Playlist(),
          ));
    } else if (type == "MandiScreen") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MandiScreen(),
          ));
    } else if (type == "search") {
      final query = text.toString();
      print(query);
      if (query.length <= 0) return;
      List<String> searchedProductsId;

      // try {
      //   print("1");
      //   searchedProductsId = await ProductDatabaseHelper()
      //       .searchInProducts(query.toLowerCase());
      //   print(searchedProductsId);
      //   if (searchedProductsId != null) {
      //     await Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => SearchResultScreen(
      //           searchQuery: query,
      //           searchResultProductsId: searchedProductsId,
      //           searchIn: "All Products",
      //         ),
      //       ),
      //     );
      //     //  await refreshPage();
      //   } else {
      //     throw "Couldn't perform search due to some unknown reason";
      //   }
      // } catch (e) {
      //   final error = e.toString();
      //   Logger().e(error);
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text("$error"),
      //     ),
      //   );
      //  }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.toString())),
      );
    }
  }

  Future<void> _sendToAI(String text) async {
    try {
      Map data = {
        "text": text,
      };
      print(data);
      final response = await _api.navigationFarmerAi(data);
      print(response);
      _processAIResponse(response);

      //   Utils.snackBar(context, response["message"]); // Display OTP sent message
    } on ApiException catch (errorJson) {
      final errorMessage = errorJson.message;
      print(errorMessage);
      Utils.snackBar(context, errorMessage);
    } catch (error) {
      print(error);
      Utils.snackBar(context, "An unexpected error occurred. $error");
    }
  }

  Future<void> stopListening() async {
    print("stop listening");

    await speechToText.stop();

    // Delay to ensure lastWords updates
    await Future.delayed(Duration(seconds: 1));

    if (lastWords.isNotEmpty) {
      print("Sending words to AI: $lastWords");
      await _sendToAI(lastWords);
    } else {
      print("No recognized words to send.");
      Utils.snackBar(context, "No input detected. Please try again.");
    }

    setState(() {
      _isListening = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechToText.hasPermission && !_isListening) {
            await startListening();
          } else if (_isListening) {
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          size: 40,
          color: speechToText.isListening ? Colors.red : Colors.green,
        ),
        //child: Icon(Icons.mic),
      ),
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.amber[800],
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  text: isEnglish ? 'Home' : 'घर',
                ),
                GButton(
                  icon: LineIcons.video,
                  text: isEnglish ? 'Videos' : 'वीडियो',
                ),
                // GButton(
                //   icon: LineIcons.shoppingBasket,
                //   text: isEnglish ? 'Mandi' : 'मंडी',
                // ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}






// import 'package:krishfarm/farmer/screens/VideoScreen.dart';
// import 'package:krishfarm/farmer/screens/farmers_home_screen.dart';
// import 'package:krishfarm/farmer/screens/playlist_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:line_icons/line_icons.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';

// import './MenuScreen.dart';
// import './MandiScreen/MandiScreen.dart';
// import './MandiScreen/state/MandiBloc.dart';
// import './ProductsScreen/ProductsScreen.dart';
// import '../services/LocalizationProvider.dart';
// import './ProductsScreen/state/ProductsBloc.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final PageController _pageController = PageController(initialPage: 0);
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     // Uncomment and add your ProductsScreen if needed
//     // Provider<ProductsBloc>(
//     //   create: (context) => ProductsBloc(),
//     //   dispose: (context, blog) => blog.dispose(),
//     //   child: ProductsScreen(),
//     // ),
//     FarmerHomeScreen(),
//     //  MenuScreen(),
//     Playlist(),
//     Provider<MandiBloc>(
//       create: (context) => MandiBloc(),
//       dispose: (context, bloc) => bloc.dispose(),
//       child: MandiScreen(),
//     ),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     _pageController.jumpToPage(index);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         children: _pages,
//         onPageChanged: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           // Uncomment and add your ProductsScreen if needed
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.shopping_cart),
//           //   label: 'Market',
//           // ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.menu),
//             label: 'Menu',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.video_library),
//             label: 'Video',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.local_grocery_store),
//             label: 'Mandi',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.amber[800],
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// class MandiBloc {
//   void dispose() {}
// }
