import 'package:flutter/material.dart';

class UIHelper {
  static Widget bottomBorderSpace({double height = 12.0}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1.0),
        ),
      ),
    );
  }
}