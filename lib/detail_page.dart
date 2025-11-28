import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
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
  List imgs = [];
  String posterImg = "";
  @override
  void initState() {
    super.initState();
    mainData = widget.mainData;
    firebase = widget.firebase;
  }
  Future<Map> getDetailData() async {
    var detailData = await firebase.collection(targetDatabases["detail_db"]).doc(mainData["id"]).get();
    imgs = [];
    imgs.add(mainData["img"]);
    if (detailData.data()["imgs"].isNotEmpty) {
      detailData.data()["imgs"].forEach((element) {
        if (element["imgname"].contains("포스터")) {
          
        } else {
          imgs.add(element["originimgurl"]);
        }
      });
    }
    return detailData.data();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F3F3),
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        if (imgs.isNotEmpty) Carousel(imgList: imgs),
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
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 243, 216, 202),
                                        shape: BoxShape.circle
                                      ),
                                      alignment: Alignment.center,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 2.6),
                                        child: FaIcon(FontAwesomeIcons.solidCalendar, color: const Color.fromARGB(255, 226, 119, 66), size: 20.4)
                                      )
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(12, 5.7, 0, 0),
                                        child: Text("${mainData["start_date"]} ~ ${mainData["end_date"]}",style: TextStyle (
                                          fontSize: 15,
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
                                    Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 243, 216, 202),
                                        shape: BoxShape.circle
                                      ),
                                      child: FaIcon(FontAwesomeIcons.solidClock, color: const Color.fromARGB(255, 226, 119, 66), size: 18.9)
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(12, 5.7, 0, 0),
                                        child: Text(snapshot.data?["playtime"].replaceAll("<br>", "\n") ,style: TextStyle (
                                          height: 1.3,
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontVariations: <FontVariation>[
                                            const FontVariation('wght', 420),
                                          ],
                                        ),
                                        ),
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
                                    Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 243, 216, 202),
                                        shape: BoxShape.circle
                                      ),
                                      child: Container(
                                        margin:  EdgeInsets.only(top: 2.2),
                                        child: FaIcon(FontAwesomeIcons.wonSign, color: const Color.fromARGB(255, 226, 119, 66), size: 18.9),
                                        )
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(12, 5.7, 0, 0),
                                        child: Text(mainData["price"],style: TextStyle (
                                          fontSize: 15,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 243, 216, 202),
                                        shape: BoxShape.circle
                                      ),
                                      child: Container(
                                        margin:  EdgeInsets.only(bottom: 1.6),
                                        child: FaIcon(FontAwesomeIcons.locationDot, color: const Color.fromARGB(255, 226, 119, 66), size: 23)
                                      )
                                      ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(12, 5.7, 0, 0),
                                        child: Text(mainData["locate_full"],style: TextStyle (
                                          fontSize: 15,
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
                                  borderRadius: BorderRadius.circular(8)
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
                                height: 25,
                              )
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(top: 12.8),
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          color: Colors.white,
                          // padding: EdgeInsets.fromLTRB(0, 13.5, 0, 0),
                          child: ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InfoText(infoName: snapshot.data?["info"][index]["infoname"], infoText: snapshot.data?["info"][index]["infotext"]);
                            },
                            itemCount: snapshot.data?["info"].length,
                          ),
                        ),
                      ],
                    ),
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
        printLog("KAKAO MAP complete");
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

class InfoText extends StatelessWidget {

  const InfoText({super.key, required this.infoName, required this.infoText});

  final String infoName;
  final String infoText;

  // if ()
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 16, 0, 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(infoName.replaceAll("<br>", "\n"), style: TextStyle (
            fontSize: 17,
            color: Colors.black,
            fontVariations: <FontVariation>[
              FontVariation('wght', 700),
            ],
          )),
          Container(
            padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
            margin: EdgeInsets.fromLTRB(0, 9, 0, 0),
            child: ExpandableText(
              infoName!="행사내용" ? 
              (infoText.startsWith(" ") ? infoText.replaceAll("\n", "\n ").replaceAll("<br>", "\n") : ' ${infoText.replaceAll("\n", "\n ").replaceAll("<br>", "\n")}')
              : infoText.replaceAll("<br>", "\n"),
              expandText: '더보기',
              collapseText: ' 접기',
              maxLines: 7,
              expandOnTextTap: true,
              // expanded: true,
              collapseOnTextTap: true,
              linkColor: const Color.fromARGB(255, 155, 155, 155),
              style: TextStyle(
                height: 1.5,
                fontSize: 14.8,
                color: Colors.black,
                fontVariations: <FontVariation>[
                  FontVariation('wght', 420),
                ],
              ),
                  ),
          ),
      ],
      ),
    );
  }
}

class Carousel extends StatefulWidget {
  const Carousel({super.key, required this.imgList});
  final List imgList;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  List imgList = [];
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    imgList = widget.imgList;
  }
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
                    return Image.network(
                      img,
                      width: double.maxFinite,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/img_error.jpg',
                        width: double.maxFinite,
                        fit: BoxFit.cover
                        );
                      },
                    );
                  },
                );
              }).toList(),
          options: CarouselOptions(
            height: 252,
            viewportFraction: 1,
            autoPlay: false,
            enableInfiniteScroll: imgList.length == 1 ? false : true,
            // autoPlayInterval: const Duration(seconds: 4),
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
            color: const Color.fromARGB(207, 15, 15, 15),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(9))
          ),
          // padding: EdgeInsets.fromLTRB(5.3, 0.2, 5.2, 0.2),
          child: Text("${_current+1} / ${imgList.length}",
            style: TextStyle(
              fontSize: 13,
              color: const Color.fromARGB(255, 226, 226, 226),
              fontVariations: <FontVariation>[
              const FontVariation('wght', 390),
            ],
              ),
          )
        ),
      ],
    );
  }
}