library gps_test;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import 'package:gps_test/preset/msg.dart' as MSG;
import 'package:gps_test/preset/url.dart' as URL;
import 'package:gps_test/preset/title.dart' as TITLE;
import 'package:gps_test/preset/path.dart' as PATH;
import 'package:rxdart/rxdart.dart';

part 'model/user.dart';
part 'model/checklist.dart';

part 'service/abstract/common.dart';
part 'service/user.dart';
part 'service/checklist.dart';

part 'extensions.dart';
part 'app_root.dart';

part 'foreground/task_handler.dart';
part 'view/login.dart';
part 'view/checklist.dart';

part 'global.dart';

part 'widget/common.dart';
