class PremiumPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int durationDays;
  final List<String> features;
  final bool isPopular;
  final String? stripePriceId;

  PremiumPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.features,
    this.isPopular = false,
    this.stripePriceId,
  });

  factory PremiumPlan.fromJson(Map<String, dynamic> json) {
    return PremiumPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      durationDays: json['duration_days'] ?? 30,
      features: List<String>.from(json['features'] ?? []),
      isPopular: json['is_popular'] ?? false,
      stripePriceId: json['stripe_price_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'duration_days': durationDays,
      'features': features,
      'is_popular': isPopular,
      'stripe_price_id': stripePriceId,
    };
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  String get formattedInterval {
    if (durationDays >= 365) {
      final years = (durationDays / 365).round();
      return years == 1 ? 'per year' : 'per $years years';
    } else if (durationDays >= 30) {
      final months = (durationDays / 30).round();
      return months == 1 ? 'per month' : 'per $months months';
    } else if (durationDays >= 7) {
      final weeks = (durationDays / 7).round();
      return weeks == 1 ? 'per week' : 'per $weeks weeks';
    } else {
      return durationDays == 1 ? 'per day' : 'per $durationDays days';
    }
  }
}
