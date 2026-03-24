import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

class WeatherMapTile extends StatefulWidget {
  final WeatherData data;
  const WeatherMapTile({super.key, required this.data});

  @override
  State<WeatherMapTile> createState() => _WeatherMapTileState();
}

class _WeatherMapTileState extends State<WeatherMapTile> {
  bool _showOverlay = false;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_getMapUrl()));
  }

  String _getMapUrl() {
    double scale = _showOverlay ? 0.3 : 0.1;
    String layer = _showOverlay ? 'cyclemap' : 'mapnik';
    return 'https://www.openstreetmap.org/export/embed.html?bbox=${widget.data.longitude - scale}%2C${widget.data.latitude - scale}%2C${widget.data.longitude + scale}%2C${widget.data.latitude + scale}&layer=$layer&marker=${widget.data.latitude}%2C${widget.data.longitude}';
  }

  void _toggle() {
    setState(() => _showOverlay = !_showOverlay);
    _controller.loadRequest(Uri.parse(_getMapUrl()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final wp = context.watch<WeatherProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                wp.translate('WETTERKARTE', 'WEATHER MAP'),
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              TextButton.icon(
                onPressed: _toggle,
                icon: Icon(_showOverlay ? Icons.layers_rounded : Icons.layers_outlined, size: 18),
                label: Text(wp.translate(_showOverlay ? 'Standard' : 'Wetter-Ebene', _showOverlay ? 'Standard' : 'Weather Layer'), style: const TextStyle(fontSize: 12)),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: cs.outlineVariant)),
                clipBehavior: Clip.antiAlias,
                child: WebViewWidget(controller: _controller),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(12)),
                  child: Text(wp.formatTemp(widget.data.current.temperature), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
