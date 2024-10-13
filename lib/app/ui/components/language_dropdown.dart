import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transpeach/app/core/constants/tab/tab_idiomas.dart';
import 'package:transpeach/app/core/utils/dropdown_utils.dart';

class LanguageDropdown extends StatefulWidget {
  final Function(String? value) onChanged;
  final String? value;

  const LanguageDropdown(
      {super.key, required this.onChanged, required this.value});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  final List<DropdownMenuItem<String>> _dropDownMenuItens =
      buildDropdownMenuItens(TabIdiomas.idiomas);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          filled: true,
          isDense: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 10, bottom: 10, right: 5),
        ),
        hint: const Text('Selecione...'),
        value: widget.value,
        items: _dropDownMenuItens,
        onChanged: (String? value) {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            widget.onChanged(value);
          });
        },
      ),
    );
  }
}
