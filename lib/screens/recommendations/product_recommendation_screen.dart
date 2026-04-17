import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/models/product_recommendation.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';
import 'package:femi_friendly/providers/pregnancy_provider.dart';
import 'package:femi_friendly/services/api_client.dart';

class ProductRecommendationScreen extends StatefulWidget {
  const ProductRecommendationScreen({super.key});

  @override
  State<ProductRecommendationScreen> createState() =>
      _ProductRecommendationScreenState();
}

class _ProductRecommendationScreenState extends State<ProductRecommendationScreen>
    with SingleTickerProviderStateMixin {
  static const String _fallbackDisclaimer =
      'This app only suggests products. Purchases are made on external platforms.';

  static const List<String> _cyclePhases = <String>[
    'menstrual',
    'follicular',
    'ovulation',
    'luteal',
  ];

  static const List<String> _flowLevels = <String>[
    'light',
    'medium',
    'heavy',
    'spotting',
  ];

  final ApiClient _apiClient = ApiClient();

  late final AnimationController _heroController;
  late final Animation<double> _heroAnimation;

  String _selectedCyclePhase = 'menstrual';
  String _selectedFlowLevel = 'medium';
  int _painLevel = 4;
  bool _pregnancyStatus = false;

  bool _isLoading = false;
  String? _error;
  String _recommendedCategory = 'Pads';
  List<RecommendedProduct> _products = <RecommendedProduct>[];
  String _disclaimer = _fallbackDisclaimer;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    _initializeFromProviders();
    _heroController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRecommendations());
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  void _initializeFromProviders() {
    final cycle = context.read<CycleProvider>();
    final pregnancy = context.read<PregnancyProvider>();
    final latestSymptom = cycle.history.isNotEmpty ? cycle.history.first.symptom : '';

    _selectedCyclePhase = _phaseFromDay(cycle.currentDayInCycle);
    _selectedFlowLevel = _flowFromSymptomText(latestSymptom);
    _painLevel = _painFromSymptomText(latestSymptom);
    _pregnancyStatus = pregnancy.pregnancyMode;
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final payload = ProductRecommendationInput(
        cyclePhase: _selectedCyclePhase,
        flowLevel: _selectedFlowLevel,
        painLevel: _painLevel,
        pregnancyStatus: _pregnancyStatus,
      );
      final response = await _apiClient.recommendProducts(payload.toJson());
      final parsed = ProductRecommendationResponse.fromJson(response);

      if (!mounted) return;
      setState(() {
        _recommendedCategory = parsed.category;
        _products = parsed.products;
        _disclaimer = parsed.disclaimer;
        _isLoading = false;
      });
    } catch (exc) {
      if (!mounted) return;
      setState(() {
        _recommendedCategory = 'Pads';
        _products = <RecommendedProduct>[];
        _disclaimer = _fallbackDisclaimer;
        _error = exc.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openLink(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null || (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https')))) {
      _showSnack('Invalid product link.');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showSnack('Could not open this product link.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Product Recommendations'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRecommendations,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          children: [
            FadeTransition(
              opacity: _heroAnimation,
              child: _buildHeroCard(),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInputCard(),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Recommended for you',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'AI picks based on your cycle and pregnancy profile.',
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.95),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildCategoryChip(),
            const SizedBox(height: AppSpacing.sm),
            if (_isLoading) ..._buildLoadingCards(),
            if (!_isLoading && _error != null) _buildErrorCard(),
            if (!_isLoading && _error == null && _products.isNotEmpty)
              ..._buildProductCards(),
            if (!_isLoading && _error == null && _products.isEmpty)
              _buildEmptyCard(),
            const SizedBox(height: AppSpacing.md),
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAD1457), Color(0xFFE91E63), Color(0xFFFF80AB)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            child: Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Product Suggestions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No in-app sales. Buy safely on trusted external stores.',
                  style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personalization',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Cycle Phase',
                  value: _selectedCyclePhase,
                  options: _cyclePhases,
                  onChanged: (value) =>
                      setState(() => _selectedCyclePhase = value),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildDropdownField(
                  label: 'Flow Level',
                  value: _selectedFlowLevel,
                  options: _flowLevels,
                  onChanged: (value) =>
                      setState(() => _selectedFlowLevel = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pain Level: $_painLevel/10',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _painLevel.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _painLevel = value.round()),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _pregnancyStatus,
            onChanged: (value) => setState(() => _pregnancyStatus = value),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
            title: const Text(
              'Pregnancy Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            subtitle: const Text(
              'Turn on for prenatal-focused recommendations.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchRecommendations,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Get Recommendations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        _labelize(option),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) onChanged(newValue);
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildProductCards() {
    return _products.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 360 + (index * 90)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 14),
                child: child,
              ),
            );
          },
          child: _ProductCard(
            product: product,
            onBuyNow: () => _openLink(product.link),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildLoadingCards() {
    return <Widget>[
      const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.8),
              ),
              SizedBox(height: 8),
              Text(
                'Fetching live products...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      ...List<Widget>.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.5, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildCategoryChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Category: $_recommendedCategory',
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Could not fetch recommendations',
            style: TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error ?? 'Unknown API error.',
            style: const TextStyle(fontSize: 12, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _fetchRecommendations,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: const Text(
        'No products were returned for this profile. Try adjusting flow or pain values.',
        style: TextStyle(color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _disclaimer,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _phaseFromDay(int day) {
    if (day <= 5) return 'menstrual';
    if (day <= 13) return 'follicular';
    if (day <= 16) return 'ovulation';
    return 'luteal';
  }

  String _flowFromSymptomText(String input) {
    final text = input.toLowerCase();
    if (text.contains('heavy')) return 'heavy';
    if (text.contains('light')) return 'light';
    if (text.contains('spot')) return 'spotting';
    return 'medium';
  }

  int _painFromSymptomText(String input) {
    final text = input.toLowerCase();
    if (text.contains('severe')) return 8;
    if (text.contains('mild')) return 3;
    if (text.contains('cramp') || text.contains('pain')) return 6;
    return 4;
  }

  String _labelize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onBuyNow,
  });

  final RecommendedProduct product;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              product.image,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 150,
                color: AppColors.accentLight,
                child: const Icon(Icons.image_outlined, color: AppColors.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onBuyNow,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Buy Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

