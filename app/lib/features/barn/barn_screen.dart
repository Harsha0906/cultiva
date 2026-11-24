import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/live_query.dart';
import '../../core/router.dart';
import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/crop_sprite.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/pixel_icon.dart';
import '../../core/ui/prop_sprite.dart';
import '../../data/providers.dart';
import '../../domain/task.dart';
import '../shop/shop_view.dart';
import 'spot_picker.dart';

/// Today's harvested tasks (including finished to-dos that left the plot).
final todaysHarvestProvider = StreamProvider<List<(FarmTask, int)>>((ref) {
  final farm = ref.watch(farmServiceProvider);
  final db = ref.watch(dbProvider);
  Future<List<(FarmTask, int)>> load() async {
    final day = await farm.today();
    final out = <(FarmTask, int)>[];
    for (final c in await farm.progress.forDay(day)) {
      if (c.harvestedAt == null) continue;
      final task = await farm.tasks.byId(c.taskId);
      if (task != null) out.add((task, c.coins));
    }
    return out;
  }

  return liveQuery(
    db.tableUpdates(TableUpdateQuery.onAllTables([db.completions, db.tasks])),
    load,
  );
});

/// The barn: today's harvest + owned decorations (place them on the farm).
class BarnScreen extends ConsumerWidget {
  const BarnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final harvested = ref.watch(todaysHarvestProvider).value ?? const [];
    final shop = ref.watch(shopViewProvider).value;
    final t = Theme.of(context).textTheme;
    final coinsToday = harvested.fold<int>(0, (s, h) => s + h.$2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const PixelIcon(PixelIcons.back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.farm),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: [
          Semantics(
            header: true,
            child: Text("Today's harvest", style: t.titleMedium),
          ),
          const SizedBox(height: Space.xs),
          if (harvested.isEmpty)
            Text('Nothing harvested yet today.', style: t.bodySmall)
          else ...[
            Text(
              '${harvested.length} crop${harvested.length == 1 ? '' : 's'} · $coinsToday coins',
              style: t.bodySmall,
            ),
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final p in harvested)
                  Container(
                    width: 100,
                    padding: const EdgeInsets.all(Space.sm),
                    decoration: BoxDecoration(
                      color: CultivaColors.paper,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CultivaColors.line, width: 2),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 64,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: CropSprite(p.$1.crop, frame: 3),
                          ),
                        ),
                        Text(
                          p.$1.title,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodyMedium,
                        ),
                        Text(
                          '+${p.$2}',
                          style: const TextStyle(
                            fontFamily: kPixelFont,
                            color: CultivaColors.tealDark,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: Space.xl),
          Semantics(
            header: true,
            child: Text('Decorations', style: t.titleMedium),
          ),
          const SizedBox(height: Space.sm),
          if (shop == null)
            const SizedBox.shrink()
          else if (shop.owned.isEmpty) ...[
            Text('Visit the shop to decorate your farm.', style: t.bodyMedium),
            const SizedBox(height: Space.md),
            PixelButton(
              label: 'Go to the shop',
              variant: PixelButtonVariant.teal,
              onPressed: () => context.go(Routes.shop),
            ),
          ] else
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final o in shop.owned.where((o) => !o.item.animal))
                  Semantics(
                    button: true,
                    label:
                        '${o.item.name}, ${o.spot == null ? 'in storage' : 'on the farm, spot ${o.spot! + 1}'}',
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => showSpotPicker(context, o.item),
                      child: Container(
                        width: 110,
                        padding: const EdgeInsets.all(Space.sm),
                        decoration: BoxDecoration(
                          color: CultivaColors.paper,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: o.spot != null
                                ? CultivaColors.teal
                                : CultivaColors.line,
                            width: o.spot != null ? 3 : 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 90,
                              child: Center(child: PropSprite(o.item.asset)),
                            ),
                            Text(
                              o.item.name,
                              textAlign: TextAlign.center,
                              style: t.bodyMedium,
                            ),
                            Text(
                              o.spot == null
                                  ? 'In storage'
                                  : 'On the farm · spot ${o.spot! + 1}',
                              textAlign: TextAlign.center,
                              style: t.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
