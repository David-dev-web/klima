import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../widgets/forecast_card.dart';
import '../widgets/weather_icon.dart';
import '../widgets/hourly_scroll.dart';
import '../widgets/hero_weather_card.dart';
import '../widgets/info_pill_row.dart';
import '../widgets/weather_map_tile.dart';
import 'search_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () => wp.refreshWeather(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _AppBar(wp: wp, cs: cs),
            if (wp.isLoading && wp.data == null) 
              SliverFillRemaining(child: _Shimmer(cs: cs))
            else if (wp.error != null && wp.data == null)
              SliverFillRemaining(child: _Error(wp: wp, msg: wp.error!))
            else if (wp.data != null)
              SliverToBoxAdapter(child: _Content(wp: wp, data: wp.data!, cs: cs)),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final WeatherProvider wp; final ColorScheme cs;
  const _AppBar({required this.wp, required this.cs});
  @override
  Widget build(BuildContext context) => SliverAppBar(
    floating: true,
    backgroundColor: cs.surface,
    surfaceTintColor: Colors.transparent,
    title: GestureDetector(
      onTap: () async {
        final res = await Navigator.push<GeocodingResult>(context, MaterialPageRoute(builder: (_) => const SearchPage()));
        if (res != null) wp.loadLocation(res.latitude, res.longitude, res.displayName);
      },
      child: Text(wp.data?.locationName ?? wp.translate('Lade...', 'Loading...'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
    ),
    actions: [
      IconButton(icon: const Icon(Icons.settings_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
    ],
  );
}

class _Content extends StatelessWidget {
  final WeatherProvider wp; final WeatherData data; final ColorScheme cs;
  const _Content({required this.wp, required this.data, required this.cs});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      HeroWeatherCard(data: data),
      const SizedBox(height: 20),
      InfoPillRow(data: data),
      const SizedBox(height: 24),
      _Section(wp.translate('STÜNDLICH', 'HOURLY'), cs),
      const SizedBox(height: 12),
      HourlyScroll(hours: data.hourly.where((h) => h.time.isAfter(DateTime.now().subtract(const Duration(hours: 1)))).take(24).toList()),
      const SizedBox(height: 24),
      WeatherMapTile(data: data),
      const SizedBox(height: 24),
      _Section(wp.translate('7-TAGE-VORHERSAGE', '7-DAY FORECAST'), cs),
      const SizedBox(height: 12),
      _ForecastCard(data: data, cs: cs, wp: wp),
      const SizedBox(height: 32),
    ],
  );
}

class _Section extends StatelessWidget {
  final String title; final ColorScheme cs;
  const _Section(this.title, this.cs);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)));
}

class _ForecastCard extends StatelessWidget {
  final WeatherData data; final ColorScheme cs; final WeatherProvider wp;
  const _ForecastCard({required this.data, required this.cs, required this.wp});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Card(
      elevation: 0, color: cs.surfaceContainerHighest.withAlpha(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          for (int i=0; i<data.daily.length; i++) ...[
            ForecastRow(forecast: data.daily[i], isToday: i == 0, onTap: () => _detail(context, data.daily[i], data.hourly, wp)),
            if (i < data.daily.length-1) Divider(height: 1, indent: 24, endIndent: 24, color: cs.outlineVariant.withAlpha(100)),
          ]
        ],
      ),
    ),
  );

  void _detail(BuildContext ctx, DailyForecast d, List<HourlyForecast> h, WeatherProvider wp) {
    final dayH = h.where((x) => x.time.day == d.date.day).toList();
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6, maxChildSize:0.9, minChildSize:0.4,
      builder: (context, sc) => Container(
        decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(children: [
          const SizedBox(height: 12), Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24), Text(DateFormat('EEEE, d. MMMM', wp.lang == AppLanguage.en ? 'en_US' : 'de_DE').format(d.date), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(child: ListView.separated(controller: sc, padding: const EdgeInsets.all(24), itemCount: dayH.length, separatorBuilder: (context, index) => const SizedBox(height: 16), itemBuilder: (context, i) {
            final x = dayH[i];
            return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(DateFormat('HH:mm').format(x.time), style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(WeatherIcon.getInfo(x.weatherCode).emoji, style: const TextStyle(fontSize: 24)),
              Text(wp.formatTemp(x.temperature), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ]);
          })),
        ]),
      ),
    ));
  }
}

class _Shimmer extends StatelessWidget {
  final ColorScheme cs; const _Shimmer({required this.cs});
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(baseColor: cs.surfaceContainerHighest, highlightColor: cs.surfaceContainerLow, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    Container(height: 300, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(48))),
    const SizedBox(height: 24), Row(children: List.generate(3, (i) => Expanded(child: Container(height: 60, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)))))),
    const SizedBox(height: 24), Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28))),
  ])));
}

class _Error extends StatelessWidget {
  final WeatherProvider wp; final String msg; const _Error({required this.wp, required this.msg});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_rounded, size:64, color:Colors.grey), const SizedBox(height:16), Text(msg), const SizedBox(height:24), ElevatedButton(onPressed: wp.refreshWeather, child: const Text('Retry'))]));
}
