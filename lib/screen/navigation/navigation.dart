import 'package:ahille/screen/account/account.dart';
import 'package:ahille/screen/chat/chat.dart';
import 'package:ahille/screen/navigation/update_navigation.dart';
import 'package:ahille/screen/search/search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../home/home.dart';

class Navigation extends StatelessWidget {
  Navigation({Key? key}) : super(key: key);
  final List<Widget> _items = [];
  late final List<Widget> _pages = <Widget>[];

  addItem(Widget widget, IconData icon, String label) {
    _pages.add(widget);
    _items.add(
      NavigationDestination(
        icon: Icon(icon),
        label: label,
      ),
    );
  }

  buttons(context) {
    if (_items.isNotEmpty) {
      _items.clear();
      _pages.clear();
    }

    addItem(const Home(), Icons.sensor_window_sharp, S.current.home);
    addItem(const Chat(), Icons.article, S.current.chat);
    addItem(const Search(), Icons.search, S.current.search);
    addItem(const Account(), Icons.account_box, S.current.account);
  }

  UpdateNavigation getUpdateNavigation(context, {bool listen=true}) {
    return Provider.of<UpdateNavigation>(context,listen: listen);
  }

  @override
  Widget build(BuildContext context) {
    buttons(context);

    return Scaffold(
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: Colors.green,
            iconTheme: const IconThemeData.fallback().copyWith(color: Colors.red),
            listTileTheme: const ListTileThemeData(
              iconColor: Colors.red,
            ),
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.red,
            textTheme: Theme.of(context).textTheme.copyWith(caption: const TextStyle(color: Colors.yellow))),
        // sets the inactive color of the `BottomNavigationBar`

        child: NavigationBar(
          onDestinationSelected: (int index) {
            getUpdateNavigation(context,listen: false).updatePageIndex(index);
          },
          selectedIndex: getUpdateNavigation(context).getPageIndex,
          destinations: _items,
        ),
      ),
      body: _pages[getUpdateNavigation(context).getPageIndex],
    );
  }
}
