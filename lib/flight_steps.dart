library FlightSteps;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:dio/dio.dart';
import 'package:flat/flat.dart';

import 'package:flight_steps/preset/msg.dart' as MSG;
import 'package:flight_steps/preset/url.dart' as URL;
import 'package:flight_steps/preset/title.dart' as TITLE;
import 'package:flight_steps/preset/path.dart' as PATH;
import 'package:flight_steps/preset/state.dart' as STATE;
import 'package:flight_steps/preset/id.dart' as ID;
import 'package:flight_steps/preset/color.dart' as COLOR;
import 'package:flight_steps/preset/size.dart' as SIZE;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';

part 'model/common.dart';
part 'model/user.dart';
part 'model/checklist.dart';
part 'model/work/work.dart';
part 'model/work/list.dart';
part 'model/work/current.dart';
part 'model/work/extra.dart';
part 'model/work/working.dart';
part 'model/member.dart';
part 'model/config.dart';
// part 'model/work/work_available.dart';

part 'service/work/worklist.dart';
part 'service/work/work.dart';
part 'service/work/extra.dart';

part 'service/abstract/common.dart';
part 'service/user.dart';
part 'service/checklist.dart';
part 'service/member.dart';
part 'service/sse_event.dart';
part 'service/route_manager.dart';
part 'service/location.dart';

part 'extensions.dart';
part 'app_root.dart';

part 'foreground/task_handler.dart';
part 'foreground/cookie_manager.dart';
part 'foreground/location_manager.dart';
part 'foreground/user_manager.dart';

part 'view/login.dart';
part 'view/preferences.dart';
part 'view/checklist.dart';
part 'view/worklist.dart';
part 'view/work_detail.dart';

part 'view/create/abstract.dart';
part 'view/create/aircraft.dart';
part 'view/create/group.dart';
part 'view/create/group_extra.dart';
part 'view/create/group_shift.dart';
part 'view/create/plate.dart';

part 'global.dart';

part 'widget/common.dart';
part 'widget/dialog.dart';
part 'widget/tile_work.dart';
part 'widget/tile_work_extra.dart';
part 'widget/tile_member.dart';
part 'widget/stream_exception.dart';

part 'utils/custom_stream.dart';
