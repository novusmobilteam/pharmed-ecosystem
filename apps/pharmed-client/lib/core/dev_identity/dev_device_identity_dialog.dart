// [SWREQ-CORE-005] Test cihazı seçimi — yalnızca bilgisayar test sürümü.
//
// Seçim bir sonraki açılışta geçerli olur: kayıt yazılır ve uygulama kapanır.
// Kimlik ve yerel depo çalışırken değiştirilmez (bkz. DevDeviceIdentity).
//
// Geliştirici/test aracıdır, son kullanıcı görmez; metinler yerelleştirilmez
// (BuildVariantBadge ve Debug sekmesiyle aynı yaklaşım).
//
// Sınıf: Class B

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'dev_device_identity.dart';

/// Test cihazı seçim ekranını açar. Bu sürümde yoksa hiçbir şey yapmaz.
Future<void> showDevDeviceIdentityDialog(BuildContext context) async {
  if (!DevDeviceIdentity.isAvailable) return;
  await showMedDialog<void>(context: context, builder: (_) => const _DevDeviceIdentityDialog());
}

class _DevDeviceIdentityDialog extends StatefulWidget {
  const _DevDeviceIdentityDialog();

  @override
  State<_DevDeviceIdentityDialog> createState() => _DevDeviceIdentityDialogState();
}

class _DevDeviceIdentityDialogState extends State<_DevDeviceIdentityDialog> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  DevDeviceRegistry? _registry;
  String? _error;
  bool _busy = false;

  /// Seçilen satır. null → "Bu bilgisayar".
  String? _pendingId;

  /// Bu oturumda çalışan cihaz.
  String? get _currentId => DevDeviceIdentity.active?.id;

  @override
  void initState() {
    super.initState();
    _pendingId = _currentId;
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final registry = await DevDeviceIdentity.loadRegistry();
    if (mounted) setState(() => _registry = registry);
  }

  Future<void> _add() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final profile = await DevDeviceIdentity.createProfile(_nameController.text, deviceId: _idController.text);
      _nameController.clear();
      _idController.clear();
      await _load();
      if (mounted) setState(() => _pendingId = profile.id);
    } catch (e) {
      final msg = e is StateError ? e.message : '$e';
      if (mounted) setState(() => _error = 'Test cihazı eklenemedi: $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _applyAndExit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await DevDeviceIdentity.selectForNextLaunch(_pendingId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Seçim kaydedilemedi: $e';
        });
      }
      return;
    }
    // Kimlik ve depo yalnızca açılışta belirlenir; temiz geçiş için kapat.
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    final registry = _registry;
    final pinned = DevDeviceIdentity.isPinnedByDefine;

    return MedDialog(
      title: 'Test cihazı',
      subtitle: 'Bu bilgisayarda hangi kabin olarak çalışılacağını seçin',
      icon: PhosphorIcons.devices(),
      width: 560,
      child: registry == null
          ? const Center(child: MedLoadingIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  pinned
                      ? 'Kimlik derleme ayarıyla (PHARMED_DEVICE_ID) sabitlendi; buradan değiştirilemez.'
                      : 'Her test cihazının kendi kimliği ve kendi yerel verisi vardır. Yeni bir cihaza '
                            'geçtiğinizde giriş yaptıktan sonra kabin kurulum sihirbazı açılır. '
                            'Seçim sonrası uygulama kapanır; yeniden açtığınızda seçilen cihaz olarak başlar.',
                  style: MedTextStyles.bodySm(color: MedColors.text2).copyWith(height: 1.5),
                ),
                const SizedBox(height: MedSpacing.lg),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _ProfileTile(
                        title: 'Bu bilgisayar',
                        subtitle: 'Gerçek cihaz kimliği · mevcut kurulum',
                        selected: _pendingId == null,
                        current: _currentId == null,
                        onTap: pinned || _busy ? null : () => setState(() => _pendingId = null),
                      ),
                      for (final profile in registry.profiles)
                        _ProfileTile(
                          title: profile.name,
                          subtitle: profile.deviceId,
                          monoSubtitle: true,
                          selected: _pendingId == profile.id,
                          current: _currentId == profile.id,
                          onTap: pinned || _busy ? null : () => setState(() => _pendingId = profile.id),
                        ),
                      if (pinned && DevDeviceIdentity.active != null)
                        _ProfileTile(
                          title: DevDeviceIdentity.active!.name,
                          subtitle: DevDeviceIdentity.active!.deviceId,
                          monoSubtitle: true,
                          selected: true,
                          current: true,
                          onTap: null,
                        ),
                    ],
                  ),
                ),
                if (!pinned) ...[
                  const SizedBox(height: MedSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: MedTextInputField(
                          controller: _nameController,
                          hintText: 'Yeni test cihazı adı (ör. Mobil kabin)',
                          enabled: !_busy,
                          onChanged: (_) {},
                          onFieldSubmitted: (_) => _busy ? null : _add(),
                        ),
                      ),
                      const SizedBox(width: MedSpacing.md),
                      Expanded(
                        child: MedTextInputField(
                          controller: _idController,
                          hintText: 'Kimlik (boşsa otomatik)',
                          enabled: !_busy,
                          onChanged: (_) {},
                          onFieldSubmitted: (_) => _busy ? null : _add(),
                        ),
                      ),
                      const SizedBox(width: MedSpacing.md),
                      MedButton(
                        label: 'Ekle',
                        variant: MedButtonVariant.secondary,
                        prefixIcon: Icon(PhosphorIcons.plus()),
                        onPressed: _busy ? null : _add,
                      ),
                    ],
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: MedSpacing.md),
                  Text(_error!, style: MedTextStyles.bodySm(color: MedColors.red)),
                ],
                const SizedBox(height: MedSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MedButton(
                      label: 'Vazgeç',
                      variant: MedButtonVariant.ghost,
                      onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
                    ),
                    if (!pinned) ...[
                      const SizedBox(width: MedSpacing.md),
                      MedButton(
                        label: 'Kapat ve geç',
                        prefixIcon: Icon(PhosphorIcons.arrowsClockwise()),
                        onPressed: _busy || _pendingId == _currentId ? null : _applyAndExit,
                      ),
                    ],
                  ],
                ),
              ],
            ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.current,
    required this.onTap,
    this.monoSubtitle = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool current;
  final bool monoSubtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MedSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.mdAll,
        child: Container(
          padding: MedSpacing.insetLg,
          decoration: BoxDecoration(
            color: selected ? MedColors.blueLight : MedColors.surface2,
            border: Border.all(color: selected ? MedColors.blue : MedColors.border),
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            children: [
              Icon(
                selected ? PhosphorIcons.radioButton(PhosphorIconsStyle.fill) : PhosphorIcons.circle(),
                size: 20,
                color: selected ? MedColors.blue : MedColors.text3,
              ),
              const SizedBox(width: MedSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: MedTextStyles.bodyMd(color: MedColors.text).copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: monoSubtitle
                          ? MedTextStyles.monoSm(color: MedColors.text3)
                          : MedTextStyles.bodySm(color: MedColors.text3),
                    ),
                  ],
                ),
              ),
              if (current)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: MedColors.greenLight, borderRadius: MedRadius.smAll),
                  child: Text('Şu an', style: MedTextStyles.bodySm(color: MedColors.green)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
