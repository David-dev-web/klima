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
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  static const _seed = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightScheme = lightDynamic ??
            ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light);
        final ColorScheme darkScheme = darkDynamic ??
            ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark);

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
    return base.copyWith(textTheme: GoogleFonts.outfitTextTheme(base.textTheme));
  }
}
