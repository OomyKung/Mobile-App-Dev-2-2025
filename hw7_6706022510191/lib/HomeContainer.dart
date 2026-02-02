import 'package:flutter/material.dart';
import "Area/AreaHome.dart";
import "Volume/VolumeHome.dart";

class HomeContainer extends StatefulWidget {
  const HomeContainer({Key? key}) : super(key: key);

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  int _index = 0;

  final pages = const [AreaHome(), VolumeHome()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.square_foot), label: 'Area'),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: 'Volume',
          ),
        ],
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
      ),
    );
  }
}
