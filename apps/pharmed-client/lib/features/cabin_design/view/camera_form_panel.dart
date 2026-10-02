part of 'cabin_design_dialog.dart';

/// Sağ panel: kamera tanımı. Her açılışta (kamera/yeni) kendi
/// CameraFormNotifier'ını kurar ve kapanınca bırakır.
class _CameraFormPanel extends ConsumerStatefulWidget {
  const _CameraFormPanel({super.key, required this.selection, required this.design});

  final CameraSelection selection;
  final CabinDesignNotifier design;

  @override
  ConsumerState<_CameraFormPanel> createState() => _CameraFormPanelState();
}

class _CameraFormPanelState extends ConsumerState<_CameraFormPanel> {
  late final CameraFormNotifier _form;

  @override
  void initState() {
    super.initState();
    final id = widget.selection.cameraId;
    final cameras = widget.design.cameras;
    _form = CameraFormNotifier(
      devices: ref.read(cameraDeviceRepositoryProvider),
      secrets: ref.read(cameraSecretStoreProvider),
      tester: ref.read(cameraTesterProvider),
      existing: id == null ? null : cameras.firstWhereOrNull((c) => c.id == id),
      initialCabinId: widget.selection.initialCabinId,
      otherCameras: cameras.where((c) => c.id != id).toList(),
    );
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _openTest() async {
    unawaited(_form.runTest());
    await _CameraTestDialog.show(context, _form);
  }

  Future<void> _save() async {
    final saved = await _form.save();
    if (saved != null) await widget.design.onCameraSaved(saved);
  }

  Future<void> _delete() async {
    final confirmed = await _ConfirmDeleteCameraDialog.show(context, _form.name);
    if (confirmed != true) return;
    if (await _form.delete()) await widget.design.onCameraDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _form,
      builder: (context, _) {
        final f = _form;
        return Container(
          color: MedColors.surface,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: MedSpacing.insetXl.top * 2,
              horizontal: MedSpacing.insetXl.left * 6,
            ),
            child: Column(
              spacing: 12.0,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        f.isEditing
                            ? context.l10n.cabinDesign_camera_editTitle
                            : context.l10n.cabinDesign_camera_newTitle,
                        style: MedTextStyles.titleMd(),
                      ),
                    ),
                    IconButton(
                      onPressed: f.isBusy ? null : widget.design.closeCameraForm,
                      icon: Icon(PhosphorIcons.x()),
                    ),
                  ],
                ),

                // ── Bağlantı ───────────────────────────────────────────
                MedTextInputField(
                  label: context.l10n.cabinDesign_camera_nameLabel,
                  initialValue: f.name,
                  onChanged: f.setName,
                ),
                Row(
                  spacing: MedSpacing.sm,
                  children: [
                    Expanded(
                      flex: 3,
                      child: MedTextInputField(
                        label: context.l10n.cabinDesign_camera_hostLabel,
                        initialValue: f.host,
                        onChanged: f.setHost,
                      ),
                    ),
                    Expanded(
                      child: MedTextInputField(
                        label: context.l10n.cabinDesign_camera_portLabel,
                        initialValue: '${f.port}',
                        onChanged: f.setPort,
                        // NOT: MedTextInputField sayısal mod parametresinin adını doğrulayın
                        // (tasarım sistemi: sayısal alanda ekran klavyesi numpad açılır).
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: MedSpacing.sm,
                  children: [
                    Expanded(
                      child: MedTextInputField(
                        label: context.l10n.cabinDesign_camera_usernameLabel,
                        initialValue: f.username,
                        onChanged: f.setUsername,
                      ),
                    ),
                    Expanded(
                      child: MedTextInputField(
                        label: context.l10n.cabinDesign_camera_passwordLabel,
                        hint: f.isEditing ? context.l10n.cabinDesign_camera_passwordKeepHint : null,
                        onChanged: f.setPassword,
                        // NOT: gizli giriş parametresinin adını doğrulayın.
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
                _FieldLabel(context.l10n.cabinDesign_camera_streamLabel),
                Row(
                  spacing: 6.0,
                  children: [
                    for (final s in CameraStream.values)
                      _OptionBox(
                        label: switch (s) {
                          CameraStream.main => context.l10n.cabinDesign_camera_streamMain,
                          CameraStream.sub => context.l10n.cabinDesign_camera_streamSub,
                        },
                        isSelected: f.stream == s,
                        onTap: () => f.setStream(s),
                      ),
                  ],
                ),

                // ── Kabinler ───────────────────────────────────────────
                _FieldLabel(context.l10n.cabinDesign_camera_cabinsLabel),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    for (final cabin in widget.design.stationCabins)
                      if (cabin.id != null)
                        _CabinPickBox(
                          cabin: cabin,
                          isSelected: f.cabinIds.contains(cabin.id),
                          owner: f.ownerOfCabin(cabin.id!),
                          onTap: () => f.toggleCabin(cabin.id!),
                        ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.cabinDesign_camera_enabledLabel,
                            style: MedTextStyles.bodyMd(color: MedColors.text),
                          ),
                          Text(
                            context.l10n.cabinDesign_camera_enabledHint,
                            style: MedTextStyles.bodySm(color: MedColors.text3),
                          ),
                        ],
                      ),
                    ),
                    MedToggle(value: f.enabled, onChanged: f.isBusy ? null : f.setEnabled),
                  ],
                ),

                // ── Test ───────────────────────────────────────────────
                const SizedBox(height: MedSpacing.sm),
                _TestStatusLine(form: f),
                if (f.saveError != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 14, color: MedColors.red),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(f.saveError!, style: MedTextStyles.bodySm(color: MedColors.red)),
                      ),
                    ],
                  ),
                const SizedBox(height: MedSpacing.sm),
                Row(
                  children: [
                    if (f.isEditing)
                      MedButton(
                        label: context.l10n.cabinDesign_camera_deleteButton,
                        variant: MedButtonVariant.ghost,
                        isLoading: f.isDeleting,
                        onPressed: f.isBusy ? null : _delete,
                      ),
                    const Spacer(),
                    MedButton(
                      label: context.l10n.cabinDesign_camera_testButton,
                      prefixIcon: Icon(PhosphorIcons.videoCamera()),
                      variant: MedButtonVariant.secondary,
                      onPressed: f.canTest ? _openTest : null,
                    ),
                    const SizedBox(width: MedSpacing.sm),
                    MedButton(
                      label: context.l10n.common_saveButton,
                      isLoading: f.isSaving,
                      onPressed: f.canSave ? _save : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
  );
}

class _OptionBox extends StatelessWidget {
  const _OptionBox({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : null,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 2 : 1),
          borderRadius: MedRadius.mdAll,
        ),
        child: Text(label, style: MedTextStyles.bodyMd()),
      ),
    );
  }
}

/// Kabin seçimi. Başka kameraya atanmış kabin pasif görünür ve kime ait olduğunu söyler.
class _CabinPickBox extends StatelessWidget {
  const _CabinPickBox({required this.cabin, required this.isSelected, required this.owner, required this.onTap});

  final Cabin cabin;
  final bool isSelected;
  final CameraDevice? owner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final taken = owner != null;
    return GestureDetector(
      onTap: taken ? null : onTap,
      child: Container(
        width: 150,
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: taken ? MedColors.surface3 : (isSelected ? MedColors.blueLight : null),
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 2 : 1),
          borderRadius: MedRadius.mdAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cabin.name ?? '—',
              style: MedTextStyles.bodyMd(color: taken ? MedColors.text4 : MedColors.text),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              taken ? context.l10n.cabinDesign_camera_cabinAssignedTo(owner!.name) : (cabin.type?.label ?? ''),
              style: MedTextStyles.bodySm(color: MedColors.text4),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Kaydet'in neden kapalı olduğunu söyler: test yok / değerler değişti / geçerli.
class _TestStatusLine extends StatelessWidget {
  const _TestStatusLine({required this.form});
  final CameraFormNotifier form;

  @override
  Widget build(BuildContext context) {
    final result = form.testResult;
    final (icon, color, text) = switch ((result, form.isTestValid)) {
      (final r?, true) => (
        Icons.check_circle_outline_rounded,
        MedColors.green,
        context.l10n.cabinDesign_camera_testValid(r.connectTime.inMilliseconds, r.mbPerMinute.toStringAsFixed(1)),
      ),
      (_?, false) => (Icons.refresh_rounded, MedColors.amber, context.l10n.cabinDesign_camera_testStale),
      (null, _) => (Icons.info_outline_rounded, MedColors.text4, context.l10n.cabinDesign_camera_testRequiredHint),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: MedTextStyles.bodySm(color: MedColors.text3)),
        ),
      ],
    );
  }
}

class _ConfirmDeleteCameraDialog extends StatelessWidget {
  const _ConfirmDeleteCameraDialog({required this.name});
  final String name;

  static Future<bool?> show(BuildContext context, String name) => showDialog<bool>(
    context: context,
    builder: (_) => _ConfirmDeleteCameraDialog(name: name),
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: MedSpacing.insetXl * 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: MedSpacing.md,
            children: [
              Text(context.l10n.cabinDesign_camera_deleteConfirmTitle, style: MedTextStyles.titleMd()),
              Text(
                context.l10n.cabinDesign_camera_deleteConfirmMessage(name),
                style: MedTextStyles.bodyMd(color: MedColors.text2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(context.l10n.common_cancelButton),
                  ),
                  const SizedBox(width: MedSpacing.sm),
                  MedButton(
                    label: context.l10n.cabinDesign_camera_deleteButton,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
