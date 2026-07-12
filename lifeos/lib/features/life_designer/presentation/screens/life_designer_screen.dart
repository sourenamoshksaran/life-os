import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';

/// Contains: Workout Builder, Routine Builder, Learning Builder, Task
/// Templates, Theme Settings, Goals, Milestones (docs/05_UI_UX_
/// Specification.md "Life Designer"). "Plugins" is explicitly out of v1
/// scope per that document's amendment (naming collision with the
/// internal Module Lifecycle Interface — see docs/03_System_
/// Architecture.md §17).
///
/// Scope note: this screen wires to the builders that already exist
/// (Workout, Learning) and to Settings (Theme Settings, Daily Goals).
/// Goals/Milestones/Projects (RFC-004) and a dedicated Task Templates
/// builder are not yet implemented as modules — flagged here rather than
/// linked to something that doesn't exist.
class LifeDesignerScreen extends StatelessWidget {
  const LifeDesignerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Life Designer')),
      body: ListView(
        padding: const EdgeInsets.all(LifeOSSpacing.md),
        children: [
          _DesignerTile(
            icon: PhosphorIconsRegular.barbell,
            title: 'Workout Builder',
            onTap: () => context.go('/tasks/workout'),
          ),
          _DesignerTile(
            icon: PhosphorIconsRegular.graduationCap,
            title: 'Learning Builder',
            onTap: () => context.go('/tasks/learning'),
          ),
          _DesignerTile(
            icon: PhosphorIconsRegular.paintBrush,
            title: 'Theme Settings',
            onTap: () => context.go('/life-designer/settings'),
          ),
          _DesignerTile(
            icon: PhosphorIconsRegular.target,
            title: 'Daily Goals',
            onTap: () => context.go('/life-designer/settings'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: LifeOSSpacing.md),
            child: Text(
              'Goals/Milestones/Projects and a dedicated Task Templates '
              'builder are specified (RFC-004) but not yet implemented as '
              'screens — see IMPLEMENTATION_REPORT.md.',
              style: TextStyle(color: LifeOSColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignerTile extends StatelessWidget {
  const _DesignerTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: LifeOSSpacing.sm),
      decoration: BoxDecoration(color: LifeOSColors.card, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: LifeOSColors.primary),
        title: Text(title, style: const TextStyle(color: LifeOSColors.textPrimary)),
        trailing: const Icon(PhosphorIconsRegular.caretLeft, color: LifeOSColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
