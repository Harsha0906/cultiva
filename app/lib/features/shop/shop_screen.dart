import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/app_prefs.dart';
import '../../core/sfx.dart';

import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/prop_sprite.dart';
import '../../data/providers.dart';
import '../../data/shop_service.dart';
import '../../domain/shop.dart';
import '../barn/spot_picker.dart';
import 'shop_view.dart';

/// Shop tab: cosmetic decorations bought with coins earned from tasks.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(shopViewProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Store'),
        actions: [
          if (view != null)
            Padding(
              padding: const EdgeInsets.only(right: Space.lg),
              child: Center(
                child: Semantics(
                  label: '${view.balance} coins',
                  excludeSemantics: true,
                  child: _CoinCount(view.balance),
                ),
              ),
            ),
        ],
      ),
      body: view == null
          ? const SizedBox.shrink()
          : GridView.builder(
              padding: const EdgeInsets.all(Space.lg),
              // Large text: one wide card per row so names and buttons fit.
              gridDelegate: MediaQuery.textScalerOf(context).scale(10) >= 15
                  ? const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: Space.md,
                      childAspectRatio: 1.15,
                    )
                  : const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: Space.md,
                      crossAxisSpacing: Space.md,
                      childAspectRatio: 0.72,
                    ),
              itemCount: kShopCatalogue.length,
              itemBuilder: (context, i) =>
                  _ItemCard(item: kShopCatalogue[i], view: view),
            ),
    );
  }
}

class _CoinCount extends StatelessWidget {
  const _CoinCount(this.coins);
  final int coins;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/sprites/cultiva/fx/coin.png',
        width: 20,
        height: 20,
        fit: BoxFit.cover,
        alignment: Alignment.centerLeft,
        filterQuality: FilterQuality.none,
      ),
      const SizedBox(width: Space.xs),
      Text(
        '$coins',
        style: const TextStyle(
          fontFamily: kPixelFont,
          fontSize: 18,
          color: Colors.white,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    ],
  );
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item, required this.view});
  final ShopItem item;
  final ShopView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final owned = view.ownedItem(item.id) != null;
    final short = item.price - view.balance;
    return Container(
      decoration: BoxDecoration(
        color: CultivaColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: owned ? CultivaColors.teal : CultivaColors.line,
          width: owned ? 3 : 2,
        ),
      ),
      padding: const EdgeInsets.all(Space.sm),
      child: Column(
        children: [
          Expanded(child: Center(child: PropSprite(item.asset, scale: 2))),
          Text(
            item.name,
            style: t.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: Space.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/sprites/cultiva/fx/coin.png',
                width: 16,
                height: 16,
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.price}',
                style: const TextStyle(fontFamily: kPixelFont, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          if (owned)
            const PixelButton(
              label: 'Owned',
              variant: PixelButtonVariant.paper,
              onPressed: null,
            )
          else if (short > 0)
            Text(
              'Need $short more',
              style: t.bodySmall?.copyWith(fontFamily: kBodyFont),
            )
          else
            PixelButton(
              label: 'Buy',
              variant: PixelButtonVariant.teal,
              onPressed: () => _buy(context, ref),
            ),
        ],
      ),
    );
  }

  Future<void> _buy(BuildContext context, WidgetRef ref) async {
    final bought = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: CultivaColors.paperDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        side: BorderSide(color: CultivaColors.woodDark, width: 3),
      ),
      builder: (_) => _BuySheet(item: item),
    );
    if (bought != true || !context.mounted) return;
    Sfx.play(SfxName.buy);
    await AppFeedback.light();
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CultivaColors.ink,
        content: Text(
          '${item.name} is in your barn.',
          style: const TextStyle(fontFamily: kBodyFont, color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'Place it now',
          textColor: CultivaColors.gold,
          onPressed: () => showSpotPicker(context, item),
        ),
      ),
    );
  }
}

class _BuySheet extends ConsumerStatefulWidget {
  const _BuySheet({required this.item});
  final ShopItem item;

  @override
  ConsumerState<_BuySheet> createState() => _BuySheetState();
}

class _BuySheetState extends ConsumerState<_BuySheet> {
  bool _busy = false;
  String? _error;

  Future<void> _confirm() async {
    if (_busy) return; // guard before any await: no double spending
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(shopServiceProvider).buy(widget.item.id);
      if (mounted) Navigator.of(context).pop(true);
    } on ShopException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: PropSprite(widget.item.asset, scale: 3)),
            const SizedBox(height: Space.md),
            Text(
              'Buy ${widget.item.name} for ${widget.item.price} coins?',
              style: t.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (_error != null) ...[
              const SizedBox(height: Space.sm),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: kBodyFont,
                  color: Color(0xFF8A3A20),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: Space.lg),
            PixelButton(
              label: 'Buy',
              expand: true,
              loading: _busy,
              onPressed: _confirm,
            ),
            const SizedBox(height: Space.sm),
            PixelButton(
              label: 'Cancel',
              variant: PixelButtonVariant.paper,
              expand: true,
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
