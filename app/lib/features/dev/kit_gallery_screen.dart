import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/pixel_icon.dart';
import '../../core/ui/pixel_panel.dart';

/// Debug-only gallery of every UI-kit part and state (route /dev/kit).
class KitGalleryScreen extends StatefulWidget {
  const KitGalleryScreen({super.key});

  @override
  State<KitGalleryScreen> createState() => _KitGalleryScreenState();
}

class _KitGalleryScreenState extends State<KitGalleryScreen> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('UI kit')),
      body: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: [
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning, farmer', style: t.titleLarge),
                const SizedBox(height: Space.xs),
                Text(
                  'Read for 30 minutes before breakfast so the tomatoes ripen by lunch.',
                  style: t.bodyMedium,
                ),
                const SizedBox(height: Space.xs),
                Text('Taps: $_taps', style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.md,
            children: [
              PixelButton(
                label: 'Plant it',
                icon: PixelIcons.plus,
                onPressed: () => setState(() => _taps++),
              ),
              PixelButton(
                label: 'Start',
                icon: PixelIcons.play,
                variant: PixelButtonVariant.teal,
                onPressed: () => setState(() => _taps++),
              ),
              PixelButton(
                label: 'Edit',
                variant: PixelButtonVariant.wood,
                onPressed: () => setState(() => _taps++),
              ),
              PixelButton(
                label: 'Cancel',
                variant: PixelButtonVariant.paper,
                onPressed: () => setState(() => _taps++),
              ),
              const PixelButton(label: 'Disabled', onPressed: null),
              PixelButton(label: 'Saving', loading: true, onPressed: () {}),
            ],
          ),
          const SizedBox(height: Space.md),
          PixelButton(
            label:
                'A very long button label that has to wrap onto a second line',
            variant: PixelButtonVariant.teal,
            expand: true,
            onPressed: () {},
          ),
          const SizedBox(height: Space.lg),
          PixelPanel(
            style: PanelStyle.wood,
            child: Wrap(
              spacing: Space.md,
              runSpacing: Space.md,
              children: [
                for (final i in PixelIcons.values)
                  PixelIconButton(
                    semanticLabel: i.name,
                    icon: i,
                    variant: PixelButtonVariant.paper,
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
