import 'package:flutter/material.dart';
import '../core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeMenuCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const HomeMenuCard({super.key, required this.item, required this.onTap});

  @override
  State<HomeMenuCard> createState() => _HomeMenuCardState();
}

class _HomeMenuCardState extends State<HomeMenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseColor = colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            //  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            border: Border.all(
              color: _isHovered ? baseColor.withValues(alpha: 0.5) : colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Arka plan ikonu (Watermark)
              Positioned(
                bottom: 85,
                right: 5,
                child: Icon(widget.item.icon, size: 100, color: colorScheme.primary.withValues(alpha: 0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // İkon Çerçevesi
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(widget.item.icon, color: colorScheme.onPrimaryContainer),
                        ),
                        //const Spacer(),
                        Text(
                          widget.item.label ?? '',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                        ),
                      ],
                    ),
                    Spacer(),
                    //Text('Firma ekleme, çıkarma, düzenleme'),
                    SizedBox(height: 30),
                    Row(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(widget.item.description ?? '')),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 40,
                            width: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Git',
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color: context.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(PhosphorIcons.caretRight(), size: 17, color: context.colorScheme.onPrimary),
                              ],
                            ),
                          ),
                        ),
                      ],
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
