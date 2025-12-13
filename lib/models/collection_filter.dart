/// Model for Shopify Collection Filters
class CollectionFilter {
  final String id;
  final String label;
  final String type;
  final List<FilterValue> values;

  CollectionFilter({
    required this.id,
    required this.label,
    required this.type,
    required this.values,
  });

  factory CollectionFilter.fromJson(Map<String, dynamic> json) {
    return CollectionFilter(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      values:
          (json['values'] as List<dynamic>?)
              ?.map((v) => FilterValue.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'values': values.map((v) => v.toJson()).toList(),
    };
  }
}

class FilterValue {
  final String id;
  final String label;
  final int count;
  final String input;

  FilterValue({
    required this.id,
    required this.label,
    required this.count,
    required this.input,
  });

  factory FilterValue.fromJson(Map<String, dynamic> json) {
    return FilterValue(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
      input: json['input'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'count': count, 'input': input};
  }
}

/// Model for active filter chips
class ActiveFilter {
  final String filterId;
  final String filterLabel;
  final String valueId;
  final String valueLabel;
  final String input;

  ActiveFilter({
    required this.filterId,
    required this.filterLabel,
    required this.valueId,
    required this.valueLabel,
    required this.input,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActiveFilter &&
        other.filterId == filterId &&
        other.valueId == valueId;
  }

  @override
  int get hashCode => filterId.hashCode ^ valueId.hashCode;
}
