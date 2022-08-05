import 'package:ahille/screen/settings/settingsmain.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../settings/settings.dart';


class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
            canvasColor: Colors.green,
            iconTheme: IconThemeData.fallback().copyWith(
                color: Colors.red
            ),
            listTileTheme:const ListTileThemeData(
              iconColor: Colors.red,
            ),
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.red,
            textTheme: Theme
                .of(context)
                .textTheme
                .copyWith(caption: new TextStyle(color: Colors.yellow))), // sets the inactive color of the `BottomNavigationBar`

        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          height: 60,
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            NavigationDestination(
              icon: const Icon(Icons.sensor_window_sharp),
              label: S.current.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.article),
              label: S.current.chat,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search),
              label: S.current.search,
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_box),
              label: S.current.account,
            ),
          ],
        ),
      ),
      body: <Widget>[
        Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: Column(
            children: [
              const Text('Page 1'),
              const Text('Page 1'),
              const Text('Page 1'),
              TextButton(onPressed: () {
                setState(() {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyHomePage()));
                });
              }, child: Text("Setting")),

            ],
          ),
        ),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: const Text('Page 2'),
        ),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: const Text('Page 2'),
        ),
        Container(
          color: Colors.blue,
          alignment: Alignment.center,
          child: const Text('Page 3'),
        ),
      ][currentPageIndex],
    );
  }
}
