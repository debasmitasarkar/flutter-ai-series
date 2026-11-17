import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final results = <String, String>{};

Future<void> check(String name, Future<String> Function() body) async {
  try {
    results[name] = await body();
  } catch (e) {
    results[name] = 'ERROR ${e.runtimeType}: $e';
  }
  debugPrint('AUDIT $name = ${results[name]}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await check('dio GET version.json', () async {
    final r = await Dio().get<Object>('version.json');
    return 'HTTP ${r.statusCode}';
  });
  await check('hive openBox', () async {
    final box = await Hive.openBox('audit');
    await box.put('k', 1);
    return 'ok ${box.get('k')}';
  });
  await check('awesome_notifications initialize', () async {
    final ok = await AwesomeNotifications().initialize(null, [
      NotificationChannel(channelKey: 'audit', channelName: 'Audit', channelDescription: 'audit'),
    ]);
    return 'initialize returned $ok';
  });
  await check('shared_preferences', () async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('k', 1);
    return 'ok ${p.getInt('k')}';
  });
  await check('url_launcher canLaunch', () async => '${await canLaunchUrl(Uri.parse('https://dart.dev'))}');
  debugPrint('AUDIT DONE');
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('de')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: AuditApp(),
  ));
}

class AuditApp extends StatelessWidget {
  AuditApp({super.key});

  final _router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => const ResultsPage()),
  ]);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(textTheme: GoogleFonts.robotoMonoTextTheme()),
      );
}

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('AUDIT easy_localization = deviceLocale ${context.deviceLocale} -> ${'hello'.tr()}');
    return Scaffold(
        appBar: AppBar(title: const Text('js interop audit')),
        body: ListView(children: [
          ListTile(
            title: const Text('easy_localization'),
            subtitle: Text('deviceLocale ${context.deviceLocale} -> ${'hello'.tr()}'),
          ),
          for (final e in results.entries)
            ListTile(
              key: ValueKey(e.key),
              title: Text(e.key),
              subtitle: Text(e.value),
              leading: Icon(e.value.startsWith('ERROR') ? Icons.close : Icons.check,
                  color: e.value.startsWith('ERROR') ? Colors.red : Colors.green),
            ),
        ]),
      );
  }
}
