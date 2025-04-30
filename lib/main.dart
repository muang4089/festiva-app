import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:festiva/theme/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';

bool _loading = true;
void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: "Pretendard"
      ),
      home: Scaffold(
        floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: () {_loading = false;}),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
            title: SvgPicture.asset("assets/Logo.svg", width: 120),
            elevation: 0.0,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            centerTitle: true,
            ),
        body: HomePage()
      ),
      debugShowCheckedModeBanner: false,
    )
    );

}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
} 

class _HomePageState extends State<HomePage> {
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
    return SingleChildScrollView(
      child: Column(
        children: [
          carouselWidget(),
          carouselIndicator(),
          Container(
            width: 400,
            height: 700,
            child: Skeletonizer(
              enabled: _loading,
              child: Column(children: [
                Text("data"),
                Text("data"),
                Text("data")
              ],)
              ),
            ),
        ]
      ),
    );
  }

  Widget carouselWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: imgList.map(
        (img) {
          return Builder(
            builder: (context) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Skeletonizer(
                  effect: SoldColorEffect(

                    // highlightColor: const Color.fromARGB(255, 255, 255, 255)
                  ),
                  enabled: _loading,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.76,
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
                            decoration: BoxDecoration( gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color.fromRGBO(0, 0, 0, 0.04), Color.fromRGBO(0, 0, 0, 0.294)]
                              )
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            width: double.maxFinite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("04.01 - 12.24",
                                  style: TextStyle(
                                    fontSize: 20.2,
                                    color: Color(0xffF9F9F9),
                                    fontVariations: <FontVariation> [
                                      const FontVariation('wght', 380)
                                    ]
                                  ) 
                                ),
                                Text("가파도청보리축제", 
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Color(0xffFDFDFD),
                                    fontVariations: <FontVariation> [
                                      const FontVariation('wght', 420)
                                    ]
                                  )
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.fromLTRB(9, 0.6, 9, 0.6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white
                                  ),
                                  child: Text("개최중",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontVariations: <FontVariation> [
                                        const FontVariation('wght', 600)
                                      ]
                                    )
                                  ),
                                )
                              ]
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      ).toList(), 
      options: CarouselOptions(
        height: 328,
        viewportFraction: 0.825,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        }
      ),
    );
  }

  Widget carouselIndicator() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 14, 0, 20),
      child: AnimatedSmoothIndicator(
          activeIndex: _current,    
          count: imgList.length,    
          effect: ExpandingDotsEffect(
            spacing: 7,
            dotHeight: 7,
            dotWidth: 7,
            dotColor: Color(0xffD9D9D9),
            activeDotColor: Color(0xff7D7D7D),
          ), 
          ),
    );
  }
}

// class RecmdList extends StatelessWidget {
//   const RecmdList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Placeholder();
//   }
// }
