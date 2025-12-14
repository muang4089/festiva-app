import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:festiva/detail_page.dart';
import 'package:festiva/home_page.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void printLog(e) {
  debugPrint(e.toString());
}

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

late FirebaseFirestore firebase;

class _LikePageState extends State<LikePage> {
  bool islast = false;
  bool paginationLock= true;
  final listScrollCtrl = ScrollController();
  List<Map> festival = [];
  int likesIndex = 0;
  List<List<String>> chunkedLikes = [];
  final today = DateFormat("yyyy.MM.dd").format(DateTime.now());
  List<String>? likes = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    listScrollCtrl.addListener(_listScrollCtrl);
    firebase = FirebaseFirestore.instance;
    getFistData();

  }

  void getFistData() async {
    festival = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    likes = prefs.getStringList("likes");
    // printLog(isLoaded);
      // printLog(isLoaded);
    if (likes != null && likes!.isNotEmpty) {
      chunkedLikes = [];
      int chunkSize = 8;
      for (int i = 0; i < likes!.length; i += chunkSize) {
         int end = (i + chunkSize < likes!.length) ? i + chunkSize : likes!.length;
        chunkedLikes.add(likes!.sublist(i, end));
      }
      printLog(chunkedLikes);
      for (String id in chunkedLikes[0]) {
        await firebase.collection(targetDatabases["main_db"]).doc(id).get().then((snapshot) {
          try {
            String startDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventstartdate"] ?? (throw FormatException('eventstartdate error $id'))));
            String endDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventenddate"] ?? (throw FormatException('eventenddate error $id'))));
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
              stateMsg = "종료";
              textColor = Color.fromARGB(255, 129, 129, 129);
            }
            festival.add({
                "title": snapshot.data()?["title"] ?? (throw FormatException('title error $id')),
                "img": snapshot.data()?["firstimage"] ?? "",
                "locate": "${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[0]} ${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[1]}",
                "locate_full": snapshot.data()?["addr1"] ?? "",
                // "locate2": snapshot.data()?["addr2"] ?? "",
                "start_date": startDate,
                "end_date": endDate,
                "price": snapshot.data()?["price"].replaceAll("<br>", "\n") ?? (throw FormatException('price error $id')),
                "state": stateMsg,
                "color": textColor,
                "id": snapshot.data()?["contentid"] ?? (throw FormatException('contentid error $id')),
                "mapx": snapshot.data()?["mapx"] ?? "",
                "mapy": snapshot.data()?["mapy"] ?? ""
              });
            printLog(festival.length);
          } catch (e) {
            printLog(e);
          }
        });
      }
      setState(() {
        isLoaded = true;
        paginationLock = false;
      });
    } else {
      setState(() {
        isLoaded = true;
      });
    }
  }

    Future<void> _listScrollCtrl() async {
    final maxScroll = listScrollCtrl.position.maxScrollExtent;
    final currentScroll = listScrollCtrl.position.pixels;
    printLog("$maxScroll  $currentScroll $paginationLock");
    if (maxScroll - currentScroll == 0 && !paginationLock && !islast) {
      paginationLock = true;
      likesIndex++;
      for (String id in chunkedLikes[likesIndex]) {
        await firebase.collection(targetDatabases["main_db"]).doc(id).get().then((snapshot) {
          try {
            String startDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventstartdate"] ?? (throw FormatException('eventstartdate error $id'))));
            String endDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventenddate"] ?? (throw FormatException('eventenddate error $id'))));
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
              stateMsg = "종료";
              textColor = Color.fromARGB(255, 129, 129, 129);
            }
            festival.add({
                "title": snapshot.data()?["title"] ?? (throw FormatException('title error $id')),
                "img": snapshot.data()?["firstimage"] ?? "",
                "locate": "${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[0]} ${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[1]}",
                "locate_full": snapshot.data()?["addr1"] ?? "",
                "start_date": startDate,
                "end_date": endDate,
                "price": snapshot.data()?["price"].replaceAll("<br>", "\n") ?? (throw FormatException('price error $id')),
                "state": stateMsg,
                "color": textColor,
                "id": snapshot.data()?["contentid"] ?? (throw FormatException('contentid error $id')),
                "mapx": snapshot.data()?["mapx"] ?? "",
                "mapy": snapshot.data()?["mapy"] ?? ""
              });
            printLog(festival.length);
            if(festival.length >= likes!.length) islast = true;
          } catch (e) {
            printLog(e);
          }
        });
      }
      setState(() {
        paginationLock = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      scrolledUnderElevation: 0,
      toolbarHeight: 50,
      centerTitle: true,
      backgroundColor: Colors.white,
        title: Text("찜 목록", style: TextStyle(
          fontSize: 21,
          fontVariations: <FontVariation>[
            const FontVariation('wght', 690),
          ],
        )),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        controller: listScrollCtrl,
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.937,
            child: Column(
              children: [
                if((likes == null || likes!.isEmpty) && isLoaded)
                Container(
                  // color: Colors.amber,
                  margin: EdgeInsets.only(top: 38),
                  child: Text(
                    "상제정보 페이지의 ♡를 눌러 추가할 수 있어요",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.3
                    )
                  )
                ),
                if(likes != null && likes!.isNotEmpty)
                Container(
                  margin: EdgeInsets.fromLTRB(0, 32, 0, 16),
                  width: double.maxFinite,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 14.4,
                        fontVariations: <FontVariation>[
                          const FontVariation('wght', 650),
                        ],
                      ),
                      children: [
                        TextSpan(
                          text: "전체 "
                        ),
                        TextSpan(
                          text: likes!.length.toString(),
                          style: TextStyle(
                            color: orangeColor1
                          )
                        ),
                        TextSpan(
                          text: "개"
                        )
                      ]
                    )
                  ),
                ),
                if(likes != null && likes!.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: festival.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        LikeListCard(festivaData: festival[index]),
                        SizedBox(height: 24.5)
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}

class LikeListCard extends StatelessWidget {
  final Map festivaData;
  const LikeListCard({super.key, required this.festivaData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => DetailPage(mainData: festivaData, firebase: firebase)
        ));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              festivaData["img"],
              fit: BoxFit.cover,
              height: 124,
              width: 124,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                "./assets/img_error_mini.jpg",
                fit: BoxFit.cover,
                height: 124,
                width: 124,
              ),
            )
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    festivaData["title"],
                    style: TextStyle(
                      fontSize: 18,
                      overflow: TextOverflow.clip,
                      // color: const Color.fromARGB(255, 0, 0, 0),
                      fontVariations: <FontVariation>[
                        const FontVariation('wght', 720),
                      ],
                    ),
                  ),
                  if (festivaData["locate"].trim().isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 4.2),
                      child: Text(
                        festivaData["locate"],
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 13.3,
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
                        fontSize: 13.3,
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
                      festivaData["state"],
                      style: TextStyle(
                        fontSize: 13.5,
                        color: festivaData["color"],
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
          )
        ],
      ),
    );
  }
}