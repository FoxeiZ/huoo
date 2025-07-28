import 'package:equatable/equatable.dart';
import 'home_api_model.dart';

/// Response model for continue listening items (matches ContinueListeningResponse in Python)
class ContinueListeningResponse extends Equatable {
  final List<ContinueListeningItem> items;
  final int totalCount;

  const ContinueListeningResponse({this.items = const [], this.totalCount = 0});

  factory ContinueListeningResponse.fromJson(Map<String, dynamic> json) {
    return ContinueListeningResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (itemJson) => ContinueListeningItem.fromJson(
                  itemJson as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total_count': totalCount,
    };
  }

  @override
  List<Object?> get props => [items, totalCount];
}

/// Response model for top mixes (matches TopMixesResponse in Python)
class TopMixesResponse extends Equatable {
  final List<TopMixItem> items;
  final int totalCount;

  const TopMixesResponse({this.items = const [], this.totalCount = 0});

  factory TopMixesResponse.fromJson(Map<String, dynamic> json) {
    return TopMixesResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (itemJson) =>
                    TopMixItem.fromJson(itemJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total_count': totalCount,
    };
  }

  @override
  List<Object?> get props => [items, totalCount];
}

/// Response model for recent listening (matches RecentListeningResponse in Python)
class RecentListeningResponse extends Equatable {
  final List<RecentListeningItem> items;
  final int totalCount;

  const RecentListeningResponse({this.items = const [], this.totalCount = 0});

  factory RecentListeningResponse.fromJson(Map<String, dynamic> json) {
    return RecentListeningResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (itemJson) => RecentListeningItem.fromJson(
                  itemJson as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total_count': totalCount,
    };
  }

  @override
  List<Object?> get props => [items, totalCount];
}
