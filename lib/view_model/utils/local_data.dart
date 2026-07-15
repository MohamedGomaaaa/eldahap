import 'package:flutter/cupertino.dart';

Size getSize({
  context,
}) {
  Size size = MediaQuery.of(context).size;
  return size;
}