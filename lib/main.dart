import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'app/bindings/initial_binding.dart';
import 'app/services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await LocalStorageService().init();
  Get.put<LocalStorageService>(storage, permanent: true);

  InitialBinding().dependencies();
  runApp(const MotoMileageApp());
  
}
