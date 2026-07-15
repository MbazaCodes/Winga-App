import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/session.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    try {
      await dotenv.load(fileName: ".env");
      debugPrint('Dotenv loaded successfully');
    } catch (e) {
      debugPrint('Error loading .env file: $e');
    }

    // Load session from SharedPreferences BEFORE routing
    await WingaSession.load();

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url != null && anonKey != null) {
      // Initialize Supabase
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      debugPrint('Supabase initialized successfully');
    } else {
      debugPrint('Supabase URL or Anon Key is missing in .env');
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    runApp(const ProviderScope(child: WingaApp()));
  } catch (e, stack) {
    debugPrint('Critical error during initialization: $e');
    debugPrint(stack.toString());
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization Error: $e'),
        ),
      ),
    ));
  }
}

class WingaApp extends ConsumerWidget {
  const WingaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Winga App',
      debugShowCheckedModeBanner: false,
      theme: buildWingaTheme(),
      routerConfig: router,
    );
  }
}
