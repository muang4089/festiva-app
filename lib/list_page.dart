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
          toolbarHeight: 70,
          scrolledUnderElevation: 10,
          // pinned: true,
          title: SearchBar(
            leading: FaIcon(FontAwesomeIcons.magnifyingGlass,color: const Color(0xffE47C49),size: 29),
            trailing: [Icon(Icons.filter_list_rounded,color: const Color(0xff6D6D6D),size: 28)],
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            elevation: WidgetStatePropertyAll(0),
            constraints: BoxConstraints(minHeight: 44),
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
          elevation: 30,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          centerTitle: true,
          floating: true,
          // snap: true,
        ),
      ],
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