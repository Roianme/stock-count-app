import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/item_model.dart';
import '../../utils/index.dart';
import '../category_view.dart';

/// Reusable item card widget used in both home_view and category_view
class ItemCardWidget extends StatelessWidget {
  final Item item;
  final double statusControlWidth;
  final VoidCallback onCheckChanged;
  final Function(int) onPiecesChanged;
  final Function(ItemStatus) onStatusChanged;
  final bool showItemNameInColumn;
  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final bool hideIcon;
  final bool isListView;

  const ItemCardWidget({
    super.key,
    required this.item,
    required this.statusControlWidth,
    required this.onCheckChanged,
    required this.onPiecesChanged,
    required this.onStatusChanged,
    this.showItemNameInColumn = false,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
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
      onLongPress: onLongPress,
      onTap: isMultiSelectMode ? onTap : null,
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: context.isLandscape ? 6 : 12,
        ),
        elevation: isSelected ? 8 : 2,
        color: isSelected ? context.theme.accent.withValues(alpha: 0.15) : null,
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
                      _buildStatusOrPiecesWidget(context),
                    ],
                  ),
                  if (showItemNameInColumn && !isCompact)
                    const SizedBox(height: 6),
                  if (showIcon)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () {
                          if (isMultiSelectMode) {
                            onTap?.call();
                          } else {
                            onCheckChanged();
                          }
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: item.category.color.withValues(
                                alpha: 0.12,
                              ),
                            ),
                            if (isMultiSelectMode && isSelected)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: context.theme.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
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

  Widget _buildStatusOrPiecesWidget(BuildContext context) {
    if (item.status == ItemStatus.pieces) {
      return Container(
        width: statusControlWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: context.theme.statusControlDecoration,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey('pieces_${item.id}_${item.pieces}'),
                initialValue: item.pieces == 0 ? '' : item.pieces.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                enabled: !isMultiSelectMode,
                style: TextStyle(
                  fontSize: context.responsive.fontSize(20, 18),
                  fontWeight: FontWeight.w600,
                  color: isMultiSelectMode
                      ? Colors.grey
                      : context.theme.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                  hintText: 'Pieces',
                  hintStyle: TextStyle(
                    fontSize: context.responsive.fontSize(18, 16),
                  ),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    // Blank input - don't auto-check
                    onPiecesChanged(0);
                    onStatusChanged(ItemStatus.zero);
                  } else {
                    final parsed = int.tryParse(value) ?? 0;
                    onPiecesChanged(parsed);
                    if (parsed == 0) {
                      onStatusChanged(ItemStatus.zero);
                    }
                    // Auto-check item when a value is explicitly entered (including 0)
                    if (!item.isChecked) {
                      onCheckChanged();
                    }
                  }
                },
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
