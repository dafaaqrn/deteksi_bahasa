import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../screens/auth_gate.dart';

class _OnboardingSlide {
  final String badge;
  final String badgeIcon;
  final String image;
  final String title;
  final String subtitle;
  final Color badgeBg;
  final Color badgeFg;

  const _OnboardingSlide({
    required this.badge,
    required this.badgeIcon,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.badgeBg,
    required this.badgeFg,
  });
}

class IntroductionAnimationScreen extends StatefulWidget {
  const IntroductionAnimationScreen({super.key});

  @override
  State<IntroductionAnimationScreen> createState() =>
      _IntroductionAnimationScreenState();
}

class _IntroductionAnimationScreenState
    extends State<IntroductionAnimationScreen> {
  static const _cream = Color(0xFFFCFBF8);

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      badge: 'Akurat & Responsif',
      badgeIcon: '✨',
      image: 'assets/images/onboarding_1.png',
      title: 'Terjemahkan Bahasa Isyarat Secara Instan',
      subtitle:
          'Arahkan kamera ke gerakan tangan, dan lihat terjemahannya langsung muncul sebagai teks.',
      badgeBg: AppColors.primaryFixed,
      badgeFg: AppColors.primary,
    ),
    _OnboardingSlide(
      badge: 'Hemat Kuota & Offline',
      badgeIcon: '⚡',
      image: 'assets/images/onboarding_2.png',
      title: 'Berjalan Langsung di HP Kamu',
      subtitle:
          'Deteksi diproses di perangkat kamu sendiri, tetap bisa dipakai walau tanpa koneksi internet.',
      badgeBg: AppColors.tertiaryFixed,
      badgeFg: AppColors.tertiary,
    ),
    _OnboardingSlide(
      badge: 'Mudah & Menyenangkan',
      badgeIcon: '📖',
      image: 'assets/images/onboarding_3.png',
      title: 'Belajar Sambil Berkomunikasi',
      subtitle:
          'Jelajahi kamus kosakata BISINDO dan pantau riwayat percakapanmu kapan saja.',
      badgeBg: AppColors.primaryFixed,
      badgeFg: AppColors.primary,
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _handleNext() {
    if (_isLastPage) {
      _finishOnboarding();
    } else {
      _goToPage(_currentPage + 1);
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()),
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
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _buildSlide(_slides[index]),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pan_tool_alt, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                'BISINDO AI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          AnimatedOpacity(
            opacity: _isLastPage ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            child: TextButton(
              onPressed: _isLastPage ? null : () => _goToPage(_slides.length - 1),
              style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
              child: const Text('Lewati', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryFixed, width: 1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset(
                    slide.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceContainerLow,
                      alignment: Alignment.center,
                      child: Icon(Icons.image_outlined,
                          size: 48, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: slide.badgeBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${slide.badgeIcon} ${slide.badge}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: slide.badgeFg,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (index) {
              final active = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Icon(_isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}