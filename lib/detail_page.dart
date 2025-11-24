import 'package:carousel_slider/carousel_slider.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  Future<dynamic> getDetailData() async {
    var detailData = await firebase.collection(targetDatabases["detail_db"]).doc(mainData["id"]).get();
    printLog(detailData["sponsor1tel"]);
    return detailData;
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
                        Text("경남고성공룡세계엑스포",style: TextStyle (
                          fontSize: 23.9,
                          color: Colors.black,
                          fontVariations: <FontVariation>[
                            const FontVariation('wght', 700),
                          ],
                        )),
                        Container(
                          margin: EdgeInsets.fromLTRB(2, 3.3, 0, 15),
                          child: Text("경남 고성군 | (재)고성문화관광재단",style: TextStyle (
                            fontSize: 14.5,
                            color: Color(0xff313131),
                            fontVariations: <FontVariation>[
                              const FontVariation('wght', 500),
                            ],
                          )),
                        ),
                        Divider(thickness: 1, color: Color(0xffAFAFAF),indent: 9,endIndent: 9,),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 16, 0, 14.5),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.solidCalendar, color: orangeColor1, size: 21.5),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Text("2025.04.13 ~ 2025.05.23",style: TextStyle (
                                    fontSize: 14.7,
                                    color: Colors.black,
                                    fontVariations: <FontVariation>[
                                      const FontVariation('wght', 440),
                                    ],
                                  )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 14.5),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.solidClock, color: orangeColor1, size: 19.5),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Text("10:00~21:00(과학체험부스10:00~19:00 / 별음악회, 시낭송: 19:00~21:00)",style: TextStyle (
                                    height: 1.3,
                                    fontSize: 14.7,
                                    color: Colors.black,
                                    fontVariations: <FontVariation>[
                                      const FontVariation('wght', 440),
                                    ],
                                  )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 14.5),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.wonSign, color: orangeColor1, size: 19),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Text("부분 유료",style: TextStyle (
                                    fontSize: 14.7,
                                    color: Colors.black,
                                    fontVariations: <FontVariation>[
                                      const FontVariation('wght', 440),
                                    ],
                                  )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          // color: Colors.amber,
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.locationDot, color: orangeColor1, size: 25,),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Text("경상남도 고성군 당항만로 1116 당항포관광지",style: TextStyle (
                                    fontSize: 14.7,
                                    color: Colors.black,
                                    fontVariations: <FontVariation>[
                                      const FontVariation('wght', 440),
                                    ],
                                  )),
                                ),
                              )
                            ],
                          ),
                        ),
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