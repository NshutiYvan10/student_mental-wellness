import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../providers/app_providers.dart';
import '../../services/hive_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _schoolCtrl;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final box = Hive.box(HiveService.settingsBox);
    _nameCtrl = TextEditingController(text: (box.get(HiveService.keyProfileName) as String?) ?? 'Anonymous Student');
    _schoolCtrl = TextEditingController(text: (box.get(HiveService.keyProfileSchool) as String?) ?? '');
    _avatarPath = box.get(HiveService.keyProfileAvatarPath) as String?;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final box = Hive.box(HiveService.settingsBox);
    await box.put(HiveService.keyProfileName, _nameCtrl.text.trim());
    await box.put(HiveService.keyProfileSchool, _schoolCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: _avatarPath != null ? AssetImage(_avatarPath!) as ImageProvider : null,
            child: _avatarPath == null ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _schoolCtrl,
            decoration: const InputDecoration(labelText: 'School/Institution'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(themeMode.name),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (v) => ref.read(themeModeProvider.notifier).state = v!,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


