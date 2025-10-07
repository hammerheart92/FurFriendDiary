
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'l10n/app_localizations.dart';
import 'src/presentation/routes/app_router.dart';
import 'src/data/local/hive_manager.dart';
import 'src/presentation/providers/settings_provider.dart';
import 'src/utils/file_logger.dart';
import 'theme/theme.dart';

late final Logger logger;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize file logger
  logger = await FileLogger.getInstance();

  logger.i("🚀 DEBUG: Starting FurFriendDiary app initialization");
  logger.i("📝 DEBUG: Logs are being saved to: ${FileLogger.logFile?.path}");
  
  try {
    // Initialize HiveManager (this handles everything)
    logger.i("🔍 DEBUG: Initializing HiveManager");
    await HiveManager.instance.initialize();
    
    // Verify initialization
    if (!HiveManager.instance.isInitialized) {
      throw Exception("HiveManager failed to initialize properly");
    }
    
    logger.i("✅ DEBUG: HiveManager initialized successfully");
    
    // Verify boxes are accessible
    final petBox = HiveManager.instance.petProfileBox;
    final walkBox = HiveManager.instance.walkBox;
    final settingsBox = HiveManager.instance.settingsBox;
    final appPrefsBox = HiveManager.instance.appPrefsBox;
    
    logger.i("✅ DEBUG: All boxes verified accessible:");
    logger.d("   - Pet profiles: ${petBox.length} items");
    logger.d("   - Walks: ${walkBox.length} items"); 
    logger.d("   - Settings: ${settingsBox.length} items");
    logger.d("   - App prefs: ${appPrefsBox.length} items");
    
  } catch (e, stackTrace) {
    logger.e("🚨 FATAL ERROR: App initialization failed: $e");
    logger.e("🚨 STACK TRACE: $stackTrace");
    
    // Show error dialog and exit
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('App Initialization Failed', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Error: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => main(), // Retry
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ));
    return;
  }
  
  logger.i("🚀 DEBUG: Starting app with properly initialized Hive");
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      routerConfig: createRouter(),
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ro')],
    );
  }
}
