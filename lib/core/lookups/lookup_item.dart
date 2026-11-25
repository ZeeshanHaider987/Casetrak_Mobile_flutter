class LookupItem {
  const LookupItem({
    required this.id,
    required this.label,
    this.code,
    this.isActive = true,
  });

  final String id;
  final String label;
  final String? code;
  final bool isActive;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'code': code,
        'isActive': isActive,
      };

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    return LookupItem(
      id: json['id'].toString(),
      label: (json['label'] ?? json['name'] ?? json['id']).toString(),
      code: json['code']?.toString(),
      isActive: json['isActive'] != false,
    );
  }
}
