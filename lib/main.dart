import 'package:cyber_vpn/app/app.dart';
import 'package:cyber_vpn/app/di.dart';
import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );
  await configureDependencies();

  runApp(const CyberVpnApp());
}
