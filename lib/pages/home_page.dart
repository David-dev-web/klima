import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../widgets/forecast_card.dart';
import '../widgets/hourly_scroll.dart';
import '../widgets/hero_weather_card.dart';
import '../widgets/info_pill_row.dart';
import '../widgets/weather_map_tile.dart';
import '../widgets/weather_illustrations.dart';
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
        onRefresh: () => wp.refreshWeather(force: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _AppBar(wp: wp, cs: cs),
            if (wp.isLoading && wp.data == null) 
              SliverFillRemaining(child: _Shimmer(cs: cs))
            else if (wp.error != null && wp.data == null)
              SliverFillRemaining(child: _OfflineView(wp: wp, msg: wp.error ?? 'Error'))
            else if (wp.data != null)
              ..._buildSliverContent(context, wp, wp.data!, cs),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSliverContent(BuildContext context, WeatherProvider wp, WeatherData data, ColorScheme cs) {
    return [
      SliverToBoxAdapter(child: HeroWeatherCard(data: data)),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
      SliverToBoxAdapter(child: InfoPillRow(data: data)),
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
      SliverToBoxAdapter(child: _Section(wp.translate('HOURLY'), cs)),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      SliverToBoxAdapter(
        child: HourlyScroll(
          hours: data.hourly.where((h) => h.time.isAfter(DateTime.now().subtract(const Duration(hours: 1)))).take(24).toList()
        )
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
      SliverToBoxAdapter(child: WeatherMapTile(data: data)),
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
      SliverToBoxAdapter(child: _Section(wp.translate('DAILY'), cs)),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      SliverToBoxAdapter(child: _ForecastCard(data: data, cs: cs, wp: wp)),
      const SliverToBoxAdapter(child: SizedBox(height: 48)),
    ];
  }
}

class _AppBar extends StatelessWidget {
  final WeatherProvider wp; final ColorScheme cs;
  const _AppBar({required this.wp, required this.cs});
  @override
  Widget build(BuildContext context) => SliverAppBar(
    floating: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    title: GestureDetector(
      onTap: () async {
        final res = await Navigator.push<GeocodingResult>(context, MaterialPageRoute(builder: (_) => const SearchPage()));
        if (res != null) {
          wp.loadLocation(res.latitude, res.longitude, res.displayName);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_outlined, size: 16, color: cs.onSurface),
          const SizedBox(width: 8),
          Text(
            wp.data?.locationName ?? wp.translate('LOADING'),
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: IconButton(
          icon: const Icon(Icons.settings_rounded), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))
        ),
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  final String title; final ColorScheme cs;
  const _Section(this.title, this.cs);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        letterSpacing: 2.0,
        fontSize: 11,
        color: cs.onSurface.withOpacity(0.5),
      ),
    ),
  );
}

class _ForecastCard extends StatelessWidget {
  final WeatherData data; final ColorScheme cs; final WeatherProvider wp;
  const _ForecastCard({required this.data, required this.cs, required this.wp});

  @override
  Widget build(BuildContext context) {
    if (data.daily.isEmpty) return const SizedBox.shrink();
    
    final weekMin = data.daily.map((e) => e.minTemp).reduce((a, b) => a < b ? a : b);
    final weekMax = data.daily.map((e) => e.maxTemp).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.onSurface.withOpacity(0.06), width: 1),
        ),
        child: Column(
          children: [
            for (int i=0; i<data.daily.length; i++) ...[
              ForecastRow(
                forecast: data.daily[i], 
                isToday: i == 0, 
                onTap: () => _detail(context, data.daily[i], data.hourly, wp),
                weekMin: weekMin,
                weekMax: weekMax,
              ),
              if (i < data.daily.length-1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: cs.onSurface.withOpacity(0.06)),
                ),
            ]
          ],
        ),
      ),
    );
  }

  void _detail(BuildContext ctx, DailyForecast d, List<HourlyForecast> h, WeatherProvider wp) {
    final dayH = h.where((x) => x.time.day == d.date.day).toList();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, sc) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(
                DateFormat('EEEE, d. MMMM', wp.lang == AppLanguage.en ? 'en_US' : 'de_DE').format(d.date),
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  controller: sc,
                  padding: const EdgeInsets.all(24),
                  itemCount: dayH.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final x = dayH[i];
                    final xcs = Theme.of(context).colorScheme;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: xcs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('HH:mm').format(x.time), style: const TextStyle(fontWeight: FontWeight.bold)),
                          WeatherIllustration(weatherCode: x.weatherCode, size: 32),
                          Text(wp.formatTemp(x.temperature), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final ColorScheme cs; const _Shimmer({required this.cs});
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(baseColor: cs.surfaceContainerHigh, highlightColor: cs.surfaceContainerLow, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    Container(height: 300, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
    const SizedBox(height: 24), Row(children: List.generate(3, (i) => Expanded(child: Container(height: 60, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)))))),
    const SizedBox(height: 24), Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
  ])));
}

class _OfflineView extends StatelessWidget {
  final WeatherProvider wp; final String msg; const _OfflineView({required this.wp, required this.msg});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cs.errorContainer, shape: BoxShape.circle),
              child: Icon(Icons.cloud_off_rounded, size: 64, color: cs.onErrorContainer),
            ),
            const SizedBox(height: 24),
            Text(msg, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            SizedBox(
              height: 56, width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => wp.refreshWeather(force: true),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(wp.translate('RETRY')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary, 
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
