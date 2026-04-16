// lib/screens/ai_insights_screen.dart
// AI Insights and Predictions Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:femi_friendly/providers/ai_provider.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  // Form keys and controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ageController;
  late TextEditingController _bmiController;
  late TextEditingController _cycleLengthController;
  late TextEditingController _stressController;
  late TextEditingController _sleepController;
  late TextEditingController _weightController;

  String _selectedExercise = 'moderate';
  final List<String> _selectedSymptoms = [];

  final List<String> exerciseOptions = ['light', 'moderate', 'high'];
  final List<String> symptomOptions = [
    'cramping',
    'bloating',
    'fatigue',
    'mood_changes',
    'acne',
    'headache',
    'breast_pain',
  ];

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _bmiController = TextEditingController();
    _cycleLengthController = TextEditingController();
    _stressController = TextEditingController(text: '5');
    _sleepController = TextEditingController(text: '7.5');
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _bmiController.dispose();
    _cycleLengthController.dispose();
    _stressController.dispose();
    _sleepController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final inputData = {
      'age': int.parse(_ageController.text),
      'bmi': double.parse(_bmiController.text),
      'cycle_length': int.parse(_cycleLengthController.text),
      'stress': int.parse(_stressController.text),
      'sleep': double.parse(_sleepController.text),
      'weight': double.parse(_weightController.text),
      'exercise': _selectedExercise,
      'symptoms': _selectedSymptoms.isEmpty ? ['none'] : _selectedSymptoms,
    };

    print('🔄 Submitting data: $inputData');

    // Trigger prediction
    context.read<AIProvider>().fetchPrediction(inputData);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📤 Sending data to AI...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _retryRequest(BuildContext context) {
    final inputData = {
      'age': int.parse(_ageController.text),
      'bmi': double.parse(_bmiController.text),
      'cycle_length': int.parse(_cycleLengthController.text),
      'stress': int.parse(_stressController.text),
      'sleep': double.parse(_sleepController.text),
      'weight': double.parse(_weightController.text),
      'exercise': _selectedExercise,
      'symptoms': _selectedSymptoms.isEmpty ? ['none'] : _selectedSymptoms,
    };

    context.read<AIProvider>().fetchPrediction(inputData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Health Insights'),
        elevation: 0,
        backgroundColor: Colors.purple.shade400,
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                _submitForm(context);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Form
                    _buildInputForm(context),

                    const SizedBox(height: 24),

                    // Results Section
                    if (aiProvider.isLoading)
                      _buildLoadingState()
                    else if (aiProvider.hasError)
                      _buildErrorState(context, aiProvider)
                    else if (aiProvider.predictionResult != null)
                      _buildResultsSection(aiProvider)
                    else
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputForm(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📋 Enter Your Health Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Age
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age (years)',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Age is required';
                  final age = int.tryParse(value!);
                  if (age == null || age < 0 || age > 120) return 'Enter valid age';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // BMI
              TextFormField(
                controller: _bmiController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'BMI (kg/m²)',
                  prefixIcon: const Icon(Icons.scale),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'BMI is required';
                  final bmi = double.tryParse(value!);
                  if (bmi == null || bmi < 10 || bmi > 60) return 'Enter valid BMI';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Cycle Length
              TextFormField(
                controller: _cycleLengthController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cycle Length (days)',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Cycle length is required';
                  final length = int.tryParse(value!);
                  if (length == null || length < 15 || length > 60) {
                    return 'Enter valid cycle length (15-60)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: const Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Weight is required';
                  final weight = double.tryParse(value!);
                  if (weight == null || weight < 20 || weight > 200) {
                    return 'Enter valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Stress Level (Slider)
              const Text('Stress Level (1-10):', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Text('1'),
                  Expanded(
                    child: Slider(
                      value: double.parse(_stressController.text),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _stressController.text,
                      onChanged: (value) {
                        setState(() {
                          _stressController.text = value.toInt().toString();
                        });
                      },
                    ),
                  ),
                  const Text('10'),
                ],
              ),
              const SizedBox(height: 12),

              // Sleep Hours
              TextFormField(
                controller: _sleepController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Sleep Hours',
                  prefixIcon: const Icon(Icons.bedtime),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Sleep hours required';
                  final sleep = double.tryParse(value!);
                  if (sleep == null || sleep < 0 || sleep > 24) {
                    return 'Enter valid sleep hours';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Exercise Level
              const Text('Exercise Level:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedExercise,
                isExpanded: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedExercise = newValue;
                    });
                  }
                },
                items: exerciseOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.capitalize()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Symptoms
              const Text('Symptoms (select all that apply):',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: symptomOptions.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom.replaceAll('_', ' ').capitalize()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _submitForm(context),
                  icon: const Icon(Icons.psychology),
                  label: const Text('Get AI Prediction'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.purple.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              '⏳ Processing your data...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connecting to AI backend',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AIProvider aiProvider) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade700, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '❌ Error',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              aiProvider.errorMessage ?? 'An unknown error occurred',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _retryRequest(context);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('🔄 Retry'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AIProvider>().clearResults();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(AIProvider aiProvider) {
    final result = aiProvider.predictionResult ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success Header
        Card(
          elevation: 2,
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green.shade300, width: 1),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  '✅ Prediction Complete!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cycle Status Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cycle Status',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  aiProvider.getCycleStatus() ?? result['status'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: (result['status'] == 'Regular' ? Colors.green : Colors.orange),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Predicted Cycle Length: ${aiProvider.getPredictedCycleLength()?.toStringAsFixed(1) ?? result['cycle_length'] ?? 'N/A'} days',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Water Intake Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.opacity, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Water Intake',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${aiProvider.getWaterIntake()?.toStringAsFixed(2) ?? result['water_intake'] ?? 'N/A'} L',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Food Recommendations
        if (aiProvider.getFoodRecommendations() != null)
          _buildListCard(
            title: '🥗 Food Recommendations',
            items: aiProvider.getFoodRecommendations() ?? [],
          ),

        if (aiProvider.getFoodRecommendations() != null) const SizedBox(height: 12),

        // Health Tips
        if (aiProvider.getHealthTips() != null)
          _buildListCard(
            title: '💡 Health Tips',
            items: aiProvider.getHealthTips() ?? [],
          ),

        if (aiProvider.getHealthTips() != null) const SizedBox(height: 12),

        // All Recommendations
        if (aiProvider.getRecommendations() != null)
          _buildListCard(
            title: '📋 Recommendations',
            items: aiProvider.getRecommendations() ?? [],
          ),

        const SizedBox(height: 20),

        // Share Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📤 Sharing results...')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Results'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard({required String title, required List<String> items}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✓', style: TextStyle(color: Colors.green, fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology_alt, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No predictions yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill in your health data and tap "Get AI Prediction" to get started',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringCapitalize on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
