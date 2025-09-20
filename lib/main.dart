
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'src/presentation/routes/app_router.dart';
import 'src/data/local/hive_manager.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("🚀 DEBUG: Starting FurFriendDiary app initialization");
  
  try {
    // Clear any potentially corrupted data first
    print("🔧 DEBUG: Clearing potentially corrupted Hive data");
    await HiveManager.instance.clearAllData();
    
    // Initialize HiveManager (this handles everything)
    print("🔍 DEBUG: Initializing HiveManager");
    await HiveManager.instance.initialize();
    
    // Verify initialization
    if (!HiveManager.instance.isInitialized) {
      throw Exception("HiveManager failed to initialize properly");
    }
    
    print("✅ DEBUG: HiveManager initialized successfully");
    
    // Verify boxes are accessible
    final petBox = HiveManager.instance.petProfileBox;
    final walkBox = HiveManager.instance.walkBox;
    final settingsBox = HiveManager.instance.settingsBox;
    final appPrefsBox = HiveManager.instance.appPrefsBox;
    
    print("✅ DEBUG: All boxes verified accessible:");
    print("   - Pet profiles: ${petBox.length} items");
    print("   - Walks: ${walkBox.length} items"); 
    print("   - Settings: ${settingsBox.length} items");
    print("   - App prefs: ${appPrefsBox.length} items");
    
  } catch (e, stackTrace) {
    print("🚨 FATAL ERROR: App initialization failed: $e");
    print("🚨 STACK TRACE: $stackTrace");
    
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
  
  print("🚀 DEBUG: Starting app with properly initialized Hive");
  
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
        routerConfig: createRouter(),
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ro')],
      ),
    );
  }
}
