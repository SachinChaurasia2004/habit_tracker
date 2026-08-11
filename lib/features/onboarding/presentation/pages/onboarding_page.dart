import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../data/onboarding_content.dart';
import '../../data/models/onboarding_page_model.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/animated_emoji.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late TextEditingController _nameController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _nameController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

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
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.forward(from: 0);
  }

  void _nextPage() {
    if (_currentPage < OnboardingContent.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _pageController.animateToPage(
      OnboardingContent.pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name to continue.')),
      );
      return;
    }

    final saveResult = await getIt<ProfileRepository>().updateName(name);
    if (!mounted) return;

    final saveFailed = saveResult.fold((_) => true, (_) => false);
    if (saveFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your name. Please try again.')),
      );
      return;
    }

    context.read<ProfileBloc>().add(const LoadProfileEvent());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainNavigation(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPageData = OnboardingContent.pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  currentPageData.primaryColor.withValues(alpha: 0.15),
                  AppColors.background,
                  AppColors.background,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Floating particles
          _buildFloatingParticles(currentPageData.primaryColor),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                if (_currentPage < OnboardingContent.pages.length - 1)
                  _buildSkipButton(),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: OnboardingContent.pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(
                        OnboardingContent.pages[index],
                        isLastPage: index == OnboardingContent.pages.length - 1,
                      );
                    },
                  ),
                ),

                // Bottom section
                _buildBottomSection(currentPageData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    OnboardingPageModel pageData, {
    required bool isLastPage,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          left: context.pagePadding,
          right: context.pagePadding,
          bottom: MediaQuery.viewInsetsOf(context).bottom + context.spacing(24),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Animated emoji
                AnimatedEmoji(
                  emoji: pageData.image,
                  color: pageData.primaryColor,
                ),

                SizedBox(height: context.spacing(60)),

                // Title
                Text(
                  pageData.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(32),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: context.spacing(24)),

                // Description
                Text(
                  pageData.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(16),
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                ),

                if (isLastPage) ...[
                  SizedBox(height: context.spacing(32)),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _finishOnboarding(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Your name',
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(OnboardingPageModel pageData) {
    final isLastPage = _currentPage == OnboardingContent.pages.length - 1;

    return Container(
      padding: EdgeInsets.all(context.spacing(32)),
      child: Column(
        children: [
          // Page indicators
          OnboardingIndicator(
            currentPage: _currentPage,
            pageCount: OnboardingContent.pages.length,
            activeColor: pageData.primaryColor,
          ),

          SizedBox(height: context.spacing(32)),

          // Next/Get Started button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: pageData.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: TextStyle(
                      fontSize: context.fontSize(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastPage ? Icons.check : Icons.arrow_forward,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticles(Color color) {
    return Stack(
      children: List.generate(
        8,
        (index) => _FloatingParticle(
          color: color,
          index: index,
        ),
      ),
    );
  }
}

// Floating particle widget
class _FloatingParticle extends StatefulWidget {
  final Color color;
  final int index;

  const _FloatingParticle({
    required this.color,
    required this.index,
  });

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 3000 + widget.index * 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final random = math.Random(widget.index);
    final size = random.nextDouble() * 60 + 40;
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final top = random.nextDouble() * MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: left,
          top: top + (_animation.value * 50),
          child: Opacity(
            opacity: 0.1,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color.withValues(alpha: 0.3),
                    widget.color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
