import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'camera_screen.dart';
import 'dictionary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _soundOn = true;
  int _carouselIndex = 0;
  final PageController _carouselController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  void _openDictionary() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DictionaryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildStatusBadges(),
            const SizedBox(height: 20),
            _buildHeroCard(),
            const SizedBox(height: 24),
            _buildQuickShortcuts(),
            const SizedBox(height: 24),
            _buildDailyTip(),
            const SizedBox(height: 24),
            _buildPromoCarousel(),
            const SizedBox(height: 16),
            _buildStreakCard(),
          ],
        ),
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Halo, Dafa!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Siap berkomunikasi dan belajar BISINDO hari ini?',
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryFixed,
            border: Border.all(color: AppColors.primaryFixed, width: 2),
          ),
          child: Icon(Icons.person, color: AppColors.primary),
        ),
      ],
    );
  }

  // ---------- STATUS BADGES ----------
  Widget _buildStatusBadges() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'AI On-Device Siap (Offline)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => setState(() => _soundOn = !_soundOn),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.05), blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _soundOn ? Icons.volume_up : Icons.volume_off,
                    size: 18,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _soundOn ? 'Mode Suara Aktif' : 'Mode Hening',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- HERO CTA CARD ----------
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryContainer, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.sign_language,
              size: 130,
              color: AppColors.onPrimary.withValues(alpha: 0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 16, color: AppColors.primaryFixed),
                        const SizedBox(width: 6),
                        Text(
                          'Real-Time • On-Device',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryFixed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.videocam, color: AppColors.primaryFixed, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Deteksi Kamera AI',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Text(
                  'Arahkan kamera ke gerakan tangan untuk terjemahan teks instan tanpa jeda.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _openCamera,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.center_focus_strong, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Mulai Deteksi Sekarang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- QUICK SHORTCUTS ----------
  Widget _buildQuickShortcuts() {
    final items = [
      (Icons.spellcheck, 'Alfabet A-Z', '26 Isyarat Abjad', AppColors.primary, AppColors.surfaceContainerLow),
      (Icons.forum, 'Sehari-hari', 'Keluarga & Rasa', AppColors.secondary, AppColors.secondaryFixed),
      (Icons.bolt, 'Frasa Cepat', 'Siap Pakai', AppColors.tertiary, AppColors.tertiaryFixed),
      (Icons.menu_book, 'Kamus Lengkap', 'Semua Kosakata', AppColors.onSurfaceVariant, AppColors.surfaceContainerHigh),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Akses Pintas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            Text('4 Kategori', style: TextStyle(fontSize: 12, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.6,
          children: items.map((item) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _openDictionary,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.05), blurRadius: 12),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.$5,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.$1, color: item.$4, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.$2,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.$3,
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------- DAILY TIP ----------
  Widget _buildDailyTip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, size: 20, color: AppColors.tertiaryContainer),
            const SizedBox(width: 6),
            Text(
              'Kosakata Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.06), blurRadius: 16),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KATEGORI: SALAM & KERAMAHAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '"Terima Kasih"',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.surfaceContainer, shape: BoxShape.circle),
                    child: Icon(Icons.favorite, color: AppColors.primary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.pan_tool_alt, size: 56, color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sentuhkan ujung jari tangan kanan ke dagu, lalu gerakkan tangan ke depan secara lembut.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.onSurface, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_circle, size: 20),
                      label: const Text('Putar Contoh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circleIconButton(Icons.volume_up),
                  const SizedBox(width: 8),
                  _circleIconButton(Icons.bookmark_border),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
      child: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
    );
  }

  // ---------- PROMO CAROUSEL ----------
  Widget _buildPromoCarousel() {
    final promos = [
      ('Fitur Baru', Icons.record_voice_over, 'Percakapan 2 Arah Baru ✨',
          'Sekarang dilengkapi suara-ke-teks instan untuk teman dengar.', AppColors.secondaryFixed, AppColors.secondary),
      ('Offline Pack', Icons.medical_services, 'Isyarat Medis & Faskes 🏥',
          'Akses 120+ kosakata darurat tanpa memerlukan koneksi internet.', AppColors.primaryFixed, AppColors.primary),
      ('Komunitas', Icons.groups, 'Sesi Praktik Teman Tuli 🤝',
          'Ikuti obrolan hangat bersama komunitas BISINDO Sabtu ini.', AppColors.surfaceContainerHighest, AppColors.tertiary),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kabar & Pembaruan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            Row(
              children: List.generate(promos.length, (i) {
                final active = i == _carouselIndex;
                return Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: active ? 18 : 7,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _carouselController,
            itemCount: promos.length,
            onPageChanged: (i) => setState(() => _carouselIndex = i),
            itemBuilder: (context, index) {
              final (badge, icon, title, desc, bgColor, accentColor) = promos[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [bgColor.withValues(alpha: 0.5), AppColors.surfaceContainerLowest],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                          Icon(icon, color: accentColor, size: 22),
                        ],
                      ),
                      Text(
                        title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.3),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------- STREAK CARD ----------
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.primaryFixed, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.local_fire_department, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak 5 Hari! 🔥',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                  ),
                  Text(
                    'Latihan 1 gerakan lagi hari ini',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: _openDictionary,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLowest,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: const Text('Lanjut', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}