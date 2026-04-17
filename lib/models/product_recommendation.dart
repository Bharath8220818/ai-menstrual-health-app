class ProductRecommendationInput {
  ProductRecommendationInput({
    required this.cyclePhase,
    required this.flowLevel,
    required this.painLevel,
    required this.pregnancyStatus,
    this.maxResults = 5,
  });

  final String cyclePhase;
  final String flowLevel;
  final int painLevel;
  final bool pregnancyStatus;
  final int maxResults;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cycle_phase': cyclePhase,
        'flow_level': flowLevel,
        'pain_level': painLevel,
        'pregnancy_status': pregnancyStatus,
        'max_results': maxResults,
      };
}

class RecommendedProduct {
  RecommendedProduct({
    required this.name,
    required this.price,
    required this.link,
    required this.image,
  });

  final String name;
  final String price;
  final String link;
  final String image;

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      name: (json['name'] ?? '').toString(),
      price: (json['price'] ?? 'Price unavailable').toString(),
      link: (json['link'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
    );
  }
}

class ProductRecommendationResponse {
  ProductRecommendationResponse({
    required this.category,
    required this.products,
    required this.disclaimer,
  });

  final String category;
  final List<RecommendedProduct> products;
  final String disclaimer;

  factory ProductRecommendationResponse.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    final products = rawProducts is List
        ? rawProducts
            .whereType<Map>()
            .map(
              (item) =>
                  RecommendedProduct.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
        : <RecommendedProduct>[];

    return ProductRecommendationResponse(
      category: (json['category'] ?? 'Pads').toString(),
      products: products,
      disclaimer: (json['disclaimer'] ??
              'This app only suggests products. Purchases are made on external platforms.')
          .toString(),
    );
  }
}
