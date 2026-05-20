part of 'medicine_management_view.dart';

class _ServiceFilterBar extends StatelessWidget {
  final List<HospitalService> services;
  final HospitalService? selectedService;
  final Color accentColor;
  final Function(HospitalService?) onToggle;
  final MedicineManagementType managementType;

  const _ServiceFilterBar({
    required this.services,
    required this.selectedService,
    required this.accentColor,
    required this.onToggle,
    required this.managementType,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ServiceChip(
                label: service.name ?? '-',
                icon: PhosphorIcons.hospital(),
                isSelected: selectedService?.id == service.id && managementType == MedicineManagementType.allPatients,
                accentColor: accentColor,
                onTap: () => onToggle(service),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ServiceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : accentColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? accentColor : accentColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
