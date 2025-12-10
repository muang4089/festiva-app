import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart';

bool isLiked = false;
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
  late Map mainData = {};
  late dynamic firebase;
  List imgs = [];
  String posterImg = "";
  String id = "";
  late Widget map;

  @override
  void initState() {
    super.initState();
    mainData = widget.mainData;
    firebase = widget.firebase;
  }

  void setDetailtoMain() {
    printLog("mainData is dempty");
  }

  Future<Map> getDetailData() async {
    var detailData = await firebase.collection(targetDatabases["detail_db"]).doc(mainData["id"]).get();
    
    imgs = [];
    imgs.add(mainData["img"]);
    if (detailData.data()["imgs"].isNotEmpty) {
      detailData.data()["imgs"].forEach((element) {
        if (element["imgname"].contains("포스터")) {
          posterImg = element["originimgurl"];
        } else {
          imgs.add(element["originimgurl"]);
        }
      });
    }
    return detailData.data();
  }

  Future<void> checkLike() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likes = prefs.getStringList("likes");
    printLog(likes);
    if (likes != null && likes.contains(mainData["id"])) {
        isLiked = true;
        printLog("Like!");
    } else {
        isLiked = false;
        printLog("NOT Like");
    }
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
          actions: [
            IconButton(
              visualDensity: VisualDensity.compact,
              // padding: EdgeInsets.zero,
              icon: Container(
                margin: EdgeInsets.only(top: 1.4),
                child: FaIcon(
                  Icons.share,
                  color: const Color.fromARGB(255, 49, 49, 49),
                  size: 22.5,
                ),
              ), onPressed: () {
                Uri shareUri = Uri.parse("https://milch4089.dothome.co.kr?id=${mainData["id"]}");
                // SharePlus.instance.share(ShareParams(uri: shareUri, title: mainData["title"], subject: mainData["title"]));
                SharePlus.instance.share(ShareParams(text: "${mainData["title"]}\n${shareUri.toString()}"));
              }
            ),
            SizedBox(width: 1),
            FutureBuilder(
              future: (checkLike()),
              builder: (context, asyncSnapshot) {
                return IconButton(
                  visualDensity: VisualDensity.compact,
                  // padding: EdgeInsets.only(right: 10),
                  icon: FaIcon(
                    isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                    color: isLiked ? const Color.fromARGB(255, 247, 65, 65): const Color.fromARGB(255, 49, 49, 49),
                    size: 22.5,
                  ), onPressed: () async {
                    setState(() {
                      isLiked = !isLiked;
                    });
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    if (isLiked == true) {
                      if (prefs.getStringList('likes') == null) {
                        await prefs.setStringList("likes", <String>[mainData["id"]]);
                      } else {
                        List<String>? likes = prefs.getStringList("likes");
                        likes?.add(mainData["id"]);
                        await prefs.setStringList("likes", likes!.toSet().toList());
                      }
                    } else {
                      if (prefs.getStringList('likes') != null) {
                        List<String>? likes = prefs.getStringList("likes");
                        likes?.remove(mainData["id"]);
                        await prefs.setStringList("likes", likes!.toSet().toList());
                      }
                    }
                  }
                );
              }
            ),
            SizedBox(width: 8.5),
          ],
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
                        if (imgs.isNotEmpty) 
                          GestureDetector(
                            // behavior: HitTestBehavior,
                            onTap: () {
                              showDialog(
                                barrierColor: const Color.fromARGB(213, 20, 20, 20),
                                context: context, 
                                builder: (context) {
                                  return Container(
                                    padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.13, 0, MediaQuery.of(context).size.height * 0.13),
                                    // height: 100,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Carousel(imgList: imgs, fit: BoxFit.scaleDown, indexOption: 2),
                                    ),
                                  );
                                }
                              );
                            },
                            child: SizedBox(
                              height: 252,
                              child: Carousel(imgList: imgs, fit: BoxFit.cover, indexOption: 1)
                            ),
                          ),
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          width: MediaQuery.of(context).size.width * 0.9,
                          // color: Colors.amber, 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 3.3),
                                child: Text(mainData["title"],style: TextStyle (
                                  fontSize: 23.9,
                                  color: Colors.black,
                                  fontVariations: <FontVariation>[
                                    const FontVariation('wght', 700),
                                  ],
                                )),
                              ),
                              if ((snapshot.data?["sponsor1"] ?? "").isNotEmpty)
                                Container(
                                  margin: EdgeInsets.fromLTRB(2, 0, 0, 12.4),
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
                                        margin: EdgeInsets.fromLTRB(12, 4.2, 0, 0),
                                        child: Text("${mainData["start_date"]} ~ ${mainData["end_date"]}",style: TextStyle (
                                          fontSize: 15.5,
                                          color: Colors.black,
                                          fontVariations: <FontVariation>[
                                            const FontVariation('wght', 430),
                                          ],
                                        )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              if ((snapshot.data?["playtime"] ?? "").isNotEmpty)
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
                                          margin: EdgeInsets.fromLTRB(12, 4.2, 0, 0),
                                          child: Text(snapshot.data?["playtime"].replaceAll("<br>", "\n") ,style: TextStyle (
                                            height: 1.3,
                                            fontSize: 15.5,
                                            color: Colors.black,
                                            fontVariations: <FontVariation>[
                                              const FontVariation('wght', 430),
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
                                        margin: EdgeInsets.fromLTRB(12, 4.2, 0, 0),
                                        child: Text(mainData["price"].isEmpty ? "가격정보가 없습니다" : mainData["price"], style: TextStyle (
                                          fontSize: 15.5,
                                          color: Colors.black,
                                          fontVariations: <FontVariation>[
                                            const FontVariation('wght', 430),
                                          ],
                                        )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              if (mainData["locate_full"].trim().isNotEmpty)
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
                                          margin: EdgeInsets.fromLTRB(12, 4.2, 0, 0),
                                          child: Text(mainData["locate_full"],style: TextStyle (
                                            fontSize: 15.5,
                                            color: Colors.black,
                                            fontVariations: <FontVariation>[
                                              const FontVariation('wght', 430),
                                            ],
                                          )),
                                        ),
                                      )
                                    ],
                                  ),
                                ), 
                              if (mainData["mapx"].isNotEmpty && mainData["mapy"].isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context, 
                                      builder: (context) {
                                        return Container(
                                          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.06, 80, MediaQuery.of(context).size.width * 0.06, 90),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(11.5),
                                              border: Border.all(color: Color(0xffD8D8D8), width: 2),
                                              color: Color(0xffD8D8D8)
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: getMap(double.parse(mainData["mapx"]),double.parse(mainData["mapy"]))
                                            ),
                                          ),
                                          // color: Colors.grey,
                                        );
                                      }
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xffD8D8D8), width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(0xffD8D8D8)
                                    ),
                                    margin: EdgeInsets.fromLTRB(33, 0, 0, 10),
                                    width: 270,
                                    height: 140,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: AbsorbPointer(
                                        absorbing: true, 
                                        child: getMap(double.parse(mainData["mapx"]),double.parse(mainData["mapy"]))
                                        // child: map = KakaoMAP(x: double.parse(mainData["mapx"]), y: double.parse(mainData["mapy"])),
                                      )
                                    )
                                  ),
                                ),
                                SizedBox(
                                  height: 24,
                                )
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                  if (snapshot.data?["info"].isNotEmpty)
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
                    ),
                  if (posterImg.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 12.8),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                    ),
                      child: Poster(poster: posterImg,),
                    ),
                  Container(
                    margin: EdgeInsets.only(top: 12.8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      color: Colors.white,
                    ),
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        EtcInfo(tel: snapshot.data?["tel"], telname: snapshot.data?["telname"], homepage: snapshot.data?["homepage"]),
                      ],
                    )
                  )
                ],
              );
            } else {
              return Text("");
            }
          }),
      )
    );
  }

  Widget getMap(x,y) {
    if (Platform.isAndroid) {
      printLog("get Map");
      return KakaoMap(
        option: KakaoMapOption(
          position: LatLng(y, x),
          zoomLevel: 16,
          mapType: MapType.normal,
        ),
      onMapReady: (KakaoMapController controller) {
        printLog("KAKAO MAP complete");
        // controller.setGesture(GestureType.unknown, false);
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

  @override
  Widget build(BuildContext context) {

    String processedInfoText="";
    if (infoName!="행사내용") {
      if (!infoText.contains("\n") && !infoText.contains("<br>")) {
        processedInfoText = '• ${infoText.replaceAll(". ", ".\n\n• ")}';
        // printLog("1");
        if (processedInfoText.trim().endsWith("•")) {
          processedInfoText = processedInfoText.substring(0, processedInfoText.length - 5);
          // printLog("2");
        }
      } else {
        processedInfoText = '• ${infoText.replaceAll("<br>", "\n").replaceAll("\n\n","\n").replaceAll("\n", "\n\n• ")}';
        // printLog("3");
      }
    } else {
      processedInfoText = infoText.replaceAll("<br>", "\n");
      // printLog("4");
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 25, 0, 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(infoName.replaceAll("<br>", "\n"), style: TextStyle (
            fontSize: 17.5,
            color: Colors.black,
            fontVariations: <FontVariation>[
              FontVariation('wght', 700),
            ],
          )),
          Container(
            padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
            margin: EdgeInsets.fromLTRB(0, 9, 0, 0),
            child: ExpandableText(processedInfoText,
              expandText: '더보기',
              collapseText: ' 접기',
              maxLines: 6,
              expandOnTextTap: true,
              // expanded: true,
              collapseOnTextTap: true,
              linkColor: const Color.fromARGB(255, 155, 155, 155),
              style: TextStyle(
                height: 1.44,
                fontSize: 15,
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

class Poster extends StatelessWidget {
  const Poster({super.key, required this.poster});
  final String poster;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          margin: EdgeInsets.fromLTRB(0, 19, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("행사 포스터", style: TextStyle (
                  fontSize: 17.5,
                  color: Colors.black,
                  fontVariations: <FontVariation>[
                    FontVariation('wght', 700),
                  ],
                )),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                margin: EdgeInsets.fromLTRB(0, 23, 0, 26),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.network(poster,
                      errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/img_error_poster.jpg');
                        }
                    )
                  )
                )
            ],
          ),
        ),
      ],
    );
  }
}

class EtcInfo extends StatelessWidget {
  const EtcInfo({super.key, required this.tel, required this.homepage, required this.telname});

  final String tel;
  final String homepage;
  final String telname;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 42),
      margin: EdgeInsets.fromLTRB(0, 19, 0, 0),
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 22),
            child: Text("기타 정보", style: TextStyle (
              fontSize: 17.5,
              color: Colors.black,
              fontVariations: <FontVariation>[
                FontVariation('wght', 700),
              ],
            )),
          ),
          if (homepage.isNotEmpty)
            Container(
              margin: EdgeInsets.fromLTRB(3.5, 0, 3.5, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text("행사 홈페이지", style: TextStyle(
                      fontSize: 15.5,
                      color: Color(0xff757575),
                      fontVariations: <FontVariation>[
                        FontVariation('wght', 420),
                      ],
                    )),
                  ),
                  // Expanded(child: Container( color: const Color.fromARGB(255, 12, 153, 42),)),
                  Expanded(
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 3),
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end, text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () async {
                                        try {
                                          if (!await launchUrl(Uri.parse(homepage))) {
                                            throw Exception('Could not launch $homepage');
                                          }
                                        } catch(e) {
                                          printLog(e);
                                        }
                                      },
                                      child: Container(
                                        width: 17,
                                        // padding: EdgeInsets.only(right: 3),
                                        margin: EdgeInsets.only(bottom: 1),
                                        child: FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, color: Color.fromARGB(255, 81, 111, 243), size: 13)
                                      ),
                                    )
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        try {
                                          if (!await launchUrl(Uri.parse(homepage))) {
                                            throw Exception('Could not launch $homepage');
                                          }
                                        } catch(e) {
                                          printLog(e);
                                        }
                                      },
                                    text:  homepage,
                                    style: TextStyle(
                                      fontSize: 16,
                                      decoration: TextDecoration.underline,
                                      color: Color.fromARGB(255, 81, 111, 243),
                                      fontVariations: <FontVariation>[
                                        FontVariation('wght', 420),
                                      ],
                                    ),
                                  ),
                                ]
                            )),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          if (telname.isNotEmpty)
            Container(
              margin: EdgeInsets.fromLTRB(3.5, 0, 3.5, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50,
                    child: Text("전화명", style: TextStyle(
                      fontSize: 15.5,
                      color: Color(0xff757575),
                      fontVariations: <FontVariation>[
                        FontVariation('wght', 420),
                      ],
                    )),
                  ),
                  Expanded(
                    child: Text(
                      telname,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 56, 56, 56),
                        fontVariations: <FontVariation>[
                          FontVariation('wght', 420),
                        ],
                      )
                    ),
                  )
                ],
              ),
            ),
          if (tel.isNotEmpty)
            Container(
              margin: EdgeInsets.fromLTRB(3.5, 0, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 66,
                    child: Text("전화번호", style: TextStyle(
                      fontSize: 15.5,
                      color: Color(0xff757575),
                      fontVariations: <FontVariation>[
                        FontVariation('wght', 420),
                      ],
                    )),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 3),
                            child: RichText(
                              textAlign: TextAlign.end, text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () async {
                                        try {
                                          if (!await launchUrl(Uri.parse(homepage))) {
                                            throw Exception('Could not launch $homepage');
                                          }
                                        } catch(e) {
                                          printLog(e);
                                        }
                                      },
                                      child: Container(
                                        width: 17.5,
                                        margin: EdgeInsets.only(bottom: 1),
                                        child: FaIcon(Icons.call, color: Color.fromARGB(255, 56, 56, 56), size: 15)
                                      ),
                                    )
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        try {
                                          if (!await launchUrl(Uri(scheme: "tel", path: tel))) {
                                            throw Exception('Could not launch $tel');
                                          }
                                        } catch(e) {
                                          printLog(e);
                                        }
                                      },
                                    text: tel,
                                    style: TextStyle(
                                      fontSize: 16,
                                      decoration: TextDecoration.underline,
                                      color: Color.fromARGB(255, 56, 56, 56),
                                      fontVariations: <FontVariation>[
                                        FontVariation('wght', 420),
                                      ],
                                    ),
                                  ),
                                ]
                            )),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}


class Carousel extends StatefulWidget {
  const Carousel({super.key, required this.imgList, required this.fit, required this.indexOption});
  final List imgList;
  final BoxFit fit;
  final int indexOption;
  // final double h;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  List imgList = [];
  int _current = 0;
  BoxFit fit = BoxFit.cover;
  int indexOption = 1;
  // double h = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    imgList = widget.imgList;
    fit = widget.fit;
    indexOption = widget.indexOption;
    // h = widget.h;
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
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
                      fit: fit,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/img_error.jpg',
                        width: double.maxFinite,
                        fit: fit
                        );
                      },
                    );
                  },
                );
              }).toList(),
          options: CarouselOptions(
            height: double.maxFinite,
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
        if ( indexOption == 1 )
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
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
          ),
        if ( indexOption == 2 )
          Positioned(
            bottom: -26,
            
            child: Container(
              // margin: EdgeInsets.only(top: 20),
              width: 48,
              height: 21.7,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromARGB(207, 15, 15, 15),
                borderRadius: BorderRadius.circular(9)
              ),
              // padding: EdgeInsets.fromLTRB(5.3, 0.2, 5.2, 0.2),
              child: Text("${_current+1} / ${imgList.length}",
                style: TextStyle(
                  fontSize: 14,
                  color: const Color.fromARGB(255, 226, 226, 226),
                  fontVariations: <FontVariation>[
                  const FontVariation('wght', 400),
                ],
                  ),
              )
            ),
          ),
      ],
    );
  }
}