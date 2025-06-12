import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_page/screens/login.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  
    
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Image.asset('assets/images/newspaper_onboard.jpg',
            
            height: screenSize.height * 0.6,
            width: screenSize.width,
            fit: BoxFit.fitWidth,
          ),
          Container(
            height: screenSize.height * 0.4,
            width: screenSize.width,
            padding: EdgeInsets.all(24.0),
            color: Color(0xFFECEFF1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Stay Ahead with Breaking News",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Access the latest headlines and in-depth stories from around the globe, anytime, anywhere.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF616161),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () =>Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF64B5F6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}