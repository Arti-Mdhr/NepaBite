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

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
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
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
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
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    final imagePath = state.authEntity?.image;
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// Profile Header
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: hasImage
                  ? NetworkImage(ApiEndpoints.fileUrl(imagePath))
                  : null,
              child: !hasImage
                  ? const Icon(Icons.person, size: 55, color: Colors.grey)
                  : null,
            ),

            const SizedBox(height: 15),

            Text(
              state.authEntity?.fullName ?? "User",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              state.authEntity?.email ?? "",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            /// Change Photo Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: state.status == AuthStatus.loading
                    ? null
                    : _showPickerSheet,
                child: const Text("Change Photo"),
              ),
            ),

            const SizedBox(height: 30),

            /// Options
            Card(
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text("Saved Grocery Lists"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedGroceryListsScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      ref.read(authViewModelProvider.notifier).logout();
                      AppRoutes.pushReplacement(context, const LoginScreen());
                    },
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}