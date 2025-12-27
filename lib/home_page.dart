import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:festiva/applink_handler.dart';
import 'package:festiva/detail_page.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_links/app_links.dart';
import 'package:festiva/global_variable.dart';

Map targetDatabases = {
  "main_db": "",
  "detail_db": "",
  "titles_db": "",
  "recommend_db": "",
  "carousel_db": ""
};

void printLog(e) {
  debugPrint(e.toString());
}
final FirebaseFirestore _firebase = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage>, WidgetsBindingObserver {
  final appLink = AppLinks();
  StreamSubscription<Uri>? linkSubscription;
  // final navigatorKey = GlobalKey<NavigatorState>();
  // final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  // double get _adWidth => MediaQuery.of(context).size.width * 1;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDeepLinks();
  }

  @override
  void dispose() {
    linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    // Handle links
    linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
      printLog(uri.queryParameters);
    try {
      GlobalVariable.navState.currentState?.push( MaterialPageRoute(
        builder: (context) => ApplinkHandler(id: uri.queryParameters["id"], firebase: _firebase,),
      ));
    } catch (e) {
      printLog('App link error: $e');
      return;
    }
  }

  Future<Map> databaseSet() async {
    // _loadAd();
    await _firebase.collection('APP_DATA').doc("running_databases").get().then((snapshot) {
      targetDatabases["main_db"] = "festivals_main_data_${snapshot.data()?['main']}";
      targetDatabases["detail_db"] = "festivals_detail_data_${snapshot.data()?['detail']}";
      targetDatabases["titles_db"] = "titles_${snapshot.data()?['titles']}";
      targetDatabases["carousel_db"] = "Carousel_list_${snapshot.data()?['carousel']}";
      targetDatabases["recommend_db"] = "Recommended_festivals_${snapshot.data()?['recommend']}";
      printLog(targetDatabases);
    });
    return getRecmdData();
  }

  getRecmdList() async {
    
    List<List> preIds = [];
    List<String> listTitles = [];
    try {
      final recmdSnapshot = await _firebase.collection(targetDatabases["recommend_db"]).get();
      for (var doc in recmdSnapshot.docs) {
        try {
          preIds.add(doc["pre_ids"]);
          listTitles.add(doc["title"]);
        } catch (e) {
          printLog(e);
        }
      }
    } catch (e) {
      printLog(e);
    }
    // printLog(preIds);
    // printLog(listTitles);
    return {
      "length": listTitles.length,
      "list_titles": listTitles,
      "pre_ids": preIds,
    };
  }

  Future<Map> getRecmdData() async {
    var recmdListData = await getRecmdList();
    var carouselData = await _firebase.collection(targetDatabases["carousel_db"]).get();
    List carouselList = [];
    for (var doc in carouselData.docs) {
      try {
        await _firebase.collection(targetDatabases["main_db"]).doc(doc.id).get().then((snapshot) {
          String startDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventstartdate"] ?? (throw FormatException('eventstartdate error ${doc.id}'))));
          String endDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventenddate"] ?? (throw FormatException('eventenddate error ${doc.id}'))));
          String stateMsg = "";

          switch (snapshot.data()?["state"] ?? (throw FormatException('state error ${doc.id}'))) {
            case "1":
              stateMsg = "개최 중";
            case "0":
              stateMsg = "개최 예정";
            case "-1":
              stateMsg = "종료";
          }
          carouselList.add(
            {
              "title": snapshot.data()?["title"] ?? (throw FormatException('title error ${doc.id}')),
              "date": "$startDate - $endDate",
              "state": stateMsg,
              "img": snapshot.data()?["firstimage"] ?? (throw FormatException('image error ${doc.id}')),
              "locate": "${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[0]} ${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[1]}",
              "locate_full": snapshot.data()?["addr1"] ?? "",
              // "locate2": snapshot.data()?["addr2"] ?? "",
              "start_date": startDate,
              "end_date": endDate,
              "price": snapshot.data()?["price"].replaceAll("<br>", "\n"),
              "id": snapshot.data()?["contentid"],
              "mapx": snapshot.data()?["mapx"] ?? "",
              "mapy": snapshot.data()?["mapy"] ?? "",
            }
          );
        });
        
      } catch (e) {
        printLog(e);
      }
    }
    List data = [];
    List list = [];
    for (int i = 0; i < recmdListData["length"]; i++) {
      list = [];
      for (var _id in recmdListData["pre_ids"][i]) {
        await _firebase
            .collection(targetDatabases["main_db"])
            .doc(_id.toString())
            .get()
            .then((doc) {
              try {
                list.add({
                  "title": doc["title"],
                  "img": doc["firstimage"],
                  "locate": "${doc["addr1"].toString().split(" ")[0]} ${doc["addr1"].toString().split(" ")[1]}",
                  "start_date": DateFormat("yyyy.MM.dd").format(DateTime.parse(doc["eventstartdate"])),
                  "end_date": DateFormat("yyyy.MM.dd").format(DateTime.parse(doc["eventenddate"])),
                  "price": doc["price"].replaceAll("<br>", "\n"),
                  "locate_full": doc["addr1"] ?? "",
                  "id": doc["contentid"],
                  "mapx": doc["mapx"] ?? "",
                  "mapy": doc["mapy"] ?? "",
                });
              } catch(e) {
                printLog(e);
              }
              // printLog(doc["title"]);
            });
      }
      data.add(list);
    }
    return {"data": data, "list_titles": recmdListData["list_titles"], "carousel_list" : carouselList};
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          scrolledUnderElevation: 0,
          // pinned: true,
          title: SvgPicture.asset("assets/Logo.svg", width: 120),
          elevation: 0.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          floating: true,
          // snap: true,
        ),
        FutureBuilder(
          future: databaseSet(),
          builder: (context, snapshot) {
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Text("");
                } else {
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 7),
                        child: Carousel(data: snapshot.data?["carousel_list"]),
                      ),
                      if (Platform.isAndroid || Platform.isIOS)
                        NativeBannerAd(),
                        // NativeBanner(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.882,
                        child: ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data?["list_titles"].length,
                          itemBuilder: (BuildContext context, int index) {
                            return RecmdList(
                              recmdData: snapshot.data?["data"][index],
                              listTitle: snapshot.data?["list_titles"][index],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              }, childCount: 1),
            );
          },
        ),
      ],
    );
  }
}

class NativeBannerAd extends StatefulWidget {
  const NativeBannerAd({super.key});

  @override
  State<NativeBannerAd> createState() => _NativeListAdState();
}

class _NativeListAdState extends State<NativeBannerAd> {

  late NativeAd _ad;
  bool isLoaded = false;
 
  @override
  void initState() {
    super.initState();
 
    _ad = NativeAd(
      adUnitId: dotenv.env["ADMOB_NATIVE_ID"].toString(),
      // adUnitId: "ca-app-pub-3940256099942544/2247696110",
      factoryId: "bannerAd",
      request: const AdRequest(),
      listener: NativeAdListener(onAdLoaded: (ad) {
        setState(() {
          _ad = ad as NativeAd;
          isLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        ad.dispose();
      }),
    );
    _ad.load();
  }
 
  @override
  void dispose() {
    super.dispose();
    _ad.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoaded == true) {
      return Container(
        // margin: EdgeInsets.only(top: 15),
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
        height: 71,
        width: double.infinity,
        child: AdWidget(ad: _ad),
      );
    } else {
      return const SizedBox(height: 4);
    }
  }
}


class Carousel extends StatefulWidget {

  final List data;
  const Carousel({super.key, required this.data});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  late List data;
  List imgList = [];

  @override
  void initState() {
    super.initState();
    data = widget.data;
    int i = 0;
    for (var context in data) {
      imgList.add([context["img"], i]);
      i++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          items:
              imgList.map((img) {
                return Builder(
                  builder: (context) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => DetailPage(mainData: data[img[1]], firebase: _firebase)
                          )
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Skeletonizer(
                          effect: SoldColorEffect(),
                          enabled: false,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.76,
                            child: Stack(
                              // fit: StackFit.expand,
                              alignment: Alignment.bottomCenter,
                              children: [
                                Image.network(
                                  img[0],
                                  fit: BoxFit.cover,
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  color: const Color.fromRGBO(0, 0, 0, 0.03),
                                  colorBlendMode: BlendMode.multiply,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color.fromARGB(33, 0, 0, 0),
                                        const Color.fromARGB(125, 0, 0, 0),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(16, 0, 10, 22),
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 3),
                                        child: Text(
                                          data[img[1]]["date"],
                                          style: TextStyle(
                                            fontSize: 19,
                                            color: const Color(0xffF9F9F9),
                                            fontVariations: <FontVariation>[
                                              FontVariation('wght', 550),
                                            ],
                                          ),
                                        ),
                                      ),
                                      AutoSizeText(
                                        data[img[1]]["title"],
                                        maxLines: 1,
                                        maxFontSize: 28,
                                        style: TextStyle(
                                          fontSize: 28,
                                          color: const Color(0xffFDFDFD),
                                          fontVariations: <FontVariation>[
                                            const FontVariation('wght', 650),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 12),
                                        padding: EdgeInsets.fromLTRB(9, 0.6, 9, 0.6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          data[img[1]]["state"],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontVariations: <FontVariation>[
                                              const FontVariation('wght', 600),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
          options: CarouselOptions(
            height: 320,
            viewportFraction: 0.825,
            autoPlay: false,
            // autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 14, 0, 26),
          child: AnimatedSmoothIndicator(
            activeIndex: _current,
            count: imgList.length,
            effect: ExpandingDotsEffect(
              spacing: 7,
              dotHeight: 7,
              dotWidth: 7,
              dotColor: const Color(0xffD9D9D9),
              activeDotColor: const Color(0xff7D7D7D),
            ),
          ),
        ),
      ],
    );
  }
}

class RecmdListCard extends StatelessWidget {
  final Map cardData;

  const RecmdListCard({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => DetailPage(mainData: cardData, firebase: _firebase)
          )
        );
      },
      child: Container(
        // color: Colors.blue,
        width: MediaQuery.of(context).size.width * 0.765,
        margin: EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                cardData["img"],
                width: 89,
                height: 89,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/img_error_mini.jpg',
                    fit: BoxFit.fitHeight,
                    width: 89,
                    height: 89,
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                // color: Colors.black,
                padding: EdgeInsets.only(bottom: 0.5),
                margin: EdgeInsets.only(left: 16),
                constraints: BoxConstraints(minHeight: 88),
                // height: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 27.8,
                      child: Text(
                        cardData["title"],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.6,
                          fontVariations: <FontVariation>[
                            FontVariation("wght", 700),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      cardData["locate"],
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 12.5,
                        color: const Color.fromARGB(255, 58, 58, 58),
                        fontVariations: <FontVariation>[
                          FontVariation("wght", 450),
                        ],
                      ),
                    ),
                    Text(
                      "${cardData["start_date"]} ~ ${cardData["end_date"]}",
                      style: TextStyle(
                        // overflow: TextOverflow.ellipsis,
                        fontSize: 12.5,
                        color: const Color.fromARGB(255, 58, 58, 58),
                        fontVariations: <FontVariation>[
                          FontVariation("wght", 450),
                        ],
                      ),
                    ),
                    Text(
                      cardData["price"].isEmpty ? "가격정보가 없습니다" : cardData["price"],
                      style: TextStyle(
                        fontSize: 12.5,
                        color: orangeColor2,
                        // backgroundColor: Colors.amber,
                        fontVariations: <FontVariation>[
                          FontVariation("wght", 450),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecmdList extends StatelessWidget {
  final List recmdData;

  final String listTitle;

  const RecmdList({
    super.key,
    required this.recmdData,
    required this.listTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 23.5, 0, 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    listTitle,
                    style: TextStyle(
                      fontSize: 19,
                      fontVariations: <FontVariation>[FontVariation("wght", 720)],
                    ),
                  ),
                ),
                // Row(
                //   children: [
                //     Text(
                //       "더보기 ",
                //       style: TextStyle(
                //         fontSize: 14,
                //         color: const Color(0xff707070),
                //         fontVariations: <FontVariation>[
                //           FontVariation("wght", 500),
                //         ],
                //       ),
                //     ),
                //     FaIcon(
                //       FontAwesomeIcons.chevronRight,
                //       color: const Color(0xff707070),
                //       size: 13,
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          Column(
            children: [
              if ( recmdData.length >= 1) RecmdListCard(cardData: recmdData[0]),
              if ( recmdData.length >= 2) RecmdListCard(cardData: recmdData[1]),
              if ( recmdData.length >= 3) RecmdListCard(cardData: recmdData[2]),
            ],
          ),
        ],
      ),
    );
  }
}
