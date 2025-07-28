import 'package:flutter/material.dart';

class SearchDetailsModal extends StatelessWidget {
  final Widget leadingWidget;
  final String title;
  final String subtitle;
  final String? additionalInfo;
  final List<Widget>? actionButtons;
  final String placeholderText;

  const SearchDetailsModal({
    super.key,
    required this.leadingWidget,
    required this.title,
    required this.subtitle,
    this.additionalInfo,
    this.actionButtons,
    required this.placeholderText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon and info
          Row(
            children: [
              leadingWidget,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (additionalInfo != null)
                      Text(
                        additionalInfo!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons if provided
          if (actionButtons != null) ...[
            Row(children: actionButtons!),
            const SizedBox(height: 16),
          ],

          // Placeholder text
          Text(placeholderText, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),

          // Close button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // static void showAlbumDetails(
  //   BuildContext context, {
  //   required String title,
  //   required String artist,
  //   String? year,
  //   VoidCallback? onPlay,
  //   VoidCallback? onShuffle,
  // }) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: const Color(0xFF1A1A1A),
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder:
  //         (context) => SearchDetailsModal(
  //           leadingWidget: Container(
  //             width: 80,
  //             height: 80,
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF1DB954).withValues(alpha: 0.2),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: const Icon(
  //               Icons.album,
  //               color: Color(0xFF1DB954),
  //               size: 32,
  //             ),
  //           ),
  //           title: title,
  //           subtitle: artist,
  //           additionalInfo: year,
  //           actionButtons: [
  //             if (onPlay != null)
  //               ElevatedButton.icon(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   onPlay();
  //                 },
  //                 icon: const Icon(Icons.play_arrow),
  //                 label: const Text('Play'),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xFF1DB954),
  //                   foregroundColor: Colors.white,
  //                 ),
  //               ),
  //             if (onPlay != null && onShuffle != null)
  //               const SizedBox(width: 12),
  //             if (onShuffle != null)
  //               OutlinedButton.icon(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   onShuffle();
  //                 },
  //                 icon: const Icon(Icons.shuffle),
  //                 label: const Text('Shuffle'),
  //                 style: OutlinedButton.styleFrom(
  //                   foregroundColor: Colors.white,
  //                   side: const BorderSide(color: Colors.white54),
  //                 ),
  //               ),
  //           ],
  //           placeholderText: 'Album details from search results',
  //         ),
  //   );
  // }

  // static void showArtistDetails(
  //   BuildContext context, {
  //   required String name,
  //   int? songCount,
  //   int? albumCount,
  //   VoidCallback? onPlayAll,
  //   VoidCallback? onShuffleAll,
  // }) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: const Color(0xFF1A1A1A),
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder:
  //         (context) => SearchDetailsModal(
  //           leadingWidget: CircleAvatar(
  //             radius: 40,
  //             backgroundColor: const Color(0xFF1DB954).withValues(alpha: 0.2),
  //             child: const Icon(
  //               Icons.person,
  //               color: Color(0xFF1DB954),
  //               size: 32,
  //             ),
  //           ),
  //           title: name,
  //           subtitle: '${songCount ?? 0} songs • ${albumCount ?? 0} albums',
  //           actionButtons: [
  //             if (onPlayAll != null)
  //               ElevatedButton.icon(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   onPlayAll();
  //                 },
  //                 icon: const Icon(Icons.play_arrow),
  //                 label: const Text('Play All'),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xFF1DB954),
  //                   foregroundColor: Colors.white,
  //                 ),
  //               ),
  //             if (onPlayAll != null && onShuffleAll != null)
  //               const SizedBox(width: 12),
  //             if (onShuffleAll != null)
  //               OutlinedButton.icon(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   onShuffleAll();
  //                 },
  //                 icon: const Icon(Icons.shuffle),
  //                 label: const Text('Shuffle'),
  //                 style: OutlinedButton.styleFrom(
  //                   foregroundColor: Colors.white,
  //                   side: const BorderSide(color: Colors.white54),
  //                 ),
  //               ),
  //           ],
  //           placeholderText: 'Artist details from search results',
  //         ),
  //   );
  // }
}
