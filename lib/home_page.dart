import 'package:carousel_slider/carousel_slider.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void printLog(e) {
  debugPrint(e.toString());
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
} 

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage> {

  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  @override
  bool get wantKeepAlive => true; 

  getRecmdList() async {
    //var docLength;
    List<List> preIds = [];
    List<String> listTitles = [];
    try { 
      final recmdSnapshot = await _firebase.collection('Recommended_festivals').get();
      for (var doc in recmdSnapshot.docs) {
        try {
          preIds.add(doc["pre_ids"]);
          listTitles.add(doc["title"]);
        }catch(e){
          printLog(e);
        }
      }
    } catch(e){
      printLog(e);
    }
    printLog(preIds);
    printLog(listTitles);
    return {"length": listTitles.length, "list_titles": listTitles, "pre_ids": preIds};
  }

  Future<Map> getRecmdData() async {
    
    var recmdListData = await getRecmdList();
    // var recmdPreIds = recmdListData["pre_ids"];
    List data = [];
    List _list = [];
    for(int i=0; i < recmdListData["length"]; i++ ) {
      _list = [];
      for(var _id in recmdListData["pre_ids"][i]) {
        await _firebase.collection("festivals_main_data").doc(_id.toString()).get().then((doc){
          _list.add(
            {
              "title": doc["title"],
              "img": doc["firstimage"],
              "locate": "${doc["addr1"].toString().split(" ")[0]} ${doc["addr1"].toString().split(" ")[1]}",
              "start_date": doc["eventstartdate"],
              "end_date": doc["eventenddate"],
              "price": "일부 유료"
            }
          );
        });
      }
      data.add(_list);
    }
    printLog(data);
    return {"data": data, "list_titles": recmdListData["list_titles"]};
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
          future: getRecmdData(),
          builder: (context, snapshot) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                if(snapshot.connectionState != ConnectionState.done) {
                  return Text("loading");
                }else {
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 7),
                        child: Carousel(),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.882,
                        child: ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: snapshot.data?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return RecmdList(recmdData: snapshot.data?["data"][index], listTitle: snapshot.data?["list_titles"][index]);
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
                childCount: 1,
              ),
            );
          }
        ),
      ],
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
    'assets/test1.png',
    'assets/test1.png',
    'assets/test1.png',
    'assets/test1.png'
  ];

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
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Skeletonizer(
                        effect: SoldColorEffect(),
                        enabled: false,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.76,
                          child: Skeleton.leaf(
                            child: Stack(
                              // fit: StackFit.expand,
                              alignment: Alignment.bottomCenter,
                              children: [
                                Image.asset(
                                  img,
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
                                        const Color.fromRGBO(0, 0, 0, 0.04),
                                        const Color.fromRGBO(0, 0, 0, 0.294),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "04.01 - 12.24",
                                        style: TextStyle(
                                          fontSize: 19,
                                          color: const Color(0xffF9F9F9),
                                          fontVariations: <FontVariation>[
                                            FontVariation('wght', 380),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "가파도청보리축제${_current}",
                                        style: TextStyle(
                                          fontSize: 28,
                                          color: const Color(0xffFDFDFD),
                                          fontVariations: <FontVariation>[
                                            const FontVariation('wght', 440),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding: EdgeInsets.fromLTRB(
                                          9,
                                          0.6,
                                          9,
                                          0.6,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          "개최중",
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
            height: 326,
            viewportFraction: 0.825,
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
          margin: EdgeInsets.fromLTRB(0, 14, 0, 20),
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
        )
      ],
    );
  }
}

class RecmdListCard extends StatelessWidget {
  final Map cardData;

  const RecmdListCard({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
      width: MediaQuery.of(context).size.width*0.765,
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
            ),
          ),
          Expanded(
            child: Container(
              // color: Colors.black,
              padding: EdgeInsets.only(bottom: 0.5),
              margin: EdgeInsets.only(left: 16),
              constraints: BoxConstraints(
                minHeight: 88
              ),
              // height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 27.6,
                    child: Text(
                      cardData["title"],
                      style: TextStyle(
                        fontSize: 16.5,
                        fontVariations: <FontVariation>[FontVariation("wght", 700)],
                      ),
                    ),
                  ),
                  Text(
                    cardData["locate"],
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12.5,
                      color: greyColor1,
                      fontVariations: <FontVariation>[FontVariation("wght", 500)],
                    ),
                  ),
                  Text(
                    "${cardData["start_date"]} ~ ${cardData["end_date"]}",
                    style: TextStyle(
                      // overflow: TextOverflow.ellipsis,
                      fontSize: 12.5,
                      color: greyColor1,
                      fontVariations: <FontVariation>[
                        FontVariation("wght", 500),
                      ],
                    ),
                  ),
                  Text(
                    cardData["price"],
                    style: TextStyle(
                      fontSize: 12.5,
                      color: orangeColor2,
                      // backgroundColor: Colors.amber,
                      fontVariations: <FontVariation>[FontVariation("wght", 450)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecmdList extends StatelessWidget {
  final List recmdData;
  
  final String listTitle;

  const RecmdList({super.key, required this.recmdData, required this.listTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 27, 0, 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(listTitle, style: TextStyle(
                    fontSize: 19,
                    fontVariations: <FontVariation> [
                      FontVariation("wght", 720)
                    ]
                )),
                Row(children: [
                    Text("더보기 ", style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xff707070),
                      fontVariations: <FontVariation> [
                        FontVariation("wght", 500)
                      ]
                    )), 
                    FaIcon(FontAwesomeIcons.chevronRight, color: const Color(0xff707070),size: 13,)
                  ]
                ),
              ],
            ),
          ),
          Column(
            children: [
              RecmdListCard(cardData: recmdData[0]),
              RecmdListCard(cardData: recmdData[1]),
              RecmdListCard(cardData: recmdData[2])
            ],
          )
        ],
      ),
    );
  }
}