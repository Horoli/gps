import 'package:flutter/material.dart';

const double WORK_DETAIL_HEADER = 42.0;
const double WORK_DETAIL_CHILD = 28.0;
const EdgeInsets WORK_DETAIL_PADDING = EdgeInsets.only(
  top: 8,
  bottom: 8,
  left: 16,
  right: 16,
);
const Divider DIVIDER = Divider(
  height: 1,
  indent: 15,
  endIndent: 15,
);

const EdgeInsets BUTTON_PADDING = EdgeInsets.only(
  top: 16,
  bottom: 16,
  left: 16,
  right: 16,
);

ButtonStyle BUTTON_STYLE = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4),
  ),
);
