import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../data/onboarding_content.dart';
import '../../data/models/onboarding_page_model.dart';

class OnboardingCardsPage extends StatefulWidget {
  const OnboardingCardsPage({super.key});

  @override
  State<OnboardingCardsPage> createState() => _OnboardingCardsPageState();
}

class _OnboardingCardsPageState extends State<OnboardingCardsPage> {
  late PageController _pageController;
  int _currentPage = 0;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0;
      });
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: OnboardingContent.pages.length,
                itemBuilder: (context, index) {
                  final page = OnboardingContent.pages[index];
                  final offset = _pageOffset - index;
                  
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      return _buildCard(page, offset);
                    },
                  );
                },
              ),
            ),

            // Bottom section
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(context.spacing(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Habitus',
            style: TextStyle(
              fontSize: context.fontSize(24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (_currentPage < OnboardingContent.pages.length - 1)
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainNavigation(),
                  ),
                );
              },
              child: const Text('Skip'),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(OnboardingPageModel page, double offset) {
    final scale = 1.0 - (offset.abs() * 0.1).clamp(0.0, 0.3);
    final opacity = 1.0 - (offset.abs() * 0.5).clamp(0.0, 1.0);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: context.spacing(8),
            vertical: context.spacing(40),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                page.primaryColor.withValues(alpha: 0.3),
                page.secondaryColor.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: page.primaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: page.primaryColor.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PatternPainter(
                      color: page.primaryColor.withValues(alpha: 0.05),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(context.spacing(32)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji
                      Text(
                        page.image,
                        style: const TextStyle(fontSize: 100),
                      ),

                      SizedBox(height: context.spacing(40)),

                      // Title
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.fontSize(28),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: context.spacing(16)),

                      // Description
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.fontSize(16),
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    final isLastPage = _currentPage == OnboardingContent.pages.length - 1;

    return Padding(
      padding: EdgeInsets.all(context.spacing(32)),
      child: Column(
        children: [
          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              OnboardingContent.pages.length,
              (index) => Container(
                width: index == _currentPage ? 32 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index == _currentPage
                      ? OnboardingContent.pages[_currentPage].primaryColor
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

          SizedBox(height: context.spacing(24)),

          // Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (isLastPage) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainNavigation(),
                    ),
                  );
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingContent.pages[_currentPage].primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLastPage ? 'Get Started' : 'Continue',
                style: TextStyle(
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pattern painter for background
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
