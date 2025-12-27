import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:festiva/detail_page.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';

void printLog(e) {
  debugPrint(e.toString());
}
final today = DateFormat("yyyy.MM.dd").format(DateTime.now());
// final today = DateFormat("yyyy.MM.dd").format(DateTime.parse("20250529"));
final FirebaseFirestore _firebase = FirebaseFirestore.instance;

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with AutomaticKeepAliveClientMixin<ListPage> {
  final listScrollCtrl = ScrollController();
  List<Map> globalFestivals = [];
  bool paginationLock = true;
  bool isSearch = false;
  var ids = [];
  var docCount = 0;
  var titles;

  bool islast = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    listScrollCtrl.addListener(_listScrollCtrl);
    getMainDataList(0, 1);
  }

  Future<void> searchTitle(text)  async {
    searchIndex = 0;
    searchTargetIndex = 5;
    isSearch = true;
    ids = [];
    setState(() {
      globalFestivals = [];
    });
    if (titles == null) {
      titles = await _firebase.collection("titles").doc(targetDatabases["titles_db"]).get();
      printLog("get titles");
    } else {
      printLog("already titles");
    }
    titles.data().forEach((key, value) {
      if (value[0].toLowerCase().contains(text.trim().toLowerCase())) {
        ids.add(value[1]);
        // printLog(value[0]);
      }
    });
    getSearchResult();
  }
  
  int searchIndex = 0;
  int searchTargetIndex = 5;
  Future<void> getSearchResult() async {
    List<Map> festival = [];

    if (searchIndex < ids.length) {
      if (ids.isNotEmpty) {
        if (true) {
          while (searchIndex < searchTargetIndex) {
            if (searchIndex < ids.length) {
              printLog("test");
              await _firebase.collection(targetDatabases["main_db"]).doc(ids[searchIndex]).get().then((snapshot) {
                try {
                  String startDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventstartdate"] ?? (throw FormatException('eventstartdate error ${ids[searchIndex]}'))));
                  String endDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventenddate"] ?? (throw FormatException('eventenddate error ${ids[searchIndex]}'))));
                  int state = today.compareTo(startDate)+today.compareTo(endDate);
                  String stateMsg = "";
                  Color textColor = Colors.white;
                  if (state == -2) { // -2: before | -1,0,1: holding | 2: after
                    stateMsg = "개최 예정";
                    textColor = Color.fromARGB(255, 224, 153, 48);
                  } else if (state == -1 || state == 0 || state == 1) {
                    stateMsg = "개최 중";
                    textColor = Color.fromARGB(255, 206, 44, 82);
                  } else if (state == 2) {
                    stateMsg = " 종료 ";
                    textColor = Color.fromARGB(255, 129, 129, 129);
                  }
                  festival.add({
                    "title": snapshot.data()?["title"] ?? (throw FormatException('title error ${ids[searchIndex]}')),
                    "img": snapshot.data()?["firstimage"] ?? "",
                    "locate": "${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[0]} ${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[1]}",
                    "locate_full": snapshot.data()?["addr1"] ?? "",
                    // "locate2": snapshot.data()?["addr2"] ?? "",
                    "start_date": startDate,
                    "end_date": endDate,
                    "price": snapshot.data()?["price"].replaceAll("<br>", "\n") ?? (throw FormatException('price error ${ids[searchIndex]}')),
                    "state": stateMsg,
                    "color": textColor,
                    "id": snapshot.data()?["contentid"] ?? (throw FormatException('contentid error ${ids[searchIndex]}')),
                    "mapx": snapshot.data()?["mapx"] ?? "",
                    "mapy": snapshot.data()?["mapy"] ?? ""
                  });
                  // printLog(festival);
                } catch (e) {
                  printLog(e);
                }
              });
            }
            searchIndex++;
          }
          searchTargetIndex += 5;
        }
      }
      paginationLock = false;
      setState(() {
        globalFestivals.addAll(festival);
        printLog(festival);
      });
    }
  }

  String lastdocId = "";
  Future<Map> getMainDataList(index, limit) async {
    List<Map> festival = [];

    void packagingData(data) {
        for (var doc in data.docs) {
          try {
            String startDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(doc["eventstartdate"]));
            String endDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(doc["eventenddate"]));
            int state = today.compareTo(startDate)+today.compareTo(endDate);
            String stateMsg = "";
            Color textColor = Colors.white;
            if (state == -2) { // -2: before | -1,0,1: holding | 2: after
              stateMsg = "개최 예정";
              textColor = Color.fromARGB(255, 224, 153, 48);
            } else if (state == -1 || state == 0 || state == 1) {
              stateMsg = "개최 중";
              textColor = Color.fromARGB(255, 206, 44, 82);
            } else if (state == 2) {
              stateMsg = " 종료 ";
              textColor = Color.fromARGB(255, 129, 129, 129);
            }
            festival.add({
              "title": doc["title"],
              "img": doc.data()["firstimage"] ?? "",
              "locate": "${(doc.data()["addr1"] ?? "").isEmpty ? "" : doc.data()["addr1"].toString().split(" ")[0]} ${(doc.data()["addr1"] ?? "").isEmpty ? "" : doc.data()["addr1"].toString().split(" ")[1]}",
              "locate_full": doc.data()["addr1"] ?? "",
              // "locate2": doc.data()["addr2"] ?? "",
              "start_date": startDate,
              "end_date": endDate,
              "price": doc["price"].replaceAll("<br>", "\n"),
              "state": stateMsg,
              "color": textColor,
              "id": doc["contentid"],
              "mapx": doc.data()["mapx"] ?? "",
              "mapy": doc.data()["mapy"] ?? "",
            });
            lastdocId = doc["contentid"];
            // printLog(festival);
          } catch (e) {
            printLog(e);
          }
        } 
      }

    try {
      if (index == 0) {
        globalFestivals = [];
        lastdocId = "";
        printLog("get first");
        await _firebase.collection(targetDatabases["main_db"]).orderBy("state", descending: true).orderBy("modifiedtime", descending: true).limit(10).get().then((snapshot) {
          packagingData(snapshot);
        });
        await _firebase.collection(targetDatabases["main_db"]).count().get().then((snapshot) => {
          docCount = snapshot.count!
        });
        // printLog(docCount);
      } else {
        printLog("get more");
        var lastdoc = await _firebase.collection(targetDatabases["main_db"]).doc(lastdocId).get();
        await _firebase.collection(targetDatabases["main_db"]).orderBy("state", descending: true).orderBy("modifiedtime", descending: true).startAfterDocument(lastdoc).limit(10).get().then((snapshot) {
          packagingData(snapshot);
        });
      }
    } catch (e) {
      printLog(e);
    }
    paginationLock = false;
    setState(() {
      globalFestivals.addAll(festival);
    });
    globalFestivals.length >= docCount ? islast = true : islast = false;
    // printLog(globalFestivals);
    // printLog(globalFestivals.length);
    return {"length": festival.length, "festivals": globalFestivals};
  }
  void _listScrollCtrl() {
    final maxScroll = listScrollCtrl.position.maxScrollExtent;
    final currentScroll = listScrollCtrl.position.pixels;

    if (maxScroll - currentScroll == 0 && !paginationLock && !islast) {
      printLog(islast);
      !isSearch ? getMainDataList(1, 5) : getSearchResult();
      paginationLock = true;
    }
    // printLog("$maxScroll  $currentScroll $paginationLock");
    printLog(globalFestivals.length);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      controller: listScrollCtrl,
      slivers: [
        SliverAppBar(
          toolbarHeight: 76,
          scrolledUnderElevation: 10,
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          surfaceTintColor: Colors.white,
          centerTitle: true,
          // floating: true,
          // snap: true,
          // pinned: true,
          title: Container(
            margin: EdgeInsets.fromLTRB(0, 13, 0, 5),
            child: SearchBar(
              hintText: "검색",
              leading: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                color: const Color(0xffE47C49),
                size: 29,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  searchTitle(value);
                } else if (value.trim().isEmpty && isSearch) {
                  getMainDataList(0, 5);
                  isSearch = false;
                }
              },
              trailing: [
               
                //         TextButton(
                //   onPressed: (){
                //     getSearchResult();
                //   },
                //   child: Text('Disabled TextButton'),
                // ),
              ],
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              overlayColor: WidgetStatePropertyAll(Colors.white),
              elevation: WidgetStatePropertyAll(0),
              constraints: BoxConstraints(minHeight: 46),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              side: WidgetStatePropertyAll(
                BorderSide(color: Color.fromARGB(255, 218, 218, 218), width: 1.4),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 25)),
        
        SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (globalFestivals.isNotEmpty){ 
                  if(index % 8 != 0 || index == 0) {
                    return ListCard(
                      festivaData: globalFestivals[index]
                    ) ;
                  } else {
                    return Column(
                      children: [
                        NativeListAd(),
                        ListCard(
                          festivaData: globalFestivals[index]
                        )
                      ],
                    );
                  } 
                } else {
                  return Text("데이터가 없습니다");
                }
              }, childCount: globalFestivals.length),
            )
      ],
    );
  }
}
class ListCard extends StatelessWidget {
  final Map festivaData;
  const ListCard({super.key, required this.festivaData});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: const Color.fromARGB(255, 243, 243, 243),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => DetailPage(mainData: festivaData, firebase: _firebase)
          )
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 23, 0, 23),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.035,
        ),
        // color: Colors.amber,
        // width: 80,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                festivaData["img"],
                height: 210,
                width: double.maxFinite,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/img_error.jpg',
                    height: 210,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            SizedBox(height: 7.5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 15),
                        child: Text(
                          festivaData["title"],
                          style: TextStyle(
                            fontSize: 19.5,
                            overflow: TextOverflow.clip,
                            // color: const Color.fromARGB(255, 0, 0, 0),
                            fontVariations: <FontVariation>[
                              const FontVariation('wght', 720),
                            ],
                          ),
                        ),
                      ),
                      if (festivaData["locate"].trim().isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 4.2),
                          child: Text(
                            festivaData["locate"],
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 13.8,
                              color: greyColor1,
                              fontVariations: <FontVariation>[
                                FontVariation("wght", 520),
                              ],
                            ),
                          ),
                        ),
                      Container(
                        margin: EdgeInsets.only(top: 4.2),
                        child: Text(
                          "${festivaData["start_date"]} ~ ${festivaData["end_date"]}",
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 13.5,
                            color: greyColor1,
                            fontVariations: <FontVariation>[
                              FontVariation("wght", 460),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.2),
                        child: Text(
                          festivaData["price"].isEmpty? "가격정보가 없습니다" : festivaData["price"],
                          style: TextStyle(
                            fontSize: 13.5,
                            color: orangeColor2,
                            // backgroundColor: Colors.amber,
                            fontVariations: <FontVariation>[
                              FontVariation("wght", 470),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 2.6),
                  padding: EdgeInsets.fromLTRB(8, 1, 8, 1),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: festivaData["color"]),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    festivaData["state"],
                    style: TextStyle(
                      fontSize: 13.4,
                      color: festivaData["color"],
                      // backgroundColor: Colors.amber,
                      fontVariations: <FontVariation>[FontVariation("wght", 610)],
                    ),
                  ),
                ),
              ],
            ),
            // SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}

class NativeListAd extends StatefulWidget {
  const NativeListAd({super.key});

  @override
  State<NativeListAd> createState() => _NativeListAdState();
}

class _NativeListAdState extends State<NativeListAd> {

  late NativeAd _ad;
  bool isLoaded = false;
 
  @override
  void initState() {
    super.initState();
 
    _ad = NativeAd(
      adUnitId: dotenv.env["ADMOB_NATIVE_ID"].toString(),
      // adUnitId: "ca-app-pub-3940256099942544/2247696110",
      factoryId: "listTileAd",
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
        margin: EdgeInsets.fromLTRB(0, 15, 0, 13.5),
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.035),
        height: 358,
        width: double.infinity,
        child: AdWidget(ad: _ad),
      );
    } else {
      return const SizedBox(height: 386.5);
    }
  }
}