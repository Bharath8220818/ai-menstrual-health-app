import 'dart:math';

import 'package:flutter/material.dart';

import 'package:femi_friendly/models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final Random _random = Random();

  final List<ChatMessage> _messages = <ChatMessage>[
    ChatMessage(
      text:
          "Hi! I'm your Femi AI assistant. I can help with menstrual health, fertility, pregnancy tips, and more. What's on your mind today?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isTyping = false;

  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  List<String> get suggestions => const <String>[
        'Can I get pregnant today?',
        'What to eat during periods?',
        'Pregnancy care tips',
        'Why is my cycle late?',
        'How to reduce cramps?',
      ];

  Future<void> sendMessage(String value) async {
    final text = value.trim();
    if (text.isEmpty) return;

    _messages.add(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );
    _isTyping = true;
    notifyListeners();

    final delay = 800 + _random.nextInt(600);
    await Future<void>.delayed(Duration(milliseconds: delay));

    _messages.add(
      ChatMessage(
        text: _buildSmartResponse(text),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _isTyping = false;
    notifyListeners();
  }

  Future<void> clearChat() async {
    _messages
      ..clear()
      ..add(
        ChatMessage(
          text: 'Chat cleared! How can I help you today?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    notifyListeners();
  }

  String _buildSmartResponse(String text) {
    final query = text.toLowerCase();

    if (query.contains('pregnant') ||
        query.contains('conceive') ||
        query.contains('get pregnant')) {
      return 'The best time to conceive is during your fertile window, typically Day 10-16 of a 28-day cycle. Ovulation usually happens around Day 14. Track basal body temperature and egg-white cervical mucus for better accuracy.';
    }

    // PCOS/PCOD Response
    if (query.contains('pcod') || query.contains('pcos')) {
      return 'PCOS/PCOD (Polycystic Ovary Syndrome) happens when ovaries produce excess hormones, affecting egg release.\n\n📍 SYMPTOMS:\nIrregular periods, weight gain, acne, excess hair, hair loss, dark skin patches, pelvic pain, sleep issues, fatigue.\n\n✅ WHAT TO DO:\n- Track symptoms and cycle gaps monthly\n- Exercise 30+ minutes most days\n- Sleep 7-9 hours, manage stress\n- See a gynecologist if periods missing 3+ months\n\n🥗 DIET:\n- High-protein: eggs, paneer, yogurt, dal, tofu\n- High-fiber: vegetables, oats, beans\n- Low-GI carbs: brown rice, millets, quinoa\n- Healthy fats: nuts, seeds, avocado\n- Avoid: sugary drinks, refined snacks\n\n💪 ACTIVITIES:\n- Mix cardio & strength training\n- Yoga & stretching 3-4x/week\n- Manage stress with meditation\n\nLog symptoms for better AI guidance!';
    }

    // Endometriosis Response
    if (query.contains('endometriosis')) {
      return 'Endometriosis occurs when uterine tissue grows outside the uterus.\n\n📍 SYMPTOMS:\nSevere period pain, chronic pelvic pain, painful intercourse, heavy bleeding, infertility, fatigue, painful bowel movements.\n\n✅ WHAT TO DO:\n- Consult gynecologist for diagnosis\n- Pain management strategies\n- Avoid intense exercise during periods\n- Heat therapy for pain relief\n\n🥗 DIET:\n- Anti-inflammatory: berries, leafy greens, fatty fish\n- High-fiber: vegetables, whole grains\n- Iron-rich: spinach, lentils, red meat\n- Magnesium: almonds, dark chocolate\n- Avoid: red meat excess, caffeine, alcohol\n\n💪 ACTIVITIES:\n- Gentle yoga & stretching\n- Low-impact cardio\n- Pelvic floor physical therapy\n- Rest during menstruation\n\nFertility planning requires specialist support.';
    }

    // Thyroid Disorder Response
    if (query.contains('thyroid')) {
      return 'Thyroid disorders affect hormone balance and menstrual cycles.\n\n📍 SYMPTOMS:\nIrregular/heavy periods, unexplained weight changes, fatigue, hair loss, dry skin, cold intolerance, brain fog, depression, constipation.\n\n✅ WHAT TO DO:\n- Get TSH and thyroid hormone tests\n- Take medications as prescribed\n- Manage stress\n- Regular checkups with doctor\n\n🥗 DIET:\n- Iodine-rich: seaweed, fish, eggs, dairy\n- Selenium: Brazil nuts, tuna, brown rice\n- Zinc: oysters, beef, chickpeas\n- Anti-inflammatory: berries, green tea\n- High-fiber: vegetables, whole grains\n- Avoid: excess soy, raw cruciferous veggies\n\n💪 ACTIVITIES:\n- Moderate exercise: 30min, 5x/week\n- Strength training 2-3x/week\n- Avoid over-exercising\n- Consistent sleep schedule\n\nRegular monitoring is essential!';
    }

    // Uterine Fibroids Response
    if (query.contains('fibroid')) {
      return 'Uterine fibroids are non-cancerous growths that can cause heavy bleeding.\n\n📍 SYMPTOMS:\nHeavy periods, prolonged bleeding (7+ days), pelvic pain, frequent urination, painful intercourse, constipation, fatigue, anemia, lower back pain.\n\n✅ WHAT TO DO:\n- Get ultrasound diagnosis\n- Iron supplementation for anemia\n- Pain management\n- Discuss treatment options with doctor\n\n🥗 DIET:\n- Iron-rich: red meat, spinach, lentils\n- Vitamin C: citrus, berries (for iron absorption)\n- Anti-inflammatory: turmeric, ginger, fish\n- Plant-based protein: beans, tofu\n- High-fiber: vegetables, fruits, grains\n- Omega-3: salmon, walnuts\n- Vitamin D: fatty fish, fortified milk\n\n💪 ACTIVITIES:\n- Gentle exercises: walking, swimming, yoga\n- Avoid intense abdominal work\n- Rest during heavy bleeding\n- Heat therapy for pain\n- 3-4x/week exercise\n\nTreatment depends on size and symptoms.';
    }

    // Amenorrhea Response
    if (query.contains('amenorrhea') || query.contains('no period')) {
      return 'Amenorrhea means missing periods for 3+ months.\n\n📍 CAUSES:\nExtreme stress, weight loss, over-exercising, disordered eating, hormonal imbalances, pregnancy.\n\n📍 SYMPTOMS:\nMissing periods, weight changes, stress, excessive exercise, dryness, hot flashes, headaches.\n\n✅ WHAT TO DO:\n- Medical evaluation to find cause\n- Address underlying issue\n- Restore balanced nutrition\n- Reduce stress gradually\n- Moderate exercise\n\n🥗 DIET:\n- Adequate calories for health\n- Protein: 1.2-1.6g per kg body weight\n- Healthy fats: avocado, nuts, olive oil\n- Complex carbs: whole grains, legumes\n- Iron & B12: meat, eggs, dairy\n- Calcium & magnesium for bones\n- Regular meal timing\n- NO restrictive dieting\n\n💪 ACTIVITIES:\n- Moderate exercise (avoid over-training)\n- Strength training 2-3x/week\n- Gentle cardio 150min/week\n- Yoga & stretching\n- Stress reduction & meditation\n- 7-9 hours sleep\n\nProper nutrition is critical for cycle restoration!';
    }

    // PID Response
    if (query.contains('pelvic inflammatory disease') ||
        query.contains('pid') ||
        query.contains('reproductive infection')) {
      return 'Pelvic Inflammatory Disease (PID) is a serious reproductive infection.\n\n📍 SYMPTOMS:\nPelvic pain, irregular bleeding, painful periods, painful intercourse, fever, unusual discharge, nausea, urinary issues, back pain, fatigue.\n\n⚠️ URGENT:\nSee a doctor immediately for antibiotics!\n\n✅ WHAT TO DO:\n- Immediate medical treatment\n- Complete antibiotic course\n- Pelvic rest (avoid intercourse)\n- Pain management\n- Follow-up ultrasounds\n\n🥗 DIET:\n- Anti-inflammatory: turmeric, ginger, berries\n- Immune-boosting: Vitamin C (citrus, peppers)\n- Probiotics: yogurt, kefir\n- Iron-rich: spinach, lentils, red meat\n- Protein: eggs, fish, chicken, legumes\n- High-fiber: vegetables, grains\n- Garlic & onions for antibacterial\n- Herbal teas: green tea, ginger\n- Avoid: alcohol during treatment\n- Stay hydrated\n\n💪 ACTIVITIES:\n- Rest during acute infection\n- Gentle walking once improving\n- Avoid strenuous exercise\n- Heat therapy for pain\n- Stress management\n- Sleep for immune recovery\n- No smoking\n\nUntreated PID can cause infertility. Seek immediate care!';
    }

    if (query.contains('pregnancy') ||
        query.contains('trimester') ||
        query.contains('prenatal')) {
      return 'Pregnancy tips by trimester:\n\n1st trimester: take folic acid 400-800 mcg, stay hydrated, and avoid raw seafood.\n2nd trimester: focus on iron and calcium. Light exercise like prenatal yoga is great.\n3rd trimester: rest more, eat protein-rich foods, and prepare your birth plan.\n\nAlways consult your OB-GYN for personalized advice.';
    }

    if (query.contains('eat') ||
        query.contains('food') ||
        query.contains('diet') ||
        query.contains('nutrition')) {
      return 'Best foods during your period:\n\n- Iron-rich: spinach, lentils, red meat\n- Magnesium: dark chocolate, bananas\n- Anti-inflammatory: berries, turmeric, ginger tea\n- Stay hydrated with at least 8 glasses of water\n- Avoid excess salt, caffeine, and sugary snacks';
    }

    if (query.contains('pain') ||
        query.contains('cramp') ||
        query.contains('hurt')) {
      return 'For menstrual cramps, try a heating pad on your lower abdomen, light yoga stretches, ibuprofen with food, ginger or chamomile tea, and extra rest. If pain is severe or unusual, please see a doctor.';
    }

    if (query.contains('late') ||
        query.contains('irregular') ||
        query.contains('missed')) {
      return 'A late or irregular cycle can be caused by stress, intense exercise, sudden weight changes, poor sleep, illness, medication, or pregnancy. If it is more than 2 weeks late and you are sexually active, take a pregnancy test. If irregularity keeps happening, consult your gynecologist.';
    }

    if (query.contains('ovulation') || query.contains('fertile')) {
      return 'Signs of ovulation can include a slight rise in basal body temperature, clear stretchy cervical mucus, mild pelvic cramping, and positive ovulation predictor kits. Your fertile window is often around Day 10-16.';
    }

    if (query.contains('mood') ||
        query.contains('pms') ||
        query.contains('emotional')) {
      return 'PMS mood swings are caused by hormonal shifts. Meditation, light exercise, 8 hours of sleep, and magnesium-rich foods can help. Tracking your cycle helps you prepare for those changes.';
    }

    if (query.contains('water') || query.contains('hydrat')) {
      return 'Hydration helps hormonal balance.\n\n- Period: 8-10 glasses a day\n- Pregnancy: 10-12 glasses a day\n- Ovulation phase: about 8 glasses plus electrolytes';
    }

    if (query.contains('sleep') ||
        query.contains('insomnia') ||
        query.contains('rest')) {
      return 'Good sleep is essential for hormonal health. Aim for 7-9 hours per night, keep a steady schedule, and reduce screens 1 hour before bed.';
    }

    if (query.contains('exercise') ||
        query.contains('workout') ||
        query.contains('sport')) {
      return 'Exercise recommendations by phase:\n\n- Menstrual: gentle walks, yoga, stretching\n- Follicular: cardio, HIIT, strength training\n- Ovulation: higher intensity if you feel good\n- Luteal: pilates, swimming, light cardio';
    }

    if (query.contains('cycle length') ||
        query.contains('how long') ||
        query.contains('normal cycle')) {
      return 'A normal menstrual cycle is usually 21-35 days, and bleeding often lasts 3-7 days. Cycles longer than 35 days can be seen with PCOS/PCOD or thyroid issues, so consistent tracking is helpful.';
    }

    final fallbacks = <String>[
      "That's a great question. I'd recommend logging it as a symptom in your Cycle tracker for better AI insights over time.",
      'I can help better if you tell me more about what you are experiencing.',
      'Your health journey is unique. Try the AI Insights tab for recommendations based on your cycle data.',
      'Small, consistent habits can make a big difference. Track mood, sleep, and symptoms daily for smarter predictions.',
      'This app provides general wellness guidance and does not replace a healthcare professional.',
    ];

    return fallbacks[_random.nextInt(fallbacks.length)];
  }
}
