import 'package:flutter/material.dart';
import '../model/item_model.dart';
// import '../viewmodel/home_viewmodel.dart';

class StatusDropdown extends StatelessWidget {
  final Item item;
  final ValueChanged<ItemStatus>? onChanged;

  const StatusDropdown({super.key, required this.item, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ItemStatus>(
      value: item.status,
      icon: Icon(Icons.arrow_drop_down),
      isExpanded: true,
      items: ItemStatus.values.map((ItemStatus status) {
        return DropdownMenuItem<ItemStatus>(
          value: status,
          child: Text(status.toString().split('.').last),
        );
      }).toList(),
      onChanged: (ItemStatus? newValue) {
        if (newValue != null && onChanged != null) {
          onChanged!(newValue);
        }
      },
    );
  }
}
