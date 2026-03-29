import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'providers/weather_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const KlimaApp(),
    ),
  );
}

class KlimaApp extends StatelessWidget {
  const KlimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightScheme = lightDynamic ??
            ColorScheme.fromSeed(seedColor: const Color(0xFFFF8C00), brightness: Brightness.light);
        final ColorScheme darkScheme = darkDynamic ??
            ColorScheme.fromSeed(seedColor: const Color(0xFFFF8C00), brightness: Brightness.dark);

        return MaterialApp(
          title: 'Klima',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(lightScheme),
          darkTheme: _buildTheme(darkScheme),
          themeMode: ThemeMode.system,
          home: const HomePage(),
        );
      },
    );
  }

  ThemeData _buildTheme(ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final textTheme = GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
      displayLarge: const TextStyle(fontWeight: FontWeight.w100, fontSize: 96, letterSpacing: -1.5),
      displayMedium: const TextStyle(fontWeight: FontWeight.w100, fontSize: 60, letterSpacing: -0.5),
      labelSmall: const TextStyle(fontWeight: FontWeight.w400, fontSize: 11, letterSpacing: 2.0),
    );
    return base.copyWith(
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeThroughPageTransitionsBuilder(),
          TargetPlatform.iOS: _FadeThroughPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class _FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeThroughPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}

