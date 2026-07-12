import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_router.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'features/settings/data/hive_settings_repository.dart';
import 'theme/lifeos_theme.dart';

const _settingsBoxName = 'lifeos_settings';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Settings/DailyGoals/User are Hive-backed (docs/02_Software_
  // Requirements.md §6 Storage). Unlike Isar, Hive's plain Box API needs
  // no build_runner codegen (see HiveSettingsRepository's BUILD NOTE for
  // why it avoids TypeAdapters) — this is the one repository in the app
  // that is genuinely wired to real, persistent storage today rather
  // than in-memory, without waiting on a Flutter SDK to generate code.
  await Hive.initFlutter();
  final settingsBox = await Hive.openBox(_settingsBoxName);

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(HiveSettingsRepository(settingsBox)),
      ],
      child: const LifeOSApp(),
    ),
  );
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: LifeOSTheme.dark(),
      routerConfig: appRouter,
      // Persian (fa) is the primary/default locale, RTL by default; English
      // (en) is secondary — docs/07_Design_System.md Localization Format.
      // gen-l10n's generated AppLocalizations delegate is wired once
      // `flutter gen-l10n` runs against lib/l10n/*.arb in a real
      // environment (needs the Flutter SDK this sandbox doesn't have).
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // RTL is driven by locale automatically via Directionality from
        // MaterialApp's Localizations; this explicit wrap guarantees RTL
        // even before gen-l10n's AppLocalizations is wired in, matching
        // CLAUDE.md §11 "RTL support implemented from the start."
        final isRtl = Localizations.localeOf(context).languageCode == 'fa';
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
