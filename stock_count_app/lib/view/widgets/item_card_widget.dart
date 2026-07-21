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
                                      (data.categories.cast<CategoryRecord?>().firstWhere((c) => c?.id == widget.item.categoryId, orElse: () => null)?.name) ?? widget.item.category.displayName,
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
                          backgroundColor: Color(data.categories.cast<CategoryRecord?>().firstWhere((c) => c?.id == widget.item.categoryId, orElse: () => null)?.colorValue ?? widget.item.category.color.toARGB32())
                              .withValues(alpha: 0.12),
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

    // Build a list of status control widgets
    final List<Widget> controls = [];

    // Urgent badge
    if (enabled.contains(ItemStatus.urgent)) {
      controls.add(
        Center(
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
        ),
      );
    }

    // Quantity input
    if (enabled.contains(ItemStatus.quantity)) {
      controls.add(
        SizedBox(
          height: 36,
          child: TextField(
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
          ),
        ),
      );
    }

    // Dropdown of predefined options
    if (enabled.contains(ItemStatus.dropdown) && unitOptions.isNotEmpty) {
      final displayLabel = selectedOption?.label ?? 'Select';
      controls.add(
        PopupMenuButton<ItemUnitOptionRecord>(
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    displayLabel,
                    style: TextStyle(
                      fontSize: context.responsive.fontSize(14, 13),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
        ),
      );
    }

    // If no controls enabled, show nothing
    if (controls.isEmpty) {
      return const SizedBox.shrink();
    }

    // Wrap in status control container
    return Container(
      width: widget.statusControlWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: context.theme.statusControlDecoration,
      child: controls.length == 1
          ? controls.first
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: controls,
            ),
    );
  }
}
