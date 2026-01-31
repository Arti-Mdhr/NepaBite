import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/api/api_endpoints.dart';
import 'package:nepabite/core/services/media/media_service.dart';
import 'package:nepabite/features/auth/presentation/state/auth_state.dart';
import 'package:nepabite/features/auth/presentation/viewmodel/auth_view_model.dart';



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
                  await ref.read(authViewModelProvider.notifier).uploadProfileImage(file);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Camera permission denied or cancelled")),
                  );
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
                  await ref.read(authViewModelProvider.notifier).uploadProfileImage(file);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gallery permission denied or cancelled")),
                  );
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

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final imagePath = state.authEntity?.image;
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: hasImage ? NetworkImage(ApiEndpoints.fileUrl(imagePath)) : null,
              child: !hasImage ? const Icon(Icons.person, size: 55, color: Colors.grey) : null,
            ),

            const SizedBox(height: 15),

            Text(
              state.authEntity?.fullName ?? "User",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              state.authEntity?.email ?? "",
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: state.status == AuthStatus.loading ? null : _showPickerSheet,
                child: state.status == AuthStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Change Photo"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
