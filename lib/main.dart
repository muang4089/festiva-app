import 'dart:io';
import 'package:festiva/firebase_options.dart';
import 'package:festiva/like_page.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:festiva/home_page.dart';
import 'package:festiva/list_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart'; 
import 'package:festiva/global_variable.dart';


String hashKey = "";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    await MobileAds.instance.initialize();
  }
  await dotenv.load(fileName: "assets/config/.env");
  if (Platform.isAndroid) {
    await KakaoMapSdk.instance.initialize(dotenv.env["KAKAO_API_KEY"]!);
    hashKey = (await KakaoMapSdk.instance.hashKey())!;
  } else if (Platform.isIOS) {
    // print("${await KakaoMapSdk.instance.hashKey()} muangtest");
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
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = const [
    HomePage(),
    ListPage(),
    LikePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xffFBFBFB),
        systemNavigationBarIconBrightness: Brightness.dark
      ),
      child: MaterialApp(
        navigatorKey: GlobalVariable.navState,
        theme: ThemeData(
          fontFamily: "Pretendard"
        ),
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: _pages,
            ),
          ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent, 
            // highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(0xffFBFBFB),
            selectedItemColor: orangeColor1,
            unselectedItemColor: const Color(0xff868686),
            currentIndex: _pageIndex,
            onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house, size: 15,), label: "홈"),
                BottomNavigationBarItem(icon: Icon(Icons.celebration_rounded, size: 23,), label: "축제•행사"),
                BottomNavigationBarItem(icon: IgnorePointer(ignoring: true, child: FaIcon(FontAwesomeIcons.solidHeart, size: 15,)), label: "즐겨찾기"),
              ]
            ),
        ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}