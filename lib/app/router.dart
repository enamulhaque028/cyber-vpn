import 'package:auto_route/auto_route.dart';
import 'package:cyber_vpn/features/locations/presentation/pages/locations_page.dart';
import 'package:cyber_vpn/features/onboarding/presentation/pages/onboarding_pages.dart';
import 'package:cyber_vpn/features/session/presentation/pages/home_page.dart';
import 'package:cyber_vpn/features/settings/presentation/pages/settings_pages.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: PrivacyRoute.page),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: LocationsRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: PaywallRoute.page),
  ];
}
