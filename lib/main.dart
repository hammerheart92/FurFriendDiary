import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'l10n/app_localizations.dart';
import 'src/presentation/routes/app_router.dart';
import 'src/data/local/hive_manager.dart';
import 'src/data/services/notification_service.dart';
import 'src/data/services/inventory_alert_service.dart';
import 'src/data/repositories/pet_profile_repository.dart';
import 'src/presentation/providers/settings_provider.dart';
import 'src/utils/file_logger.dart';
import 'theme/theme.dart';

late final Logger logger;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize file logger
  logger = await FileLogger.getInstance();

  try {
    // Initialize HiveManager (this handles everything)
    await HiveManager.instance.initialize();

    // Verify initialization
    if (!HiveManager.instance.isInitialized) {
      throw Exception("HiveManager failed to initialize properly");
    }

    // Initialize NotificationService
    await NotificationService().initialize();

    // Check low stock on app startup
    try {
      final petRepository = PetProfileRepository();
      final activePets = petRepository.getActive();

      if (activePets.isNotEmpty) {
        final currentPet = activePets.first;
        await InventoryAlertService().checkLowStockAndNotify(currentPet.id);
      }
    } catch (e) {
      logger.w("WARNING: Low stock check failed: $e");
      // Don't throw - this is not critical for app startup
    }
  } catch (e, stackTrace) {
    logger.e("FATAL ERROR: App initialization failed: $e");
    logger.e("STACK TRACE: $stackTrace");

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

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add observer to monitor app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer when app is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // CRITICAL FIX for Samsung devices: Flush all boxes when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // Don't await - let it complete asynchronously
      HiveManager.instance.verifyDataPersistence().then((_) {
        return HiveManager.instance.flushAllBoxes();
      }).catchError((e) {
        logger.e("ERROR: Failed to flush boxes on background: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      routerConfig: router,
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
