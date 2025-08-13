// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stylesync/Screens/HomePage.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  void _next() async {
    if (_index < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final ob = context.read<OnboardingProvider>();
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    if (ob.isValid) {
      await ob.saveFor(
        u.uid,
        email: u.email,
        displayName: u.displayName,
        photoUrl: u.photoURL,
      );

      if (!mounted) return;

      // Navigate to home immediately after successful save
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_index < 2 ? 'Tell us your style' : 'Finish'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [
                  _RegionStyleStep(),
                  _ColorSizeStep(),
                  _BudgetStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: CupertinoButton.filled(
                onPressed: ob.isValid || _index < 2 ? _next : null,
                child: Text(_index < 2 ? 'Continue' : 'Create my profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Steps ---------- */

class _RegionStyleStep extends StatelessWidget {
  const _RegionStyleStep();

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    return _StepContainer(
      title: 'Region & Style',
      child: Column(
        children: [
          _PickerRow(
            label: 'Region',
            value: ob.region ?? 'Select',
            onTap: () async {
              final selected = await _showPicker(context, ['US','EU','UK','PK','IN','GCC','SEA']);
              if (selected != null) context.read<OnboardingProvider>().setRegion(selected);
            },
          ),
          const SizedBox(height: 12),
          _PickerRow(
            label: 'Style',
            value: ob.styleType ?? 'Select',
            onTap: () async {
              final selected = await _showPicker(context, ['Casual','Formal','Streetwear','Athleisure','Smart Casual']);
              if (selected != null) context.read<OnboardingProvider>().setStyleType(selected);
            },
          ),
        ],
      ),
    );
  }
}

class _ColorSizeStep extends StatelessWidget {
  const _ColorSizeStep();

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    final colors = ['Black','White','Blue','Green','Red','Yellow','Purple','Beige'];

    return _StepContainer(
      title: 'Colors & Sizes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Favorite Colors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: colors.map((c) {
              final selected = ob.favoriteColors.contains(c);
              return CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: selected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
                onPressed: () => context.read<OnboardingProvider>().toggleColor(c),
                child: Text(c, style: TextStyle(color: selected ? CupertinoColors.white : CupertinoColors.black)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Sizes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _SizeRow(label: 'Top', onSubmitted: (v) => context.read<OnboardingProvider>().setSize('top', v)),
          _SizeRow(label: 'Bottom', onSubmitted: (v) => context.read<OnboardingProvider>().setSize('bottom', v)),
          _SizeRow(label: 'Shoes', onSubmitted: (v) => context.read<OnboardingProvider>().setSize('shoes', v)),
        ],
      ),
    );
  }
}

class _BudgetStep extends StatelessWidget {
  const _BudgetStep();

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    return _StepContainer(
      title: 'Budget',
      child: Column(
        children: [
          _PickerRow(
            label: 'Budget Tier',
            value: ob.budgetTier ?? 'Select',
            onTap: () async {
              final selected = await _showPicker(context, ['Low','Mid','High','Luxury']);
              if (selected != null) context.read<OnboardingProvider>().setBudget(selected);
            },
          ),
          const SizedBox(height: 8),
          const Text('You can change these later in Settings.',
              style: TextStyle(color: CupertinoColors.systemGrey)),
        ],
      ),
    );
  }
}

/* ---------- UI helpers ---------- */

class _StepContainer extends StatelessWidget {
  final String title;
  final Widget child;
  const _StepContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _PickerRow({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      color: CupertinoColors.systemGrey5,
      borderRadius: BorderRadius.circular(12),
      onPressed: onTap,
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(color: CupertinoColors.systemGrey)),
          const SizedBox(width: 6),
          const Icon(CupertinoIcons.chevron_right, size: 16),
        ],
      ),
    );
  }
}

class _SizeRow extends StatelessWidget {
  final String label;
  final ValueChanged<String> onSubmitted;
  const _SizeRow({required this.label, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'e.g., M / 32 / 42',
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> _showPicker(BuildContext context, List<String> items) async {
  String sel = items.first;
  return showCupertinoModalPopup<String>(
    context: context,
    builder: (ctx) {
      return Container(
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        height: 260,
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (i) => sel = items[i],
                children: items.map((e) => Center(child: Text(e))).toList(),
              ),
            ),
            CupertinoButton(
              child: const Text('Select'),
              onPressed: () => Navigator.pop(ctx, sel),
            )
          ],
        ),
      );
    },
  );
}
