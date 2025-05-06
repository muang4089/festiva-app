import 'package:festiva/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inner_shadow_widget/inner_shadow_widget.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
            leading: FaIcon(FontAwesomeIcons.magnifyingGlass,color: const Color(0xffE47C49),size: 29),
            trailing: [Icon(Icons.filter_list_rounded,color: const Color(0xff6D6D6D),size: 28)],
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            overlayColor: WidgetStatePropertyAll(Colors.white),
            elevation: WidgetStatePropertyAll(0),
            constraints: BoxConstraints(minHeight: 46),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)
            )),
            side: WidgetStatePropertyAll(
              BorderSide(
                color: Color.fromARGB(255, 218, 218, 218),
                width: 1.4
              )
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 70,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return ListCard();
          }, childCount: 10),
        ),
      ],
    );
  }
}

class ListCard extends StatelessWidget {
  const ListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.035),
      // color: Colors.amber,
      // width: 80,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/test2.png",
              height: 207,
              width: double.maxFinite,
              fit: BoxFit.cover,
            )
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                constraints: BoxConstraints(
                  minHeight: 93
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "경남고성공룡세계엑스포",
                      style: TextStyle(
                        fontSize: 19,
                        // color: const Color.fromARGB(255, 0, 0, 0),
                        fontVariations: <FontVariation>[
                          const FontVariation('wght', 720),
                        ],
                      ),
                    ),
                    Text(
                      "경기도 경남시",
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 13.5,
                        color: greyColor1,
                        fontVariations: <FontVariation>[FontVariation("wght", 500)],
                      ),
                    ),
                    Text(
                      "2025.05.01 ~ 2025.06.21",
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 13.5,
                        color: greyColor1,
                        fontVariations: <FontVariation>[FontVariation("wght", 490)],
                      ),
                    ),
                    Text(
                      "부분유료",
                      style: TextStyle(
                        fontSize: 13.5,
                        color: orangeColor2,
                        // backgroundColor: Colors.amber,
                        fontVariations: <FontVariation>[FontVariation("wght", 450)],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2.5),
                padding: EdgeInsets.fromLTRB(8, 1, 8, 1),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Color(0xffCE2C52)
                  ),
                  borderRadius: BorderRadius.circular(11)
                ),
                child: Text(
                          "계최 중",
                          style: TextStyle(
                            fontSize: 13.4,
                            color: Color(0xffCE2C52),
                            // backgroundColor: Colors.amber,
                            fontVariations: <FontVariation>[FontVariation("wght", 610)],
                          ),
                        ),
                )
            ],
          ),
          SizedBox(height: 44,)
        ],
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