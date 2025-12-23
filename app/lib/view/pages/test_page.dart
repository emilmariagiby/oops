// pages/test_page.dart
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // Page states: 0 = Instructions, 1 = Quiz, 2 = Results
  int pageState = 0;

  // Hardcoded quiz data
  final List<Map<String, dynamic>> questions = [
    {
      'question': '1. What does HTML stand for?',
      'options': [
        'Hyper Trainer Marking Language',
        'Hyper Text Markup Language',
        'Hyper Text Markdown Language',
        'Home Tool Markup Language'
      ],
      'answer': 1,
    },
    {
      'question': '2. Which language is used for styling web pages?',
      'options': ['HTML', 'CSS', 'Python', 'Java'],
      'answer': 1,
    },
    {
      'question': '3. What does CPU stand for?',
      'options': [
        'Central Process Unit',
        'Central Processing Unit',
        'Computer Personal Unit',
        'Central Processor Utility'
      ],
      'answer': 1,
    },
  ];

  int currentQuestion = 0;
  int score = 0;
  int? selectedOption;

  void checkAnswer(int selectedIndex) {
    setState(() {
      selectedOption = selectedIndex;
      if (selectedIndex == questions[currentQuestion]['answer']) {
        score++;
      }

      // Move to next question or end quiz
      Future.delayed(const Duration(seconds: 1), () {
        if (currentQuestion < questions.length - 1) {
          setState(() {
            currentQuestion++;
            selectedOption = null;
          });
        } else {
          setState(() {
            pageState = 2; // Move to results
          });
        }
      });
    });
  }

  void startQuiz() {
    setState(() {
      pageState = 1;
    });
  }

  void restartQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      pageState = 0;
      selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2563EB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          pageState == 0 ? 'Skill Assessment' : pageState == 1 ? 'Test in Progress' : 'Test Results',
          style: TextStyle(
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: pageState == 0
          ? _buildInstructionsScreen(isDark)
          : pageState == 1
              ? _buildQuestionScreen(isDark)
              : _buildResultScreen(isDark),
    );
  }

  Widget _buildInstructionsScreen(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 80,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Title
          Center(
            child: Text(
              'Skill Assessment Test',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Read the instructions carefully before starting',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // Instructions Container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildInstructionItem(
                  isDark,
                  Icons.timer_outlined,
                  'Time Limit',
                  'No time limit - take your time to answer carefully',
                ),
                _buildInstructionItem(
                  isDark,
                  Icons.quiz_outlined,
                  'Total Questions',
                  '${questions.length} multiple choice questions',
                ),
                _buildInstructionItem(
                  isDark,
                  Icons.touch_app_outlined,
                  'Selection',
                  'Tap on an option to select your answer',
                ),
                _buildInstructionItem(
                  isDark,
                  Icons.check_circle_outline,
                  'Auto-Progress',
                  'Questions advance automatically after selection',
                ),
                _buildInstructionItem(
                  isDark,
                  Icons.score_outlined,
                  'Scoring',
                  'Each correct answer is worth 1 point',
                ),
                _buildInstructionItem(
                  isDark,
                  Icons.replay_outlined,
                  'Retake',
                  'You can retake the test after completion',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          // Important Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFBBF24),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Make sure you\'re in a quiet environment before starting the test.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Start Test Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Test',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(
    bool isDark,
    IconData icon,
    String title,
    String description, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(bool isDark) {
    final question = questions[currentQuestion];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Question ${currentQuestion + 1} of ${questions.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
              backgroundColor: isDark ? const Color(0xFF334155) : Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 30),
          
          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              question['question'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Options
          ...List.generate(question['options'].length, (index) {
            final option = question['options'][index];
            final isSelected = selectedOption == index;
            final isCorrect = index == question['answer'];
            
            return GestureDetector(
              onTap: selectedOption == null ? () => checkAnswer(index) : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isCorrect
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFFEF4444).withOpacity(0.1))
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                        : (isDark ? const Color(0xFF334155) : Colors.grey[300]!),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                              : (isDark ? const Color(0xFF64748B) : Colors.grey[400]!),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              isCorrect ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultScreen(bool isDark) {
    final percentage = (score / questions.length * 100).round();
    final passed = score >= (questions.length / 2);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Result Icon
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: (passed ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              size: 100,
              color: passed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 40),
          
          // Result Text
          Text(
            passed ? 'Congratulations!' : 'Keep Practicing!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            passed
                ? 'You passed the skill assessment'
                : 'Don\'t give up, try again!',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 40),
          
          // Score Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    Text(
                      ' / ${questions.length}',
                      style: TextStyle(
                        fontSize: 30,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$percentage% Correct',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: passed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: restartQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.replay, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Retake Test',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 2,
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}