import 'package:flutter/material.dart';
import '../data/item_repository.dart';
import '../utils/index.dart';

class CafeView extends StatelessWidget {
  final ItemRepository repository;
  final VoidCallback onDrawerToggle;

  const CafeView({
    super.key,
    required this.repository,
    required this.onDrawerToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.background,
      appBar: AppBar(
        backgroundColor: context.theme.surface,
        elevation: 0,
        title: Text(
          context.responsive.compactTitle('Cafe', 'Cafe - Stock Count'),
          style: context.theme.appBarTitle,
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: context.theme.textPrimary),
          onPressed: onDrawerToggle,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(
                  context.responsive.spacing(
                    portraitValue: 24,
                    landscapeValue: 16,
                  ),
                ),
                decoration: context.theme.cardDecoration,
                child: Column(
                  children: [
                    Icon(
                      Icons.local_cafe,
                      size: context.responsive.iconSize(64),
                      color: context.theme.cafeAccent,
                    ),
                    SizedBox(
                      height: context.responsive.verticalPadding(
                        portraitValue: 16,
                        landscapeValue: 12,
                      ),
                    ),
                    Text(
                      'Cafe Stock Count',
                      style: context.theme.largeTitle.copyWith(
                        fontSize: context.responsive.fontSize(24, 20),
                      ),
                    ),
                    SizedBox(
                      height: context.responsive.verticalPadding(
                        portraitValue: 12,
                        landscapeValue: 8,
                      ),
                    ),
                    Text(
                      'Cafe items here in future version.',
                      style: context.theme.subtitle.copyWith(
                        fontSize: context.responsive.fontSize(14, 12),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.responsive.verticalPadding(
                        portraitValue: 24,
                        landscapeValue: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: context.theme.lightBackgroundDecoration(
                        context.theme.cafeAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
