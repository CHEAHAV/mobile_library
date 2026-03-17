import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';            // ✅ import AuthGate
import 'package:frontend/models/content_model.dart';
import 'package:frontend/styles/app_styles.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  late PageController _controller;
  int currentIndex = 0;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 52,
                      right: 20,
                      left: 20,
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          contents[i].image,
                          height: 450,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          contents[i].title,
                          style: AppStyles.simpleboolTextStyle(),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          contents[i].description,
                          style: AppStyles.simpleTextStyle(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Dots ────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                (index) => buildDot(index, context),
              ),
            ),

            // ── Next / Get Started button ────────────────────────────────
            GestureDetector(
              onTap: () {
                if (currentIndex == contents.length - 1) {
                  // ✅ Navigate to AuthGate — which wires onTap correctly
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthGate(), // ✅ NOT LoginPage()
                    ),
                  );
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.bounceIn,
                  );
                }
              },
              child: DropShadow(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.all(40),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      currentIndex == contents.length - 1
                          ? 'Get Started' // ✅ last page shows "Get Started"
                          : 'Next',
                      style: AppStyles.boolTextStyle().copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 18 : 7,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey[700],
      ),
    );
  }
}