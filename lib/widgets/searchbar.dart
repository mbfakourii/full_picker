import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../generated/l10n.dart';
import '../utils/border_radius_m3.dart';

class Searchbar extends StatelessWidget {
  Searchbar({Key? key, required this.onPressed, required this.onChanged, required this.onClose}) : super(key: key);
  final ValueChanged<String> onPressed;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  final TextEditingController _textEditingController = TextEditingController();

  final InputBorder border = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.transparent),
    borderRadius: BorderRadiusM3.full,
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      decoration: InputDecoration(
        hintText: S.current.search,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: TextButton(
            onPressed: () {
              onPressed.call(_textEditingController.text);
            },
            child: Icon(
              Icons.search,
              size: 6.w,
            ),
          ),
        ),
        suffixIcon: getUpdateSearchbar(context).getText.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: TextButton(
                  onPressed: () {
                    onClose.call();
                    _textEditingController.text="";
                    getUpdateSearchbar(context, listen: false).updateText(_textEditingController.text);
                  },
                  child: Icon(
                    Icons.close,
                    size: 6.w,
                  ),
                ),
              ),
        enabledBorder: border,
        focusedBorder: border,
      ),
      onSubmitted: (value) {
        onPressed.call(_textEditingController.text);
      },
      onChanged: (value) {
        onChanged.call(value);

        getUpdateSearchbar(context, listen: false).updateText(value);
      },
    );
  }

  UpdateSearchbar getUpdateSearchbar(context, {bool listen = true}) {
    return Provider.of<UpdateSearchbar>(context, listen: listen);
  }
}

class UpdateSearchbar extends ChangeNotifier {
  var _text = "";

  String get getText {
    return _text;
  }

  void updateText(value) {
    _text = value;
    notifyListeners();
  }
}
