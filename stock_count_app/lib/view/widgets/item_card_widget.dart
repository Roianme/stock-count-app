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

  const ItemCardWidget({
    super.key,
    required this.item,
    required this.statusControlWidth,
    required this.onCheckChanged,
    required this.onPiecesChanged,
    required this.onStatusChanged,
    this.showItemNameInColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: context.isLandscape ? 4 : 8,
      ),
      child: Padding(
        padding: EdgeInsets.all(
          context.responsive.verticalPadding(
            portraitValue: 12,
            landscapeValue: 8,
          ),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.3,
              child: Checkbox(
                value: item.isChecked,
                onChanged: (_) => onCheckChanged(),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: item.category.color.withValues(alpha: 0.12),
              child: Icon(item.category.icon, color: item.category.color),
            ),
            const SizedBox(width: 12),
            if (showItemNameInColumn)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: context.responsive.fontSize(16, 14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              )
            else
              Expanded(
                child: Text(
                  item.name,
                  style: context.theme.itemName.copyWith(
                    fontSize: context.responsive.fontSize(16, 14),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(width: 8),
            _buildStatusOrPiecesWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOrPiecesWidget(BuildContext context) {
    if (item.status == ItemStatus.pieces) {
      return Container(
        width: statusControlWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: context.theme.statusControlDecoration,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey('pieces_${item.id}'),
                initialValue: item.pieces == 0 ? '' : item.pieces.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Pieces',
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value) ?? 0;
                  onPiecesChanged(parsed);
                  // If pieces is 0 or blank, set status to zero
                  if (parsed == 0) {
                    onStatusChanged(ItemStatus.zero);
                  }
                },
              ),
            ),
            PopupMenuButton<ItemStatus>(
              icon: const Icon(Icons.more_vert, size: 20),
              tooltip: 'Change status',
              onSelected: onStatusChanged,
              itemBuilder: (BuildContext context) =>
                  ItemStatus.values.map((status) {
                    return PopupMenuItem<ItemStatus>(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: statusControlWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: context.theme.statusControlDecoration,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  item.status.displayName,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            PopupMenuButton<ItemStatus>(
              icon: const Icon(Icons.more_vert, size: 20),
              tooltip: 'Change status',
              onSelected: onStatusChanged,
              itemBuilder: (BuildContext context) =>
                  ItemStatus.values.map((status) {
                    return PopupMenuItem<ItemStatus>(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    }
  }
}
