import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          if (results.isEmpty) _error = wp.translate('NO_CITIES');
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = wp.translate('LOAD_ERROR'); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(wp.translate('SEARCH_CITY'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SearchBar(
              controller: _controller,
              hintText: wp.translate('SEARCH_HINT'),
              leading: Icon(Icons.search_rounded, color: cs.primary),
              onChanged: (v) => _search(v, wp),
              onSubmitted: (v) => _search(v, wp),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              hintStyle: WidgetStatePropertyAll(TextStyle(color: cs.onSurface.withOpacity(0.5))),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
            ),
          ),
          Expanded(child: _buildBody(cs, wp)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, WeatherProvider wp) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_city_rounded, size: 64, color: cs.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              _error ?? wp.translate('ENTER_CITY'),
              style: GoogleFonts.outfit(color: cs.onSurface.withOpacity(0.4), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final r = _results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => Navigator.pop(context, r),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.location_on_rounded, color: cs.primary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.displayName,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${r.admin1 ?? ''}, ${r.country}'.trim().replaceAll(RegExp(r'^, '), ''),
                            style: GoogleFonts.outfit(color: cs.onSurface.withOpacity(0.5), fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.3)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
