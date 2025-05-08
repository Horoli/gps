library gps_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:dio/dio.dart';
import 'package:flat/flat.dart';

import 'package:gps_test/preset/msg.dart' as MSG;
import 'package:gps_test/preset/url.dart' as URL;
import 'package:gps_test/preset/title.dart' as TITLE;
import 'package:gps_test/preset/path.dart' as PATH;
import 'package:gps_test/preset/state.dart' as STATE;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventsource/eventsource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'model/common.dart';
part 'model/user.dart';
part 'model/checklist.dart';
part 'model/work.dart';
part 'model/worklist.dart';
part 'model/member.dart';
part 'model/work_current.dart';
part 'model/config.dart';

part 'service/abstract/common.dart';
part 'service/user.dart';
part 'service/checklist.dart';
part 'service/worklist.dart';
part 'service/work.dart';
part 'service/member.dart';
part 'service/sse_event.dart';
part 'service/route_manager.dart';
part 'service/gps_interval.dart';

part 'extensions.dart';
part 'app_root.dart';

part 'foreground/task_handler.dart';
part 'foreground/cookie_manager.dart';
part 'foreground/location_manager.dart';

part 'view/login.dart';
part 'view/preferences.dart';
part 'view/checklist.dart';
part 'view/worklist.dart';
part 'view/create_group.dart';
part 'view/work_detail.dart';

part 'global.dart';

part 'widget/common.dart';
part 'widget/dialog.dart';
part 'widget/tile_work.dart';
part 'widget/tile_member.dart';
part 'widget/stream_exception.dart';
