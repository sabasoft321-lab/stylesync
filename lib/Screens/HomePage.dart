import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stylesync/Screens/profileTab.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showTooltip = false; // Flag to show/hide the tooltip message

  @override
  void initState() {
    super.initState();

    // Show the tooltip after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showTooltip = true;
        });
      }
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showTooltip = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // iOS status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Stack(
      children: [
        CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: CupertinoColors.systemGrey6.withOpacity(0.9),
            border: null,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house_alt, size: 26),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_grid_2x2, size: 26),
                label: 'Browse',
              ),
              BottomNavigationBarItem(
                // Bigger center + icon (always larger)
                icon: Icon(CupertinoIcons.add_circled_solid, size: 38),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.bell, size: 26),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_crop_circle, size: 26),
                label: 'Profile',
              ),
            ],
            currentIndex: _currentIndex,
            onTap: (index) async {
              if (index == 2) {
                // Center action (+)
                await _showPrimaryAction(context);
                return; // keep the current tab after action
              }
              setState(() => _currentIndex = index);
            },
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return const _HomeTab();
              case 1:
                return const _SimpleTab(title: 'Browse');
              case 2:
              // We don’t navigate to a page for the +; keep user on current tab
                return const _HomeTab();
              case 3:
                return const _SimpleTab(title: 'Alerts');
              case 4:
                return const ProfileTab();
              default:
                return const _HomeTab();
            }
          },
        ),

        // Tooltip that appears after 3 seconds
        if (_showTooltip)
          Positioned(
            bottom: 140,  // Positioning above the button
            right: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey.withOpacity(0.9),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12), bottomLeft: Radius.circular(12),),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.bubble_left, size: 18, color: CupertinoColors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Hi 👋, how can I help you?',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ],
              ),
            ),
          ),

        // Floating Action Button
        Positioned(
          bottom: 66,
          right: 16,
          child: CupertinoButton.filled(
            padding: const EdgeInsets.all(16), // Add padding to make it larger
            borderRadius: BorderRadius.circular(50), // Rounded button
            color: CupertinoColors.activeBlue, // Button color
            onPressed: () {
              // Action when button is pressed
              print('Button Pressed');
            },
            child: const Icon(
              CupertinoIcons.text_bubble,
              size: 40, // Icon size
              color: CupertinoColors.white, // Icon color
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showPrimaryAction(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Quick Action'),
        message: const Text('Choose what you want to add.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Create Outfit'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add Item'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

/* ---------------- Tabs ---------------- */

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Home'),
        border: null,
      ),
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(  // Wrap the Column with SingleChildScrollView
              child: Column(
                children: [
                  SizedBox(height: 12),
                  _HeroCarousel(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height
                  _SectionHeader('Recommended'),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.015,
                  ),
                  _CardRow(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _SectionHeader('Trending'),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.015,
                  ),
                  _CardRow(),
                ],
              ),
            ),
          ),

        ],
      )

    );
  }
}



class _SimpleTab extends StatelessWidget {
  final String title;
  const _SimpleTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        border: null,
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}

/* ---------------- Hero Carousel ---------------- */

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController(viewportFraction: 0.88);
  int _page = 0;
  Timer? _timer;

  final _cards = const [
    _HeroCard(color: CupertinoColors.systemBlue, title: 'Smart Fits', subtitle: 'Curated for you'),
    _HeroCard(color: CupertinoColors.systemPink, title: 'Top Picks', subtitle: 'This week’s best'),
    _HeroCard(color: CupertinoColors.systemTeal, title: 'Summer Styles', subtitle: 'Breezy & light'),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_page + 1) % _cards.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Responsive height based on width; clamped so it never gets too small/large
    final double pvHeight = (size.width * 0.52).clamp(180.0, 280.0);

    return Column(
      children: [
        SizedBox(
          height: pvHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: _cards.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final isActive = index == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: isActive ? 6 : 14),
                child: _cards[index],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_cards.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? CupertinoColors.activeBlue : CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  const _HeroCard({required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: CupertinoColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, color: CupertinoColors.white),
          ),
          const SizedBox(height: 12),
          // Flexible image area so the Column always fits its parent height.
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Icon(CupertinoIcons.photo_on_rectangle, size: 40, color: CupertinoColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Small Sections ---------------- */

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          const Icon(CupertinoIcons.chevron_right, size: 18, color: CupertinoColors.systemGrey),
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    final isTablet = shortest >= 600;

    // Scale values with clamps for consistency across devices
    double _clamp(double v, double min, double max) =>
        v.clamp(min, max);

    final double rowHeight = _clamp(size.height * (isTablet ? 0.24 : 0.18), 120, 220);
    final double cardWidth  = _clamp(size.width * (isTablet ? 0.28 : 0.60), 140, 260);
    final double hPad       = _clamp(size.width * 0.04, 12, 24);
    final double gap        = _clamp(size.width * 0.03, 8, 20);
    final double radius     = isTablet ? 20 : 16;
    final double iconSize   = isTablet ? 36 : 28;

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        separatorBuilder: (_, __) => SizedBox(width: gap),
        itemBuilder: (_, i) => Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(
            child: Icon(
              CupertinoIcons.cube_box,
              size: iconSize,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      ),
    );
  }
}
