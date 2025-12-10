import 'package:flutter/material.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {

  Future<String> test() async {
    await Future.delayed(Duration(seconds: 2));
    return "data";
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: test(), builder: (context, snapshot) {
      return Text("data");
    });
  }
}