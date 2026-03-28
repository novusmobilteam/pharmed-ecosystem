part of 'unified_table_view.dart';

// ─── HIZLI TARİH FİLTRE POPUP ────────────────────────────────────────────────

class _QuickDateFilterPopup extends StatelessWidget {
  const _QuickDateFilterPopup({
    this.selectedDateRange,
    required this.onDateSelected,
  });

  final DateTimeRange? selectedDateRange;
  final Function(DateTimeRange?) onDateSelected;

  bool _isSameRange(DateTime start, DateTime end) {
    if (selectedDateRange == null) return false;
    return DateUtils.isSameDay(selectedDateRange!.start, start) && DateUtils.isSameDay(selectedDateRange!.end, end);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final todayStart = now;
    final todayEnd = now;
    final yesterday = now.subtract(const Duration(days: 1));
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekEnd = now;
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);
    final last30Start = now.subtract(const Duration(days: 30));
    final last30End = now;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const Divider(height: 1, color: Color(0xFFEEF0F4)),
              const SizedBox(height: 4),
              _buildOption(context,
                  icon: Icons.today_outlined,
                  label: 'Bugün',
                  isSelected: _isSameRange(todayStart, todayEnd),
                  onTap: () => _select(context, todayStart, todayEnd)),
              _buildOption(context,
                  icon: Icons.history,
                  label: 'Dün',
                  isSelected: _isSameRange(yesterday, yesterday),
                  onTap: () => _select(context, yesterday, yesterday)),
              _buildOption(context,
                  icon: Icons.calendar_view_week_outlined,
                  label: 'Bu Hafta',
                  isSelected: _isSameRange(thisWeekStart, thisWeekEnd),
                  onTap: () => _select(context, thisWeekStart, thisWeekEnd)),
              _buildOption(context,
                  icon: Icons.calendar_month_outlined,
                  label: 'Bu Ay',
                  isSelected: _isSameRange(thisMonthStart, thisMonthEnd),
                  onTap: () => _select(context, thisMonthStart, thisMonthEnd)),
              _buildOption(context,
                  icon: Icons.schedule_outlined,
                  label: 'Son 30 Gün',
                  isSelected: _isSameRange(last30Start, last30End),
                  onTap: () => _select(context, last30Start, last30End)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Divider(height: 1, color: Color(0xFFEEF0F4)),
              ),
              _buildOption(
                context,
                icon: Icons.date_range_outlined,
                label: 'Özel Aralık Belirle...',
                color: const Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                isSelected: selectedDateRange != null &&
                    !_isSameRange(todayStart, todayEnd) &&
                    !_isSameRange(yesterday, yesterday) &&
                    !_isSameRange(thisWeekStart, thisWeekEnd) &&
                    !_isSameRange(thisMonthStart, thisMonthEnd) &&
                    !_isSameRange(last30Start, last30End),
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => _DateRangePicker(
                      initialStartDate: selectedDateRange?.start,
                      initialEndDate: selectedDateRange?.end,
                      onApply: onDateSelected,
                    ),
                  );
                },
              ),
              if (selectedDateRange != null)
                _buildOption(
                  context,
                  icon: Icons.delete_outline,
                  label: 'Filtreyi Temizle',
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                  isSelected: false,
                  onTap: () {
                    onDateSelected(null);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    final hasFilter = selectedDateRange != null;
    final label = hasFilter
        ? () {
            final s = fmt.format(selectedDateRange!.start);
            final e = fmt.format(selectedDateRange!.end);
            return s == e ? s : '$s – $e';
          }()
        : 'Filtre Yok';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      color: hasFilter ? const Color(0xFFEFF6FF) : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasFilter ? 'Seçili Aralık' : 'Tarih Aralığı Seçin',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                hasFilter ? Icons.event_available : Icons.calendar_today_outlined,
                size: 15,
                color: hasFilter ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasFilter ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, DateTime start, DateTime end) {
    onDateSelected(DateTimeRange(start: start, end: end));
    Navigator.pop(context);
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final effectiveColor = isSelected ? const Color(0xFF2563EB) : (color ?? const Color(0xFF374151));

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.06) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : icon,
              size: 18,
              color: isSelected ? const Color(0xFF2563EB) : (color ?? const Color(0xFF6B7280)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: effectiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : (fontWeight ?? FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ÖZEL TARİH ARALIĞI SEÇİCİ ───────────────────────────────────────────────

class _DateRangePicker extends StatefulWidget {
  const _DateRangePicker({
    this.initialStartDate,
    this.initialEndDate,
    required this.onApply,
  });

  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTimeRange) onApply;

  @override
  State<_DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<_DateRangePicker> {
  late DateTime _focusedMonth;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _focusedMonth = widget.initialStartDate ?? DateTime.now();
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = day;
        _endDate = null;
      } else {
        if (day.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = day;
        } else {
          _endDate = day;
        }
      }
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 530),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildMonthControls(),
              const SizedBox(height: 12),
              _buildWeekDays(),
              const SizedBox(height: 8),
              Expanded(child: _buildDaysGrid()),
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final fmt = DateFormat('dd.MM.yyyy');
    return Row(
      children: [
        Expanded(child: _buildDateChip('Başlangıç', _startDate, fmt, active: _endDate != null || _startDate == null)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.arrow_forward, size: 16, color: Color(0xFF9CA3AF)),
        ),
        Expanded(child: _buildDateChip('Bitiş', _endDate, fmt, active: _startDate != null && _endDate == null)),
      ],
    );
  }

  Widget _buildDateChip(String label, DateTime? date, DateFormat fmt, {required bool active}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
              width: active ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 13, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Text(
                date != null ? fmt.format(date) : '--.--.----',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: date != null ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthControls() {
    final fmt = DateFormat('MMMM yyyy', 'tr_TR');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MonthBtn(icon: Icons.chevron_left, onPressed: () => _changeMonth(-1)),
        Text(
          fmt.format(_focusedMonth),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        _MonthBtn(icon: Icons.chevron_right, onPressed: () => _changeMonth(1)),
      ],
    );
  }

  Widget _buildWeekDays() {
    const days = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((d) => SizedBox(
                width: 36,
                child: Center(
                  child: Text(d,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final offset = firstDay.weekday - 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth + offset,
      itemBuilder: (_, index) {
        if (index < offset) return const SizedBox();
        final day = index - offset + 1;
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final isStart = _startDate != null && DateUtils.isSameDay(date, _startDate!);
        final isEnd = _endDate != null && DateUtils.isSameDay(date, _endDate!);
        final inRange = _startDate != null && _endDate != null && date.isAfter(_startDate!) && date.isBefore(_endDate!);

        return GestureDetector(
          onTap: () => _onDaySelected(date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: (isStart || isEnd)
                  ? const Color(0xFF2563EB)
                  : inRange
                      ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: (isStart || isEnd) ? FontWeight.w700 : FontWeight.w400,
                  color: (isStart || isEnd)
                      ? Colors.white
                      : inRange
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF374151),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _DialogBtn(label: 'İptal', onPressed: () => Navigator.pop(context), filled: false),
        const SizedBox(width: 8),
        _DialogBtn(
          label: 'Uygula',
          filled: true,
          onPressed: () => _startDate != null && _endDate != null
              ? () {
                  widget.onApply(DateTimeRange(start: _startDate!, end: _endDate!));
                  Navigator.pop(context);
                }
              : null,
        ),
      ],
    );
  }
}

class _MonthBtn extends StatefulWidget {
  const _MonthBtn({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;
  @override
  State<_MonthBtn> createState() => _MonthBtnState();
}

class _MonthBtnState extends State<_MonthBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF5F7FA) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _hovered ? const Color(0xFFE5E7EB) : Colors.transparent),
          ),
          child: Icon(widget.icon, size: 18, color: const Color(0xFF374151)),
        ),
      ),
    );
  }
}
