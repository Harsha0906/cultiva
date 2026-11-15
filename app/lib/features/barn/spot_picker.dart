import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/prop_sprite.dart';
import '../../data/providers.dart';
import '../../data/shop_service.dart';
import '../../domain/shop.dart';

/// Lets the player put [item] in one of the farm's decoration spots,
/// or take it back to storage. Returns true if anything changed.
Future<bool?> showSpotPicker(BuildContext context, ShopItem item) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: CultivaColors.paperDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      side: BorderSide(color: CultivaColors.woodDark, width: 3),
    ),
    builder: (_) => _SpotPicker(item: item),
  );
}

class _SpotPicker extends ConsumerStatefulWidget {
  const _SpotPicker({required this.item});
  final ShopItem item;

  @override
  ConsumerState<_SpotPicker> createState() => _SpotPickerState();
}

class _SpotPickerState extends ConsumerState<_SpotPicker> {
  Map<int, ShopItem> _placed = const {};
  bool _busy = false;

  ShopService get _shop => ref.read(shopServiceProvider);

  @override
  void initState() {
    super.initState();
    _shop.placed().then((p) {
      if (mounted) setState(() => _placed = p);
    });
  }

  int? get _currentSpot {
    for (final e in _placed.entries) {
      if (e.value.id == widget.item.id) return e.key;
    }
    return null;
  }

  Future<void> _do(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) Navigator.of(context).pop(true);
    } on ShopException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final here = _currentSpot;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PropSprite(widget.item.asset, scale: 2),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Text(
                    'Place ${widget.item.name}',
                    style: t.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.sm),
            Text(
              'Spots are by the pond, left to right. Placing on a taken spot '
              'sends that decoration back to storage.',
              style: t.bodySmall?.copyWith(fontFamily: kBodyFont),
            ),
            const SizedBox(height: Space.md),
            Row(
              children: [
                for (var s = 0; s < kDecoSpots; s++) ...[
                  if (s > 0) const SizedBox(width: Space.sm),
                  Expanded(
                    child: PixelButton(
                      label: _spotLabel(s),
                      variant: here == s
                          ? PixelButtonVariant.teal
                          : PixelButtonVariant.paper,
                      onPressed: _busy || here == s
                          ? null
                          : () => _do(() => _shop.place(widget.item.id, s)),
                    ),
                  ),
                ],
              ],
            ),
            if (here != null) ...[
              const SizedBox(height: Space.md),
              PixelButton(
                label: 'Take back to storage',
                variant: PixelButtonVariant.wood,
                expand: true,
                onPressed: _busy
                    ? null
                    : () => _do(() => _shop.takeBack(widget.item.id)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _spotLabel(int s) {
    final occupant = _placed[s];
    if (occupant == null) return 'Spot ${s + 1}\nempty';
    if (occupant.id == widget.item.id) return 'Spot ${s + 1}\nhere';
    return 'Spot ${s + 1}\n${occupant.name}';
  }
}
