import 'package:festiva/detail_page.dart';
import 'package:festiva/global_variable.dart';
import 'package:festiva/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ApplinkHandler extends StatelessWidget {
  final dynamic id;
  final dynamic firebase;
  const ApplinkHandler({super.key, required this.id, required this.firebase});
  Future<Map> getMain() async {
    var mainData = {};
    try {
      await firebase.collection('APP_DATA').doc("running_databases").get().then((snapshot) async {
          targetDatabases["main_db"] = "festivals_main_data_${snapshot.data()?['main']}";
          targetDatabases["detail_db"] = "festivals_detail_data_${snapshot.data()?['detail']}";

          await firebase.collection(targetDatabases["main_db"]).doc(id).get().then((snapshot) {
            try {
              String startDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventstartdate"] ?? (throw FormatException('eventstartdate error $id'))));
              String endDate = DateFormat("yyyy.MM.dd").format(DateTime.parse(snapshot.data()?["eventenddate"] ?? (throw FormatException('eventenddate error $id'))));
              mainData = {
                "title": snapshot.data()?["title"] ?? (throw FormatException('title error $id')),
                "img": snapshot.data()?["firstimage"] ?? "",
                "locate": "${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[0]} ${(snapshot.data()?["addr1"] ?? "").isEmpty ? "" : snapshot.data()?["addr1"].toString().split(" ")[1]}",
                "locate_full": snapshot.data()?["addr1"] ?? "",
                "start_date": startDate,
                "end_date": endDate,
                "price": snapshot.data()?["price"].replaceAll("<br>", "\n") ?? (throw FormatException('price error $id')),
                "id": snapshot.data()?["contentid"] ?? (throw FormatException('contentid error $id')),
                "mapx": snapshot.data()?["mapx"] ?? "",
                "mapy": snapshot.data()?["mapy"] ?? ""
              };

              GlobalVariable.navState.currentState?.pushReplacement( MaterialPageRoute(
                builder: (context) => DetailPage(mainData: mainData, firebase: firebase),
              ));
              return mainData;
            } catch (e) {
              throw FormatException('data parsing error $id: $e');
            }
          });
        });
    } catch (e) {
      GlobalVariable.navState.currentState?.pop();
    }
    return mainData;
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getMain(),
      builder: (context, snapshot) {
        return Container(
          // color: Colors.green,
        );
      },
    );
  }
}