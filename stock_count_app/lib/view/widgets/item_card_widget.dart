import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/item_model.dart';
import '../../data/item_data.dart' as data;
import '../../utils/index.dart';
import '../category_view.dart';

/// Reusable item card widget used in both home_view and category_view
class ItemCardWidget extends StatelessWidget {
  final Item item;
  final double statusControlWidth;
  final VoidCallback onCheckChanged;
  final Function(int) onQuantityChanged;
  final Function(ItemStatus) onStatusChanged;
  final Function(data.ItemUnitOption) onUnitChanged;
  final bool showItemNameInColumn;
  final bool hideIcon;
  final bool isListView;

  const ItemCardWidget({
    super.key,
    required this.item,
    required this.statusControlWidth,
    required this.onCheckChanged,
    required this.onQuantityChanged,
    required this.onStatusChanged,
    required this.onUnitChanged,
    this.showItemNameInColumn = false,
    this.hideIcon = false,
    this.isListView = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompact = context.screenWidth < 420;
    final bool showIcon =
        !hideIcon && (context.isWideScreen || context.isLandscape);
    final bool useColumnLayout = showItemNameInColumn || isCompact;
    final double avatarRadius = isCompact ? 22 : 32;
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: context.isLandscape ? 6 : 12,
        ),
        elevation: 2,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive.verticalPadding(
                  portraitValue: 16,
                  landscapeValue: 12,
                ),
                vertical: context.responsive.verticalPadding(
                  portraitValue: 16,
                  landscapeValue: 12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (isListView && item.isChecked)
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: (isListView && (isCompact || !showIcon))
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: context.responsive.fontSize(
                                          18,
                                          16,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.category.displayName,
                                      style: context.theme.subtitle.copyWith(
                                        fontSize: context.responsive.fontSize(
                                          13,
                                          12,
                                        ),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )
                              : (useColumnLayout
                                    ? Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: context.responsive.fontSize(
                                            18,
                                            16,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        item.name,
                                        style: context.theme.itemName.copyWith(
                                          fontSize: context.responsive.fontSize(
                                            18,
                                            16,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusOrQuantityWidget(context),
                    ],
                  ),
                  if (showItemNameInColumn && !isCompact)
                    const SizedBox(height: 6),
                  if (showIcon)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: onCheckChanged,
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: item.category.color.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOrQuantityWidget(BuildContext context) {
    final unitOptions = data.unitOptionsForItem(item);
    if (unitOptions.isNotEmpty) {
      final selectedOption = data.selectedUnitOption(item);
      final displayLabel = selectedOption?.label ?? 'Select';

      return Container(
        width: statusControlWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: context.theme.statusControlDecoration,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  displayLabel,
                  style: TextStyle(
                    fontSize: context.responsive.fontSize(18, 16),
                    fontWeight: FontWeight.w600,
                    color: context.theme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            PopupMenuButton<data.ItemUnitOption>(
              icon: const Icon(Icons.more_vert, size: 20),
              tooltip: 'Change unit',
              padding: EdgeInsets.zero,
              onSelected: (newUnit) {
                onUnitChanged(newUnit);
                // Auto-check item when unit is updated
                if (!item.isChecked) {
                  onCheckChanged();
                }
              },
              itemBuilder: (BuildContext context) => unitOptions.map((option) {
                return PopupMenuItem<data.ItemUnitOption>(
                  value: option,
                  child: Text(
                    option.label,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    if (item.status == ItemStatus.quantity ||
        item.status == ItemStatus.urgent) {
      return Container(
        width: statusControlWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: context.theme.statusControlDecoration,
        child: Row(
          children: [
            Expanded(
              child: item.status == ItemStatus.urgent
                  ? Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: context.responsive.fontSize(18, 16),
                            fontWeight: FontWeight.w700,
                            color: context.theme.textPrimary,
                          ),
                        ),
                      ),
                    )
                  : TextFormField(
                      key: ValueKey(
                        'quantity_${item.id}_${item.quantity}_${item.status.name}',
                      ),
                      initialValue: item.quantity == 0
                          ? ''
                          : item.quantity.toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.responsive.fontSize(18, 16),
                        fontWeight: FontWeight.w600,
                        color: context.theme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        hintText: 'Quantity',
                        hintStyle: TextStyle(
                          fontSize: context.responsive.fontSize(16, 14),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          // Blank input - don't auto-check
                          onQuantityChanged(0);
                        } else {
                          final parsed = int.tryParse(value) ?? 0;
                          onQuantityChanged(parsed);
                          // Auto-check item when a value is explicitly entered (including 0)
                          if (!item.isChecked) {
                            onCheckChanged();
                          }
                        }
                      },
                    ),
            ),
            PopupMenuButton<ItemStatus>(
              icon: const Icon(Icons.more_vert, size: 22),
              tooltip: 'Change status',
              padding: EdgeInsets.zero,
              onSelected: (newStatus) {
                onStatusChanged(newStatus);
                if (newStatus == ItemStatus.urgent) {
                  if (!item.isChecked) {
                    onCheckChanged();
                  }
                  return;
                }

                final requiresQuantity = newStatus == ItemStatus.quantity;
                final hasQuantityInput = item.quantity > 0;
                // Auto-check only when status doesn't require quantity input
                // or when a quantity has been entered.
                if (!item.isChecked &&
                    (!requiresQuantity || hasQuantityInput)) {
                  onCheckChanged();
                }
              },
              itemBuilder: (BuildContext context) => const [
                PopupMenuItem<ItemStatus>(
                  value: ItemStatus.quantity,
                  child: Text('Quantity', style: TextStyle(fontSize: 16)),
                ),
                PopupMenuItem<ItemStatus>(
                  value: ItemStatus.urgent,
                  child: Text('Urgent', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: statusControlWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: context.theme.statusControlDecoration,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  item.status.displayName,
                  style: TextStyle(
                    fontSize: context.responsive.fontSize(20, 18),
                    fontWeight: FontWeight.w600,
                    color: context.theme.textPrimary,
                  ),
                ),
              ),
            ),
            PopupMenuButton<ItemStatus>(
              icon: const Icon(Icons.more_vert, size: 20),
              tooltip: 'Change status',
              padding: EdgeInsets.zero,
              onSelected: (newStatus) {
                onStatusChanged(newStatus);
                // Auto-check item when status is updated
                if (!item.isChecked) {
                  onCheckChanged();
                }
              },
              itemBuilder: (BuildContext context) =>
                  ItemStatus.values.map((status) {
                    return PopupMenuItem<ItemStatus>(
                      value: status,
                      child: Text(
                        status.displayName,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    }
  }
}
