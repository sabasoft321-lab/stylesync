import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/ProfileProvider.dart';
import '../providers/auth_provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final List<String> _regions = ['US', 'EU', 'UK', 'PK', 'IN', 'GCC', 'SEA'];
  final List<String> _styleTypes = ['Casual', 'Formal', 'Streetwear', 'Athleisure', 'Smart Casual'];
  final List<String> _budgetTiers = ['Low', 'Mid', 'High', 'Luxury'];
  final List<String> _colors = ['Black', 'White', 'Blue', 'Green', 'Red', 'Yellow', 'Purple', 'Beige'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profileProvider = context.read<ProfileProvider>();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await profileProvider.fetchUserData(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<authProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profile'),
        border: null,
      ),
      child: SafeArea(
        child: profileProvider.user == null
            ? const Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(profileProvider),
                const SizedBox(height: 24),
                _buildPreferencesSection(profileProvider),
                const SizedBox(height: 32),
                Center(child: _buildActionButtons(auth, profileProvider)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider profileProvider) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  profileProvider.user?.photoUrl ?? 'https://via.placeholder.com/150',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CupertinoActivityIndicator(radius: 20));
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    CupertinoIcons.person_crop_circle,
                    size: 100,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CupertinoColors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.camera,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profileProvider.user?.displayName ?? 'No name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profileProvider.user?.email ?? 'No email',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildPickerRow(
          label: 'Region',
          value: profileProvider.user?.region ?? 'Select',
          onTap: () => _showPicker(
            context,
            _regions,
            profileProvider.user?.region ?? _regions.first,
                (selected) {
              print(selected);
              profileProvider.updateRegion(selected);
              setState(() {}); // Ensure UI updates after selection
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildPickerRow(
          label: 'Style',
          value: profileProvider.user?.styleType ?? 'Select',
          onTap: () => _showPicker(
            context,
            _styleTypes,
            profileProvider.user?.styleType ?? _styleTypes.first,
                (selected) {
              profileProvider.updateStyle(selected);
              setState(() {}); // Ensure UI updates after selection
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildColorSelection(profileProvider),
        const SizedBox(height: 12),
        _buildPickerRow(
          label: 'Budget Tier',
          value: profileProvider.user?.budgetTier ?? 'Select',
          onTap: () => _showPicker(
            context,
            _budgetTiers,
            profileProvider.user?.budgetTier ?? _budgetTiers.first,
                (selected) {
              profileProvider.updateBudget(selected);
              setState(() {}); // Ensure UI updates after selection
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPickerRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
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

  Widget _buildColorSelection(ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favorite Colors',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors.map((color) {
            final selected = profileProvider.user?.favoriteColors?.contains(color) ?? false;
            return CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              color: selected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
              onPressed: () {
                final updatedColors = List<String>.from(profileProvider.user?.favoriteColors ?? []);
                if (selected) {
                  updatedColors.remove(color);
                } else {
                  updatedColors.add(color);
                }
                profileProvider.updateFavoriteColors(updatedColors);
                setState(() {}); // Ensure UI updates after color selection
              },
              child: Text(
                color,
                style: TextStyle(
                  color: selected ? CupertinoColors.white : CupertinoColors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(authProvider auth, ProfileProvider profileProvider) {
    return Column(
      children: [
        CupertinoButton.filled(
          onPressed: () async {
            await profileProvider.saveUserData();
            _showSuccessSnackbar('Preferences updated successfully');
          },
          child: const Text('Update Preferences'),
        ),
        const SizedBox(height: 12),
        CupertinoButton(
          onPressed: () => _showSignOutDialog(auth),
          color: CupertinoColors.systemGrey4,
          child: const Text('Sign Out', style: TextStyle(color: Colors.black),),
        ),
      ],
    );
  }


  void _showPhotoOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Profile Photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Implement camera functionality
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Implement gallery picker
            },
            child: const Text('Choose from Library'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showPicker(
      BuildContext context,
      List<String> items,
      String initialValue,
      Function(String) onSelected,
      ) {
    int selectedIndex = items.indexOf(initialValue);
    if (selectedIndex == -1) selectedIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 260,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                      itemExtent: 40,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      children: items.map((item) => Center(child: Text(item))).toList(),
                    );
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('Select'),
                onPressed: () {
                  onSelected(items[selectedIndex]);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSignOutDialog(authProvider auth) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              auth.signOut();
              Navigator.pop(context);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        width: overlay.size.width,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: const TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry?.remove());
  }
}
