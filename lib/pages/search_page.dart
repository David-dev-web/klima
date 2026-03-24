import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../providers/weather_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _weatherService = WeatherService();
  List<GeocodingResult> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query, WeatherProvider wp) async {
    if (query.trim().isEmpty) {
      setState(() { _results = []; _error = null; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final results = await _weatherService.searchCity(query);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
          if (results.isEmpty) _error = wp.translate('Keine Städte gefunden', 'No cities found');
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = wp.translate('Suche fehlgeschlagen', 'Search failed'); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(wp.translate('Stadt suchen', 'Search city'), style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                controller: _controller,
                hintText: wp.translate('Nach Stadt suchen...', 'Search for city...'),
                leading: const Icon(Icons.search_rounded),
                onChanged: (v) => _search(v, wp),
                onSubmitted: (v) => _search(v, wp),
                elevation: const WidgetStatePropertyAll(2),
              ),
            ),
            Expanded(child: _buildBody(cs, tt, wp)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, TextTheme tt, WeatherProvider wp) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('🔍', style: TextStyle(fontSize: 56)), const SizedBox(height: 16), Text(_error!, style: tt.bodyLarge, textAlign: TextAlign.center)]));
    }
    if (_results.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('🌍', style: TextStyle(fontSize: 56)), const SizedBox(height: 16), Text(wp.translate('Stadtname eingeben', 'Enter city name'), style: tt.bodyLarge?.copyWith(color: cs.onSurface.withAlpha(153)))]));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = _results[index];
        return Card(
          elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: cs.outlineVariant.withAlpha(128))),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(backgroundColor: cs.primaryContainer, child: const Text('🏙️')),
            title: Text(r.name, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('${r.admin1 ?? ''}, ${r.country}'.trim(), style: tt.bodyMedium?.copyWith(color: cs.onSurface.withAlpha(153))),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pop(context, r),
          ),
        );
      },
    );
  }
}
