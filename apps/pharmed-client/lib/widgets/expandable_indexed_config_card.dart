// [SWREQ-UI-SHARED-CARD-001]
// Index rozetli, başlık + özet + expand/collapse'lı, genişleyince body
// slotu gösteren genel kart kabuğu. Mobil wizard'daki çekmece config
// kartı ile kabin dizaynındaki serum avadanlık kartı AYNI kabuğu
// paylaşır — içerik (satır bazlı config / grid bazlı avadanlık) farklıdır.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class ExpandableIndexedConfigCard extends StatefulWidget {
  const ExpandableIndexedConfigCard({
    super.key,
    required this.index,
    required this.title,
    required this.summary,
    required this.body,
    this.subtitle,
    this.initiallyExpanded = false,
  });

  final int index; // 0-tabanlı, rozette +1 gösterilir
  final String title;
  final String summary; // sağda, kapalıyken de görünen özet metni
  final String? subtitle; // başlığın altında opsiyonel ikinci satır
  final Widget body; // expand olunca gösterilecek içerik
  final bool initiallyExpanded;

  @override
  State<ExpandableIndexedConfigCard> createState() => _ExpandableIndexedConfigCardState();
}

class _ExpandableIndexedConfigCardState extends State<ExpandableIndexedConfigCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: _expanded ? MedColors.blue.withAlpha(50) : MedColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _expanded ? MedColors.blue : MedColors.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: _expanded ? MedColors.blue : MedColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.index + 1}',
                      style: TextStyle(
                        fontFamily: MedFonts.mono,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _expanded ? Colors.white : MedColors.text3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: MedFonts.sans,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MedColors.text,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(widget.subtitle!, style: MedTextStyles.monoXs(color: MedColors.text3)),
                      ],
                    ),
                  ),
                  Text(
                    widget.summary,
                    style: TextStyle(fontFamily: MedFonts.mono, fontSize: 11, color: MedColors.text3),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 20,
                    color: MedColors.text3,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, thickness: 1, color: MedColors.border2),
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child: widget.body),
          ],
        ],
      ),
    );
  }
}
