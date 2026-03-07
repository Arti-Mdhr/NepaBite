import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/app/routes/app_routes.dart';
import 'package:nepabite/core/api/api_endpoints.dart';
import 'package:nepabite/core/services/media/media_service.dart';
import 'package:nepabite/features/auth/presentation/pages/login_screen.dart';
import 'package:nepabite/features/auth/presentation/state/auth_state.dart';
import 'package:nepabite/features/auth/presentation/viewmodel/auth_view_model.dart';
import 'package:nepabite/screens/grocery/saved_grocery_lists.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final MediaService _mediaService = MediaService();
  bool _isEditMode = false;
  static const _green = Color(0xFF1EB980);
  static const _greenLight = Color(0xFFE8F8F2);
  static const _greenDark = Color(0xFF0F7A52);

  @override
  void initState() {
    super.initState();
  }

  void _toggleEditMode() {
    setState(() => _isEditMode = !_isEditMode);
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Change Profile Photo",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _pickerTile(
                icon: Icons.camera_alt_rounded,
                label: "Take a Photo",
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _mediaService.pickFromCamera();
                  if (file != null) {
                    await ref
                        .read(authViewModelProvider.notifier)
                        .uploadProfileImage(file);
                  }
                },
              ),
              const SizedBox(height: 10),
              _pickerTile(
                icon: Icons.photo_library_rounded,
                label: "Choose from Gallery",
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _mediaService.pickFromGallery();
                  if (file != null) {
                    await ref
                        .read(authViewModelProvider.notifier)
                        .uploadProfileImage(file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _greenLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _green, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final imagePath = state.authEntity?.image;
    final hasImage = imagePath != null && imagePath.isNotEmpty;
    final fullName = state.authEntity?.fullName ?? "User";
    final email = state.authEntity?.email ?? "";


    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: CustomScrollView(
          slivers: [

            /// ── SLIVER APP BAR ──
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const SizedBox.shrink(),
              centerTitle: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton.icon(
                    onPressed: _toggleEditMode,
                    icon: Icon(
                      _isEditMode ? Icons.check_rounded : Icons.edit_rounded,
                      size: 18,
                      color: _isEditMode ? _green : Colors.black87,
                    ),
                    label: Text(
                      _isEditMode ? "Done" : "Edit",
                      style: TextStyle(
                        color: _isEditMode ? _green : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildHeader(
                    hasImage, imagePath, fullName, email, state),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  color: Colors.grey.shade100,
                ),
              ),
              title: const Text(
                "My Profile",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),

            /// ── BODY ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// INFO CARDS
                    _sectionLabel("Account Info"),
                    const SizedBox(height: 10),
                    _infoCard(children: [
                      _infoRow(
                        icon: Icons.person_outline_rounded,
                        label: "Full Name",
                        value: fullName,
                      ),
                      _divider(),
                      _infoRow(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: email,
                      ),
                       
                    ]),

                    const SizedBox(height: 28),

                    /// MENU
                    _sectionLabel("Menu"),
                    const SizedBox(height: 10),
                    _infoCard(children: [
                      _menuRow(
                        icon: Icons.list_alt_rounded,
                        iconColor: _green,
                        label: "Saved Grocery Lists",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavedGroceryListsScreen(),
                            ),
                          );
                        },
                      ),
                    ]),

                    const SizedBox(height: 12),

                    /// LOGOUT
                    _infoCard(children: [
                      _menuRow(
                        icon: Icons.logout_rounded,
                        iconColor: Colors.redAccent,
                        label: "Logout",
                        labelColor: Colors.redAccent,
                        showArrow: false,
                        onTap: () {
                          _showLogoutDialog();
                        },
                      ),
                    ]),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  /// ── HEADER ──
  Widget _buildHeader(bool hasImage, String? imagePath, String fullName,
      String email, dynamic state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          /// Avatar with edit overlay
          Stack(
            alignment: Alignment.center,
            children: [
              // Decorative ring
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_green, _greenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),

              // Avatar
              CircleAvatar(
                radius: 54,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: hasImage
                    ? NetworkImage(ApiEndpoints.fileUrl(imagePath!))
                    : null,
                child: !hasImage
                    ? const Icon(Icons.person_rounded,
                        size: 50, color: Colors.grey)
                    : null,
              ),

              // Edit overlay (only in edit mode)
              if (_isEditMode)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: state.status == AuthStatus.loading
                        ? null
                        : _showPickerSheet,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: _green.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: state.status == AuthStatus.loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            email,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _green, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    Color? labelColor,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? Colors.black87,
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 52,
      endIndent: 0,
      color: Colors.grey.shade100,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authViewModelProvider.notifier).logout();
              AppRoutes.pushReplacement(context, const LoginScreen());
            },
            child: const Text("Logout",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}