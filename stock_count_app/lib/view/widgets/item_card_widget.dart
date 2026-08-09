import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/category_model.dart';

import '../../model/item_model.dart';
import '../../data/item_data.dart' as data;
import '../../utils/index.dart';

/// Reusable item card widget used in both home_view and category_view
class ItemCardWidget extends StatefulWidget {
  final Item item;
  final double statusControlWidth;
  final VoidCallback onCheckChanged;
  final Function(int?) onQuantityChanged;
  final Function(ItemStatus) onStatusChanged;
  final Function(ItemUnitOptionRecord) onUnitChanged;
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
  State<ItemCardWidget> createState() => _ItemCardWidgetState();
}

class _ItemCardWidgetState extends State<ItemCardWidget> {
  late final TextEditingController _quantityController;
  late final FocusNode _quantityFocusNode;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.quantity == null ? '' : widget.item.quantity.toString(),
    );

    _quantityFocusNode = FocusNode();

    // Fires when the user taps away or moves focus elsewhere — i.e. they are
    // done entering the value. This is more intentional than debounce because
    // it does not depend on timing at all.
    _quantityFocusNode.addListener(() {
      if (!_quantityFocusNode.hasFocus) {
        final text = _quantityController.text;
        final parsed = text.isEmpty ? null : int.tryParse(text);
        widget.onQuantityChanged(parsed);
      }
    });
  }

  /// Syncs the controller if quantity is updated externally (e.g. ViewModel sync).
  @override
  void didUpdateWidget(ItemCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity) {
      final newText = widget.item.quantity == null
          ? ''
          : widget.item.quantity.toString(); // 0 → "0", 5 → "5"
      // Guard against unnecessary updates that would reset the cursor position
      if (_quantityController.text != newText) {
        _quantityController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _quantityFocusNode.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompact = context.screenWidth < 420;
    final bool showIcon =
        !widget.hideIcon && (context.isWideScreen || context.isLandscape);
    final bool useColumnLayout = widget.showItemNameInColumn || isCompact;
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
                            color: (widget.isListView && widget.item.isChecked)
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: (widget.isListView && (isCompact || !showIcon))
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.item.name,
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
                                      (data.categories
                                              .cast<CategoryRecord?>()
                                              .firstWhere(
                                                (c) =>
                                                    c?.id ==
                                                    widget.item.categoryId,
                                                orElse: () => null,
                                              )
                                              ?.name) ??
                                          widget.item.category.displayName,
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
                                        widget.item.name,
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
                                        widget.item.name,
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
                  if (widget.showItemNameInColumn && !isCompact)
                    const SizedBox(height: 6),
                  if (showIcon)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: widget.onCheckChanged,
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Color(
                            data.categories
                                    .cast<CategoryRecord?>()
                                    .firstWhere(
                                      (c) => c?.id == widget.item.categoryId,
                                      orElse: () => null,
                                    )
                                    ?.colorValue ??
                                widget.item.category.color.toARGB32(),
                          ).withValues(alpha: 0.12),
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
    final enabled = widget.item.enabledStatuses;
    final unitOptions = data.unitOptionsForItem(widget.item);
    final selectedOption = data.selectedUnitOption(widget.item);

    // Determine the active status type. Default to item.status if it's
    // still in the enabled set, otherwise pick the first enabled status.
    final activeStatus = enabled.contains(widget.item.status)
        ? widget.item.status
        : enabled.first;
    // Build the primary control for the active status
    Widget buildControl() {
      switch (activeStatus) {
        case ItemStatus.urgent:
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'URGENT',
                style: TextStyle(
                  fontSize: context.responsive.fontSize(18, 16),
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
          );

        case ItemStatus.quantity:
          return TextField(
            controller: _quantityController,
            focusNode: _quantityFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.responsive.fontSize(18, 16),
              fontWeight: FontWeight.w600,
              color: context.theme.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              hintText: 'Qty',
              hintStyle: TextStyle(
                fontSize: context.responsive.fontSize(16, 14),
              ),
            ),
            onSubmitted: (value) {
              final parsed = value.isEmpty ? null : int.tryParse(value);
              widget.onQuantityChanged(parsed);
            },
          );

        case ItemStatus.dropdown:
          if (unitOptions.isEmpty) {
            return Center(
              child: Text(
                'No options',
                style: TextStyle(
                  fontSize: context.responsive.fontSize(12, 11),
                  color: Colors.grey.shade500,
                ),
              ),
            );
          }
          final displayLabel = selectedOption?.label ?? 'Select';
          return PopupMenuButton<ItemUnitOptionRecord>(
            tooltip: 'Change unit',
            padding: EdgeInsets.zero,
            onSelected: (newUnit) {
              widget.onUnitChanged(newUnit);
            },
            itemBuilder: (BuildContext context) => unitOptions.map((option) {
              return PopupMenuItem<ItemUnitOptionRecord>(
                value: option,
                child: Text(option.label, style: const TextStyle(fontSize: 16)),
              );
            }).toList(),
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
          );
      }
    }

    // Build the status switch menu.
    // Status types (Quantity / Urgent) appear first, followed by a divider
    // and then individual dropdown options — so users can select a dropdown
    // value in one tap instead of two (⋮ → Dropdown → option).
    final List<PopupMenuEntry<dynamic>> menuEntries = [];

    // Status-type entries: skip Dropdown itself; its options go below.
    for (final s in ItemStatus.values) {
      if (s != ItemStatus.dropdown && s != activeStatus && enabled.contains(s)) {
        menuEntries.add(
          PopupMenuItem<dynamic>(
            value: s,
            child: Text(s.displayName, style: const TextStyle(fontSize: 16)),
          ),
        );
      }
    }

    // Dropdown unit-option entries: one per unselected option.
    if (enabled.contains(ItemStatus.dropdown) && unitOptions.isNotEmpty) {
      final unselectedOptions = activeStatus == ItemStatus.dropdown
          ? unitOptions.where(
              (o) => o.label != selectedOption?.label,
            ).toList()
          : unitOptions.toList();
      if (unselectedOptions.isNotEmpty) {
        if (menuEntries.isNotEmpty) {
          menuEntries.add(const PopupMenuDivider());
        }
        for (final option in unselectedOptions) {
          menuEntries.add(
            PopupMenuItem<dynamic>(
              value: option,
              child: Text(option.label, style: const TextStyle(fontSize: 16)),
            ),
          );
        }
      }
    }

    return Container(
      width: widget.statusControlWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: context.theme.statusControlDecoration,
      child: Row(
        children: [
          Expanded(child: buildControl()),
          if (menuEntries.isNotEmpty)
            PopupMenuButton<dynamic>(
              icon: const Icon(Icons.more_vert, size: 22),
              tooltip: 'Change status',
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value is ItemStatus) {
                  widget.onStatusChanged(value);
                } else if (value is ItemUnitOptionRecord) {
                  widget.onStatusChanged(ItemStatus.dropdown);
                  widget.onUnitChanged(value);
                }
              },
              itemBuilder: (BuildContext context) => menuEntries,
            ),
        ],
      ),
    );
  }
}
