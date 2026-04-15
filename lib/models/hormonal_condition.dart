/// Model for tracking hormonal conditions and disorders
class HormonalCondition {
  HormonalCondition({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.dietRecommendations,
    required this.activityRecommendations,
    required this.medicalInfo,
    this.isTracking = false,
    this.severity = 'none', // none, mild, moderate, severe
    this.startDate,
    this.notes = '',
    this.lastUpdated,
  });

  final String id;
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> dietRecommendations;
  final List<String> activityRecommendations;
  final String medicalInfo;
  bool isTracking;
  String severity;
  DateTime? startDate;
  String notes;
  DateTime? lastUpdated;

  HormonalCondition copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? symptoms,
    List<String>? dietRecommendations,
    List<String>? activityRecommendations,
    String? medicalInfo,
    bool? isTracking,
    String? severity,
    DateTime? startDate,
    String? notes,
    DateTime? lastUpdated,
  }) {
    return HormonalCondition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      dietRecommendations: dietRecommendations ?? this.dietRecommendations,
      activityRecommendations:
          activityRecommendations ?? this.activityRecommendations,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      isTracking: isTracking ?? this.isTracking,
      severity: severity ?? this.severity,
      startDate: startDate ?? this.startDate,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class HormonalConditionMatch {
  const HormonalConditionMatch({
    required this.id,
    required this.name,
    required this.matchCount,
    required this.severity,
    required this.matchedSymptoms,
    required this.explanation,
  });

  final String id;
  final String name;
  final int matchCount;
  final String severity;
  final List<String> matchedSymptoms;
  final String explanation;
}

/// Predefined hormonal conditions
class HormonalConditions {
  static final List<HormonalCondition> allConditions = <HormonalCondition>[
    HormonalCondition(
      id: 'pcos',
      name: 'PCOS / PCOD',
      description:
          'Polycystic Ovary Syndrome - Ovaries produce excess male hormones (androgens), eggs may not release properly',
      symptoms: <String>[
        'Irregular or missed periods',
        'Weight gain (especially around belly)',
        'Acne and oily skin',
        'Excess facial and body hair (hirsutism)',
        'Hair thinning or hair loss on scalp',
        'Dark skin patches (acanthosis nigricans)',
        'Difficulty getting pregnant',
        'Pelvic pain',
        'Sleep disturbances',
        'Mood swings and fatigue',
      ],
      dietRecommendations: <String>[
        'High-protein meals: eggs, paneer, yogurt, dal, tofu, chicken',
        'High-fiber foods: vegetables, oats, whole grains, beans, seeds',
        'Low-GI carbs: brown rice, millets, quinoa, sweet potatoes',
        'Healthy fats: nuts, seeds, avocado, olive oil',
        'Anti-inflammatory foods: berries, turmeric, ginger, green tea',
        'Limit sugary drinks and refined snacks',
        'Avoid excess processed and junk food',
        'Include omega-3 rich foods: flaxseed, walnuts, fish',
        'Stay hydrated: 8-10 glasses of water daily',
        'Eat balanced meals with protein, fiber, and healthy fats',
      ],
      activityRecommendations: <String>[
        'Continue regular exercise for 30+ minutes most days',
        'Mix cardio (walking, swimming) with strength training',
        'Yoga and stretching 3-4 times per week',
        'Low-impact activities like cycling or elliptical',
        'Manage stress through meditation or deep breathing',
        'Maintain consistent sleep schedule (7-9 hours)',
        'Reduce caffeine intake',
        'Practice stress management techniques',
      ],
      medicalInfo:
          'PCOS affects 8-15% of women. It\'s a hormonal condition that can lead to insulin resistance. Regular monitoring with your gynecologist is important. Treatment may include birth control pills, metformin, or lifestyle changes.',
    ),
    HormonalCondition(
      id: 'endometriosis',
      name: 'Endometriosis',
      description:
          'Tissue similar to uterus lining grows outside the uterus, causing pain and fertility issues',
      symptoms: <String>[
        'Severe period pain (dysmenorrhea)',
        'Chronic pelvic pain',
        'Pain during intercourse (dyspareunia)',
        'Heavy or prolonged bleeding',
        'Infertility or difficulty conceiving',
        'Fatigue and low energy',
        'Bowel pain during periods',
        'Painful bowel movements',
        'Nausea and dizziness',
      ],
      dietRecommendations: <String>[
        'Anti-inflammatory foods: berries, leafy greens, fatty fish',
        'High-fiber foods: vegetables, fruits, whole grains',
        'Iron-rich foods: spinach, lentils, red meat',
        'Magnesium sources: dark chocolate, almonds, spinach',
        'Omega-3 rich foods: salmon, flaxseed, walnuts',
        'Avoid red meat and processed meats (may increase inflammation)',
        'Limit caffeine and alcohol',
        'Avoid sugar and refined carbs',
        'Stay hydrated with plenty of water',
        'Herbal teas: ginger, turmeric, chamomile',
      ],
      activityRecommendations: <String>[
        'Gentle yoga and stretching (avoid intense abdominal work)',
        'Walking and low-impact cardio',
        'Swimming and water aerobics',
        'Pelvic floor physical therapy if needed',
        'Rest and relaxation during menstruation',
        'Heat therapy and warm baths for pain relief',
        'Stress management and meditation',
        'Avoid high-impact exercises during painful periods',
      ],
      medicalInfo:
          'Endometriosis affects 10-15% of reproductive-age women. It requires proper diagnosis through imaging or laparoscopy. Treatment options include pain management, hormonal therapy, or surgery. Fertility planning should involve a specialist.',
    ),
    HormonalCondition(
      id: 'thyroid',
      name: 'Thyroid Disorders',
      description:
          'Thyroid disease affects hormone balance and can cause irregular periods, weight changes, and fatigue',
      symptoms: <String>[
        'Irregular or heavy periods',
        'Missing periods',
        'Unexplained weight gain or loss',
        'Fatigue and weakness',
        'Sluggish metabolism',
        'Hair loss and dry skin',
        'Cold intolerance',
        'Brain fog and poor concentration',
        'Depression and mood swings',
        'Constipation',
      ],
      dietRecommendations: <String>[
        'Iodine-rich foods: seaweed, fish, eggs, dairy',
        'Selenium sources: Brazil nuts, tuna, brown rice',
        'Zinc-rich foods: oysters, beef, chickpeas',
        'Anti-inflammatory foods: berries, green tea, turmeric',
        'High-fiber foods: vegetables, whole grains, legumes',
        'Lean protein: chicken, fish, tofu',
        'Healthy fats: olive oil, avocado, nuts',
        'Limit goitrogenic foods (raw cruciferous vegetables in excess)',
        'Avoid excess soy supplements',
        'Stay hydrated and avoid excess caffeine',
      ],
      activityRecommendations: <String>[
        'Regular moderate exercise: 30 minutes, 5 days per week',
        'Strength training 2-3 times per week',
        'Walking, yoga, or swimming',
        'Avoid over-exercising which can stress thyroid',
        'Maintain consistent sleep schedule',
        'Manage stress through relaxation techniques',
        'Get regular sunlight exposure',
        'Take medications as prescribed by doctor',
      ],
      medicalInfo:
          'Thyroid disorders are common, especially in women. Both hyperthyroidism and hypothyroidism affect menstrual cycles. Regular TSH and thyroid hormone testing is essential. Treatment typically involves medication and lifestyle changes.',
    ),
    HormonalCondition(
      id: 'fibroids',
      name: 'Uterine Fibroids',
      description:
          'Non-cancerous growths in the uterus that can cause heavy bleeding and pelvic pain',
      symptoms: <String>[
        'Heavy menstrual bleeding',
        'Prolonged periods (more than 7 days)',
        'Pelvic pain and pressure',
        'Frequent urination',
        'Pain during intercourse',
        'Constipation or bloating',
        'Fatigue from heavy blood loss',
        'Anemia symptoms',
        'Lower back pain',
      ],
      dietRecommendations: <String>[
        'Iron-rich foods: red meat, spinach, lentils, fortified cereals',
        'Vitamin C for iron absorption: citrus, berries, tomatoes',
        'Anti-inflammatory foods: turmeric, ginger, fatty fish',
        'Reduce red meat consumption (may promote fibroid growth)',
        'Increase plant-based proteins: beans, lentils, tofu',
        'High-fiber foods: vegetables, fruits, whole grains',
        'Omega-3 rich foods: salmon, mackerel, walnuts',
        'Vitamin D sources: fatty fish, egg yolks, fortified milk',
        'Avoid excess processed foods',
        'Stay hydrated: 8-10 glasses of water daily',
      ],
      activityRecommendations: <String>[
        'Gentle exercises: walking, swimming, yoga',
        'Avoid intense abdominal exercises',
        'Regular physical activity 3-4 times per week',
        'Pelvic floor stretches and exercises',
        'Rest during heavy bleeding days',
        'Heat therapy for pain relief',
        'Stress management and relaxation',
        'Maintain healthy weight through balanced exercise',
      ],
      medicalInfo:
          'Uterine fibroids are very common in women of reproductive age. While benign, they can affect fertility and quality of life. Treatment options range from monitoring to medication or surgery, depending on size and symptoms.',
    ),
    HormonalCondition(
      id: 'amenorrhea',
      name: 'Amenorrhea (Absent Periods)',
      description:
          'Missing periods for 3+ months, which can indicate hormonal imbalance or underlying conditions',
      symptoms: <String>[
        'Missing periods for 3+ months',
        'Unexplained weight loss or gain',
        'Extreme stress or anxiety',
        'Excessive exercise',
        'Disordered eating patterns',
        'Vaginal dryness',
        'Hot flashes',
        'Headaches',
        'Vision changes',
      ],
      dietRecommendations: <String>[
        'Balanced nutrition with adequate calories',
        'Sufficient protein: 1.2-1.6g per kg body weight',
        'Healthy fats: avocado, nuts, olive oil',
        'Complex carbs: whole grains, legumes',
        'Iron and B12 rich foods: meat, eggs, dairy',
        'Calcium and magnesium for bone health',
        'Regular meal timing (don\'t skip meals)',
        'Fertility-supporting foods: seeds, nuts, leafy greens',
        'Avoid restrictive dieting',
        'Stay hydrated and take electrolytes if needed',
      ],
      activityRecommendations: <String>[
        'Moderation in exercise (avoid overtraining)',
        'Strength training: 2-3 times per week',
        'Gentle cardio: 150 minutes per week',
        'Restorative activities: yoga, pilates, stretching',
        'Stress reduction: meditation, therapy, counseling',
        'Adequate rest and sleep: 7-9 hours',
        'Avoid excessive cardio and HIIT',
        'Weight restoration if underweight',
      ],
      medicalInfo:
          'Amenorrhea can result from stress, extreme weight loss, overexercise, hormonal disorders, or pregnancy. Medical evaluation is important to rule out serious conditions. Treatment focuses on addressing the underlying cause.',
    ),
    HormonalCondition(
      id: 'pid',
      name: 'Pelvic Inflammatory Disease (PID)',
      description:
          'Infection in the reproductive organs that can cause pain, irregular bleeding, and infertility',
      symptoms: <String>[
        'Pelvic pain and cramping',
        'Irregular bleeding',
        'Painful periods',
        'Painful intercourse',
        'Fever and chills',
        'Unusual vaginal discharge',
        'Nausea and vomiting',
        'Urinary symptoms',
        'Back pain',
        'Fatigue',
      ],
      dietRecommendations: <String>[
        'Anti-inflammatory foods: turmeric, ginger, berries',
        'Immune-boosting foods: vitamin C rich (citrus, peppers)',
        'Probiotics: yogurt, kefir, fermented foods',
        'Iron-rich foods: spinach, lentils, red meat',
        'Protein for healing: eggs, fish, chicken, legumes',
        'High-fiber foods: vegetables, whole grains',
        'Garlic and onions for antibacterial properties',
        'Green tea and herbal teas',
        'Avoid alcohol during treatment',
        'Stay hydrated with water and herbal teas',
      ],
      activityRecommendations: <String>[
        'Rest during acute infection phase',
        'Gentle walking once acute symptoms improve',
        'Avoid strenuous exercise until cleared by doctor',
        'Pelvic rest (avoid intercourse until infection clears)',
        'Heat therapy for pain relief',
        'Stress management and relaxation',
        'Adequate sleep for immune recovery',
        'Avoid smoking and secondhand smoke',
      ],
      medicalInfo:
          'PID is a serious infection that requires antibiotic treatment. Early diagnosis and treatment are crucial to prevent complications. Untreated PID can lead to infertility, ectopic pregnancy, or chronic pelvic pain. Always see a doctor immediately.',
    ),
  ];

  static HormonalCondition getConditionById(String id) {
    return allConditions.firstWhere(
      (HormonalCondition condition) => condition.id == id,
      orElse: () => allConditions.first,
    );
  }
}
