part of 'step3_service_scope.dart';

class _RoomScopeBody extends StatefulWidget {
  const _RoomScopeBody({required this.currentScope, required this.onScopeChanged});

  final RoomBased? currentScope;
  final ValueChanged<ServiceScope> onScopeChanged;

  @override
  State<_RoomScopeBody> createState() => _RoomScopeBodyState();
}

class _RoomScopeBodyState extends State<_RoomScopeBody> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late List<String> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = List.from(widget.currentScope?.rooms ?? []);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addRoom() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    if (_rooms.contains(value)) {
      _controller.clear();
      return;
    }
    setState(() => _rooms.add(value));
    _controller.clear();
    widget.onScopeChanged(RoomBased(rooms: List.from(_rooms)));
  }

  void _removeRoom(String room) {
    setState(() => _rooms.remove(room));
    widget.onScopeChanged(RoomBased(rooms: List.from(_rooms)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──
        Text(
          'Oda Numaraları',
          style: TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: MedColors.text2,
          ),
        ),
        const SizedBox(height: 6),

        // ── Tag input ──
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MedColors.surface2,
              border: Border.all(color: MedColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                // Mevcut tag'ler
                for (final room in _rooms) _RoomTag(label: room, onRemove: () => _removeRoom(room)),
                // Input
                IntrinsicWidth(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: _rooms.isEmpty ? 'Oda numarası girin…' : 'Ekle…',
                      hintStyle: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text4),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    style: TextStyle(fontFamily: MedFonts.mono, fontSize: 13, color: MedColors.text),
                    onSubmitted: (_) => _addRoom(),
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Her oda numarasını girdikten sonra Enter\'a basın.',
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
        ),

        // ── Oda sayısı özeti ──
        if (_rooms.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: MedColors.greenLight, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.door_front_door_rounded, size: 16, color: MedColors.green),
                const SizedBox(width: 8),
                Text(
                  '${_rooms.length} oda tanımlandı',
                  style: TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MedColors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RoomTag extends StatelessWidget {
  const _RoomTag({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: MedFonts.mono,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MedColors.blue,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: MedColors.blue),
          ),
        ],
      ),
    );
  }
}
