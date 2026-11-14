import 'package:material_ui/material_ui.dart';

/// Profile (opened from the header avatar). Placeholder until Phase 9.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile & animal avatars arrive in Phase 9'),
      ),
    );
  }
}
