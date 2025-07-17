import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'profile_setup_screen.dart';
import '../../../../features/home/domain/usecases/get_work_entries_usecase.dart';

class GetStartedScreen extends StatefulWidget {
  final GetWorkEntriesUseCase getWorkEntriesUseCase;
  const GetStartedScreen({super.key, required this.getWorkEntriesUseCase});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to HourMate',
      subtitle: 'Track your work hours with style',
      description:
          'Transform your work tracking experience with our modern, neon-themed interface designed for productivity.',
      icon: Icons.access_time_rounded,
    ),
    OnboardingPage(
      title: 'Smart Time Tracking',
      subtitle: 'Clock in, clock out, stay focused',
      description:
          'Easily track your work sessions, monitor productivity, and visualize your progress with beautiful charts.',
      icon: Icons.work_rounded,
    ),
    OnboardingPage(
      title: 'Insights & Analytics',
      subtitle: 'Turn data into victories',
      description:
          'Get detailed insights into your work patterns, productivity trends, and achieve your professional goals.',
      icon: Icons.analytics_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToProfileSetup();
    }
  }

  void _navigateToProfileSetup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileSetupScreen(
          getWorkEntriesUseCase: widget.getWorkEntriesUseCase,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.neonYellowGreen.withValues(alpha: 0.15),
              AppTheme.backgroundColor,
              AppTheme.backgroundColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.cyanBlue, AppTheme.neonYellowGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonYellowGreen.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: AppTheme.black,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'HourMate',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppTheme.primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                    ),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.neonYellowGreen
                            : AppTheme.secondaryTextColor.withValues(
                                alpha: 0.3,
                              ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: _currentPage == index
                            ? [
                                BoxShadow(
                                  color: AppTheme.neonYellowGreen.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ),

              // Next Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.cyanBlue, AppTheme.neonYellowGreen],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _nextPage,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppTheme.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  page.iconColor.withValues(alpha: 0.2),
                  page.iconColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 60, color: page.iconColor),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.neonYellowGreen,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color iconColor;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.iconColor = AppTheme.neonYellowGreen,
  });
}
