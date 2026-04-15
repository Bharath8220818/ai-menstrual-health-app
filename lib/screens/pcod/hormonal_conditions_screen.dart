import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/models/hormonal_condition.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';
import 'package:femi_friendly/providers/hormonal_condition_provider.dart';
import 'package:femi_friendly/widgets/glass_card.dart';

class HormonalConditionsScreen extends StatefulWidget {
  const HormonalConditionsScreen({super.key});

  @override
  State<HormonalConditionsScreen> createState() =>
      _HormonalConditionsScreenState();
}

class _HormonalConditionsScreenState extends State<HormonalConditionsScreen> {
  String _selectedConditionId = 'pcos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hormonal Health Disorder Tracker'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildAnalysisSummary(context),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: HormonalConditions.allConditions.map((condition) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: _selectedConditionId == condition.id,
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              _selectedConditionId = condition.id;
                            });
                          }
                        },
                        label: Text(condition.name),
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.pink.shade200,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            _buildConditionDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSummary(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final conditionProvider = context.watch<HormonalConditionProvider>();
    final matches = conditionProvider.analyzeSymptoms(
      cycleProvider.trackedSymptoms,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'HHDT Symptom Match',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Possible matches are based on your tracked symptoms only. This does not diagnose any condition.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              if (matches.isEmpty)
                const Text(
                  'Log more symptoms in the Cycle tab to see up to 4 possible condition matches here.',
                )
              else
                ...matches.map((match) {
                  final Color chipColor = match.severity == 'High'
                      ? Colors.red.shade400
                      : match.severity == 'Medium'
                          ? Colors.orange.shade400
                          : Colors.blue.shade400;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  match.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: chipColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  match.severity,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            match.explanation,
                            style: const TextStyle(height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionDetails(BuildContext context) {
    final condition = HormonalConditions.getConditionById(_selectedConditionId);
    final conditionProvider = context.read<HormonalConditionProvider>();
    final isTracked = conditionProvider.trackedConditions.containsKey(
      _selectedConditionId,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Track this condition',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conditionProvider.getImprovementStatus(
                          _selectedConditionId,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isTracked,
                    onChanged: (value) {
                      if (value) {
                        conditionProvider.trackCondition(_selectedConditionId);
                      } else {
                        conditionProvider.untrackCondition(_selectedConditionId);
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'About This Condition',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(condition.description),
                  const SizedBox(height: 12),
                  const Text(
                    'Medical Info:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condition.medicalInfo,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isTracked)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'How are you feeling?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'none',
                          label: Text('None'),
                        ),
                        ButtonSegment<String>(
                          value: 'mild',
                          label: Text('Mild'),
                        ),
                        ButtonSegment<String>(
                          value: 'moderate',
                          label: Text('Moderate'),
                        ),
                        ButtonSegment<String>(
                          value: 'severe',
                          label: Text('Severe'),
                        ),
                      ],
                      selected: <String>{
                        conditionProvider.trackedConditions[_selectedConditionId]
                                ?.severity ??
                            'none',
                      },
                      onSelectionChanged: (Set<String> newSelection) {
                        conditionProvider.updateSeverity(
                          _selectedConditionId,
                          newSelection.first,
                        );
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          Text(
            'Common Symptoms',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: condition.symptoms.map((symptom) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.check_circle, size: 18),
                        const SizedBox(width: 12),
                        Expanded(child: Text(symptom)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Diet Recommendations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: condition.dietRecommendations.map((diet) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Icon(
                            Icons.eco_outlined,
                            size: 18,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(diet)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Activity Recommendations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: condition.activityRecommendations.map((activity) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(activity)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isTracked)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your Notes & Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Track improvements, changes, symptoms, or progress...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        conditionProvider.updateNotes(
                          _selectedConditionId,
                          value,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
