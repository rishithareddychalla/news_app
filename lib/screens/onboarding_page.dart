import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_page/screens/login.dart';
import 'package:confetti/confetti.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final ConfettiController _confettiController = ConfettiController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Stay Ahead with Breaking News',
      'desc':
          'Get top stories, personalized updates,\nand live reports at your fingertips.',
      'asset': 'assets/animations/Hello kirte gsdg gb dsg.json',
    },
    {
      'title': 'Real-Time Global Coverage',
      'desc': 'Breaking news from across the globe\nin real-time.',
      'asset': 'assets/animations/Global Network.json',
    },
    {
      'title': 'Personalized for You',
      'desc': 'Choose what matters most and\ncustomize your news feed.',
      'asset': 'assets/animations/Appointment booking with smartphone.json',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    _confettiController.play();
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder:
                (context, index) => Column(
                  children: [
                    SizedBox(
                      height: screenSize.height * 0.55,
                      width: double.infinity,
                      child: Lottie.asset(
                        _onboardingData[index]['asset']!,
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  _onboardingData[index]['title']!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                    color: const Color(0xFF0D47A1),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _onboardingData[index]['desc']!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF424242),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _onboardingData.length,
                                    (i) => AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      height: 8,
                                      width: _currentPage == i ? 24 : 8,
                                      decoration: BoxDecoration(
                                        color:
                                            _currentPage == i
                                                ? const Color(0xFF1E88E5)
                                                : Colors.grey,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed:
                                      _currentPage == _onboardingData.length - 1
                                          ? _completeOnboarding
                                          : () => _pageController.nextPage(
                                            duration: const Duration(
                                              milliseconds: 400,
                                            ),
                                            curve: Curves.easeInOut,
                                          ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E88E5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 6,
                                  ),
                                  child: Text(
                                    _currentPage == _onboardingData.length - 1
                                        ? "Get Started"
                                        : "Next",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _completeOnboarding,
                                  child: const Text(
                                    "Skip",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 40,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
