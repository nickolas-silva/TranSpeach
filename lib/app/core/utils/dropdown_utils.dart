import 'package:flutter/material.dart';

List<DropdownMenuItem<String>> buildDropdownMenuItens(List<String> list, {List<String>? ignoredTerms}) {
  List<DropdownMenuItem<String>> items = [];
  items.add(
    const DropdownMenuItem(
      value: null,
      child: Text(
        'Selecione...',
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
    )
  );
  for (int i = 0; i < list.length; i++) {
    if(list[i] != '-'){
      if(ignoredTerms != null){
        if(!ignoredTerms.contains(list[i])){
          items.add(
            DropdownMenuItem(
              value: i.toString(),
              child: Text(
                list[i],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                )
              ),
            )
          );
        }
      } else {
        items.add(
          DropdownMenuItem(
            value: i.toString(),
            child: Text(
              list[i],
              style: const TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.bold
              )
            ),
          )
        );
      }
    }
  }
  return items;
}