import 'package:flutter/material.dart';
import 'package:huoo/services/songs_cache.dart';
import 'package:intl/intl.dart';

class CacheStatusWidget extends StatefulWidget {
  final VoidCallback onRefresh;
  final bool showLastUpdated;

  const CacheStatusWidget({
    required this.onRefresh,
    this.showLastUpdated = true,
    super.key,
  });

  @override
  State<CacheStatusWidget> createState() => _CacheStatusWidgetState();
}

class _CacheStatusWidgetState extends State<CacheStatusWidget> {
  final SongsCache _songsCache = SongsCache();

  @override
  void initState() {
    super.initState();
    _songsCache.addListener(_onCacheChanged);
  }

  @override
  void dispose() {
    _songsCache.removeListener(_onCacheChanged);
    super.dispose();
  }

  void _onCacheChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Never';
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return widget.showLastUpdated
        ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last updated: ${_formatDateTime(_songsCache.lastUpdated)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                color: Colors.white.withValues(alpha: 0.6),
                onPressed: widget.onRefresh,
              ),
            ],
          ),
        )
        : const SizedBox.shrink();
  }
}
