import 'dart:math';

import 'package:flutter/material.dart';

import 'package:femi_friendly/models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final Random _random = Random();

  final List<ChatMessage> _messages = <ChatMessage>[
    ChatMessage(
      text:
          'Hi! 🌸 I\'m your Femi AI assistant. I can help with menstrual health, fertility, pregnancy tips, and more. What\'s on your mind today?',
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

    // Simulated AI thinking delay (realistic)
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
    _messages.clear();
    _messages.add(
      ChatMessage(
        text: 'Chat cleared! 🌸 How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  String _buildSmartResponse(String text) {
    final query = text.toLowerCase();

    // Pregnancy questions
    if (query.contains('pregnant') ||
        query.contains('conceive') ||
        query.contains('get pregnant')) {
      return '🤰 The best time to conceive is during your **fertile window** — typically Day 10–16 of a 28-day cycle. Ovulation usually happens around Day 14. Track your basal body temperature and look for egg-white cervical mucus as signs of ovulation. For the most accurate prediction, use our AI Insights tab! ✨';
    }

    // Pregnancy trimester tips
    if (query.contains('pregnancy') ||
        query.contains('trimester') ||
        query.contains('prenatal')) {
      return '🌸 Pregnancy tips by trimester:\n\n**1st (Weeks 1–12):** Take folic acid 400–800mcg, stay hydrated, and avoid raw seafood.\n\n**2nd (Weeks 13–27):** Focus on iron & calcium. Light exercise like prenatal yoga is great!\n\n**3rd (Weeks 28–40):** Rest more, eat protein-rich foods, and prep your birth plan.\n\nAlways consult your OB-GYN for personalized advice. 💙';
    }

    // Period food
    if (query.contains('eat') ||
        query.contains('food') ||
        query.contains('diet') ||
        query.contains('nutrition')) {
      return '🥗 **Best foods during your period:**\n\n• 🩸 Iron-rich: spinach, lentils, red meat\n• 🍫 Magnesium: dark chocolate, bananas\n• 🫐 Anti-inflammatory: berries, turmeric, ginger tea\n• 💧 Stay hydrated with at least 8 glasses of water\n• ❌ Avoid: excess salt, caffeine, sugary snacks\n\nNourish yourself — you deserve it! 🌸';
    }

    // Cramps / pain
    if (query.contains('pain') ||
        query.contains('cramp') ||
        query.contains('hurt')) {
      return '💗 For menstrual cramps, try:\n\n• 🔥 A warm heating pad on your lower abdomen\n• 🧘 Light yoga stretches (child\'s pose, cat-cow)\n• 💊 Ibuprofen (with food) for pain relief\n• 🫖 Ginger or chamomile tea\n• 😴 Rest and prioritize sleep\n\nIf pain is severe or unusual, please see a doctor. You got this! 💪';
    }

    // Late or irregular cycle
    if (query.contains('late') ||
        query.contains('irregular') ||
        query.contains('missed')) {
      return '📅 A late or irregular cycle can be caused by:\n\n• 😰 Stress or anxiety\n• 🏋️ Intense exercise or sudden weight changes\n• 💤 Sleep disruption\n• 🤒 Illness or medication\n• 🤰 Pregnancy (if sexually active)\n\nIf it\'s more than 2 weeks late and you\'re sexually active, take a pregnancy test. If irregularity persists, consult your gynecologist. 💙';
    }

    // Ovulation
    if (query.contains('ovulation') || query.contains('fertile')) {
      return '✨ **Signs of ovulation:**\n\n• 📈 Slight rise in basal body temperature\n• 🌡️ Cervical mucus becomes clear and stretchy\n• 🤏 Mild pelvic cramping (mittelschmerz)\n• 📊 Ovulation predictor kits (OPKs) can confirm\n\nYour fertile window is typically Day 10–16. Check the AI Insights tab for your personalized prediction! 🌸';
    }

    // Mood / PMS
    if (query.contains('mood') ||
        query.contains('pms') ||
        query.contains('emotional')) {
      return '💜 PMS mood swings are very real! They\'re caused by hormonal shifts:\n\n• 🌙 During luteal phase (Day 17–28), progesterone rises then drops\n• 🧘 Meditation and light exercise help regulate mood\n• 💤 Prioritize 8 hours of sleep\n• 🍫 Magnesium-rich foods reduce PMS symptoms\n• 📱 Tracking your cycle helps predict and prepare\n\nYou\'re not alone — your emotions are valid! 🌸';
    }

    // Water intake
    if (query.contains('water') || query.contains('hydrat')) {
      return '💧 Hydration is crucial for hormonal balance!\n\n• **Period:** 8–10 glasses/day (reduces bloating)\n• **Pregnancy:** 10–12 glasses/day\n• **Ovulation phase:** 8 glasses + electrolytes\n\nAdd lemon, cucumber, or mint to make water more enjoyable. Herbal teas also count! 🍵';
    }

    // Sleep
    if (query.contains('sleep') || query.contains('insomnia') || query.contains('rest')) {
      return '😴 Good sleep is essential for hormonal health:\n\n• Aim for **7–9 hours** per night\n• Your cycle phase affects sleep quality\n• Luteal phase: progesterone can cause fatigue\n• During periods: pain may disrupt sleep — try a heating pad\n• Avoid screens 1 hour before bed\n\nA consistent sleep schedule regulates your cycle! 🌙';
    }

    // Exercise
    if (query.contains('exercise') ||
        query.contains('workout') ||
        query.contains('sport')) {
      return '🏃‍♀️ **Exercise recommendations by phase:**\n\n• 🩸 Menstrual: Gentle walks, yoga, stretching\n• 🌱 Follicular: Cardio, HIIT, strength training\n• ✨ Ovulation: High intensity — best performance!\n• 🌙 Luteal: Pilates, swimming, light cardio\n\nListening to your body is key. Moving even a little helps with cramps and mood! 💪';
    }

    // Cycle length query
    if (query.contains('cycle length') ||
        query.contains('how long') ||
        query.contains('normal cycle')) {
      return '📊 A **normal menstrual cycle** is 21–35 days, with the average being 28 days. Period duration is typically 3–7 days.\n\n• Short cycles (<21 days): may indicate hormonal imbalance\n• Long cycles (>35 days): PCOS or thyroid issues possible\n\nTrack at least 3 cycles for an accurate average. Your data in the Cycle tab will help! 🌸';
    }

    // Default smart fallbacks
    final fallbacks = <String>[
      '🌸 That\'s a great question! I\'d recommend logging that as a symptom in your Cycle tracker for better AI insights over time.',
      '💙 I\'m here to help! Could you tell me more about what you\'re experiencing? The more detail, the better I can assist.',
      '✨ Your health journey is unique. Would you like to explore the AI Insights tab for personalized recommendations based on your cycle data?',
      '🌺 Small, consistent habits make a big difference for menstrual health. Try tracking your mood, sleep, and symptoms daily for smarter predictions!',
      '💗 Remember: this app provides general wellness guidance. For medical concerns, always consult a qualified healthcare professional. How else can I help?',
    ];

    return fallbacks[_random.nextInt(fallbacks.length)];
  }
}
