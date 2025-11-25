import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'home_page.dart';

void printLog(e) {
  debugPrint(e.toString());
}

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.mainData, required this.firebase});
  final Map mainData;
  final dynamic firebase;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Map mainData;
  late dynamic firebase;

  @override
  void initState() {
    super.initState();
    mainData = widget.mainData;
    firebase = widget.firebase;
  }
  Future<Map> getDetailData() async {
    var detailData = await firebase.collection(targetDatabases["detail_db"]).doc(mainData["id"]).get();
    printLog(detailData.data());
    
    return detailData.data();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        backgroundColor: Colors.white,
          title: Text("상세정보", style: TextStyle(
            fontSize: 21,
            fontVariations: <FontVariation>[
              const FontVariation('wght', 690),
            ],
          )),
          leading: IconButton(
            icon: FaIcon(
              FontAwesomeIcons.chevronLeft,
              color: const Color.fromARGB(255, 0, 0, 0),
              size: 17,
            ), onPressed: () {Navigator.pop(context);},
          ),
        ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getDetailData(), 
          builder: (context, snapshot) {
            if (snapshot.hasData) {
            //  return Text(snapshot.data?["sponsor1tel"]);
              return Column(
                children: [
                  Carousel(),
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: MediaQuery.of(context).size.width * 0.9,
                    // color: Colors.amber, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mainData["title"],style: TextStyle (
                          fontSize: 23.9,
                          color: Colors.black,
                          fontVariations: <FontVariation>[
                            const FontVariation('wght', 700),
                          ],
                        )),
                        Container(
                          margin: EdgeInsets.fromLTRB(2, 3.3, 0, 13),
                          child: Text("${snapshot.data?["sponsor1"]} ${!snapshot.data?["sponsor2"].trim().isEmpty ? '|' : ''} ${snapshot.data?["sponsor2"]}",style: TextStyle (
                            fontSize: 14.5,
                            color: Color(0xff313131),
                            fontVariations: <FontVariation>[
                              const FontVariation('wght', 500),
                            ],
                          )),
                        ),
                        Divider(thickness: 1, color: Color(0xffAFAFAF),indent: 9,endIndent: 9,),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 16, 0, 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FaIcon(FontAwesomeIcons.solidCalendar, color: orangeColor1, size: 21.5),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Text("${mainData["start_date"]} ~ ${mainData["end_date"]}",style: TextStyle (
                                    fontSize: 14.7,
                                    color: Colors.black,
                                    fontVariations: <FontVariation>[
                                      const FontVariation('wght', 420),
                                    ],
                                  )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FaIcon(FontAwesomeIcons.solidClock, color: orangeColor1, size: 19.5),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Text(snapshot.data?["playtime"].replaceAll("<br>", "\n") ,style: TextStyle (
                                    height: 1.3,
                                    fontSize: 14.7,
                                    color: Colors.black,
                                    fontVariations: <FontVariation>[
                                      const FontVariation('wght', 420),
                                    ],
                                  )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FaIcon(FontAwesomeIcons.wonSign, color: orangeColor1, size: 19),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Text(mainData["price"],style: TextStyle (
                                    fontSize: 14.7,
                                    color: Colors.black,
                                    fontVariations: <FontVariation>[
                                      const FontVariation('wght', 420),
                                    ],
                                  )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          // color: Colors.amber,
                          margin: EdgeInsets.only(bottom: 17),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.locationDot, color: orangeColor1, size: 25,),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Text(mainData["locate_full"],style: TextStyle (
                                    fontSize: 14.7,
                                    color: Colors.black,
                                    fontVariations: <FontVariation>[
                                      const FontVariation('wght', 420),
                                    ],
                                  )),
                                ),
                              )
                            ],
                          ),
                        ), 
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xffD8D8D8), width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          margin: EdgeInsets.only(left: 33),
                          width: 270,
                          height: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: getMap(double.parse(mainData["mapx"]),double.parse(mainData["mapy"]))
                          )
                        ),
                        SizedBox(
                          height: 250,
                        )
                      ],
                    )
                  )
                ],
              );
            } else {
              return Text("asdf");
            }
          }),
      )
    );
  }

  Widget getMap(x,y) {
    if (Platform.isAndroid) {
      return KakaoMap(
        option: KakaoMapOption(
          position: LatLng(y, x),
          zoomLevel: 16,
          mapType: MapType.normal,
        ),
      onMapReady: (KakaoMapController controller) {
        printLog("카카오 지도가 정상적으로 불러와졌습니다.");
        controller.labelLayer.addPoi(LatLng(y, x), style: PoiStyle(
          icon: KImage.fromAsset("assets/pin.png", 22, 22)
        ));
      });
    } else {
      return Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: const Color.fromARGB(255, 241, 241, 241)
      );
    }
  }
}

class Carousel extends StatefulWidget {
  const Carousel({super.key});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {

  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  List imgList = [
    'assets/test2.png',
    'assets/test2.png',
    'assets/test1.png',
    'assets/test2.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CarouselSlider(
          carouselController: _controller,
          items:
              imgList.map((img) {
                return Builder(
                  builder: (context) {
                    return Image.asset(
                      img,
                      width: double.maxFinite,
                      fit: BoxFit.cover,
                    );
                  },
                );
              }).toList(),
          options: CarouselOptions(
            height: 252,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        Container(
          width: 43,
          height: 21.7,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(204, 15, 15, 15),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(9))
          ),
          // padding: EdgeInsets.fromLTRB(5.3, 0.2, 5.2, 0.2),
          child: Text("${_current+1} / ${imgList.length}",
            style: TextStyle(
              fontSize: 13,
              color: const Color.fromARGB(255, 247, 247, 247),
              fontVariations: <FontVariation>[
              const FontVariation('wght', 290),
            ],
              ),
          )
        ),
      ],
    );
  }
}