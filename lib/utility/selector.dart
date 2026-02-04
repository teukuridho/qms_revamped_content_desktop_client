import 'package:flutter/material.dart';

void listenTo<T>(ChangeNotifier notifier, T Function() selector, void Function(T) callback) {
  T last = selector();
  notifier.addListener(() {
    final current = selector();
    if (current != last) {
      last = current;
      callback(current);
    }
  });
}