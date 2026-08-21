import 'package:cyber_vpn/app/app.dart';
import 'package:cyber_vpn/app/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await configureDependencies();

  runApp(const CyberVpnApp());
}
