import 'dart:io';
import 'package:festiva/firebase_options.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:festiva/home_page.dart';
import 'package:festiva/list_page.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart'; 



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
  if (Platform.isAndroid) {
    await KakaoMapSdk.instance.initialize(dotenv.env["KAKAO_API_KEY"]!);
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Pages());
}

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  
  int _pageIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);


  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _pageIndex = index; 
    });
  }
 
  // @override
  // void initState() {
  //   super.initState();
  //   _pageController = PageController(initialPage: _pageIndex);
  // }
 
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = const [
    HomePage(),
    ListPage(),
    // ListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Pretendard"
      ),
      home: Scaffold(
        // floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: () {}),
        backgroundColor: Colors.white,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: _pages,
        ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xffFBFBFB),
        selectedItemColor: orangeColor1,
        unselectedItemColor: const Color(0xff868686),
        currentIndex: _pageIndex,
        onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house, size: 15,), label: "홈"),
            BottomNavigationBarItem(icon: Icon(Icons.celebration_rounded, size: 23,), label: "축제•행사"),
            // BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.mapLocationDot, size: 15,), label: "지도탐색"),
            BottomNavigationBarItem(icon: IgnorePointer(ignoring: true, child: FaIcon(FontAwesomeIcons.solidHeart, size: 15,)), label: "즐겨찾기"),
          ]
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}