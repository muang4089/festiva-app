import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:festiva/detail_page.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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
  var docCount;
  bool islast = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    listScrollCtrl.addListener(_listScrollCtrl);
    getMainDataList(0, 1);
  }
  String lastdocId = "0";
  Future<Map> getMainDataList(index, limit) async {
    final QuerySnapshot<Map<String, dynamic>> listSnapshot;
    List<Map> festival = [];

    try {
      if (index == 0) {
        globalFestivals = [];
        printLog("getfirst");
        listSnapshot = await _firebase.collection('festivals_main_data').limit(5).get();
        await _firebase.collection('festivals_main_data').count().get().then((snapshot) => {
          docCount = snapshot.count
        });
        printLog(docCount);
      } else {
        printLog("getmore");
        var lastdoc = await _firebase.collection("festivals_main_data").doc(lastdocId).get();
        listSnapshot = await _firebase.collection('festivals_main_data').startAfterDocument(lastdoc).limit(5).get();
      }
      for (var doc in listSnapshot.docs) {
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
            "img": doc["firstimage"],
            "locate": "${doc["addr1"].toString().split(" ")[0]} ${doc["addr1"].toString().split(" ")[1]}",
            "start_date": startDate,
            "end_date": endDate,
            "price": doc["price"],
            "state": stateMsg,
            "color": textColor,
            "id": doc["contentid"]
          });
          lastdocId = doc["contentid"];
          // printLog(festival);
        } catch (e) {
          printLog(e);
        }
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

  bool paginationLock = true;
  void _listScrollCtrl() {
    final maxScroll = listScrollCtrl.position.maxScrollExtent;
    final currentScroll = listScrollCtrl.position.pixels;

    if (maxScroll - currentScroll == 0 && !paginationLock && !islast) {
      printLog(islast);
      getMainDataList(1, 5);
      paginationLock = true;
    }
    printLog("$maxScroll  $currentScroll $paginationLock");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      controller: listScrollCtrl,
      slivers: [
        SliverAppBar(
          toolbarHeight: 65,
          scrolledUnderElevation: 10,
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          surfaceTintColor: Colors.white,
          centerTitle: true,
          floating: true,
          // snap: true,
          // pinned: true,
          title: SearchBar(
            hintText: "검색",
            leading: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              color: const Color(0xffE47C49),
              size: 29,
            ),
            trailing: [
             
              //         TextButton(
              //   onPressed: (){getMainDataList(1,5);},
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
        SliverToBoxAdapter(child: SizedBox(height: 70)),
        
        SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (1 != 1) {
                  return Text("loading");
                } else {
                  return ListCard(
                    festivaData: globalFestivals[index]
                  );
                }
              }, childCount: globalFestivals.length),
            )
        // FutureBuilder(
        //   future: getMainDataList(0,5),
        //   builder: (context, snapshot) {
        //     return SliverList(
        //       delegate: SliverChildBuilderDelegate((context, index) {
        //         if (snapshot.connectionState != ConnectionState.done) {
        //           return Text("loading");
        //         } else {
        //           return ListCard(
        //             festivaData: snapshot.data?["festivals"][index]
        //           );
        //         }
        //       }, childCount: 5),
        //     );
        //   },
        // ),
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
          builder: (context) => DetailPage(mainData: festivaData, firebase: _firebase,)
          )
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 22, 0, 22),
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
                height: 212,
                width: double.maxFinite,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/img_error.jpg',
                    height: 212,
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
                  child: Container(
                    constraints: BoxConstraints(minHeight: 98,maxWidth: double.maxFinite),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
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
                        Text(
                          festivaData["locate"],
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 13.5,
                            color: greyColor1,
                            fontVariations: <FontVariation>[
                              FontVariation("wght", 500),
                            ],
                          ),
                        ),
                        Text(
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
                        Text(
                          festivaData["price"],
                          style: TextStyle(
                            fontSize: 13.5,
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
                Container(
                  margin: EdgeInsets.only(top: 2.5),
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
// Padding(
//             padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//             child: Container(
//               margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
//               decoration: BoxDecoration(
//                 boxShadow: [BoxShadow(
//                   color: Color.fromARGB(255, 218, 218, 218),
//                   blurRadius: 4,
//                   // spreadRadius: 0.3
//                 )],
//                 borderRadius: BorderRadius.circular(10)
//               ),
//               // height: 40,
//               child: TextField(
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontVariations: <FontVariation>[
//                       const FontVariation('wght', 400),
//                     ],
//                   ),
//                 decoration: InputDecoration(
//                   isDense: true,
//                   fillColor: const Color(0xffFEFEFE),
//                   filled: true,
            
//                   hintText: "검색",
//                   hintStyle: TextStyle(
//                     fontSize: 16,
//                     color: const Color.fromARGB(255, 123, 123, 123),
//                     fontVariations: <FontVariation>[
//                       const FontVariation('wght', 500),
//                     ],
//                   ),
//                   prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass,color: const Color(0xffE47C49),size: 27,),
//                   suffixIcon: Icon(Icons.filter_list_rounded,color: const Color(0xff6D6D6D), size: 27,),
//                   enabledBorder: OutlineInputBorder(
//                     // borderSide: BorderSide.none,
//                     borderSide: BorderSide(
//                       color: Color(0xffE2E2E2),
//                       width: 1
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     // borderSide: BorderSide.none,
//                     borderSide: BorderSide(
//                       color: Color(0xffE2E2E2),
//                       width: 1
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),            
//                 // textAlign: TextAlign.center,
//               ),
//             ),
//           ),