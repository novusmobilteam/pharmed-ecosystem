import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/common.dart';

// Serum avadanlık elektromanyetik kilitleri — #217, #221.
//
// Kilit kartı aynı RS485 hattında, kendi protokolüyle konuşur:
//   komut <iXX:YZ>  (XX kart ID 01-99, Y port 1-8, Z komut)  →  yanıt /xxxx\
//   k: tüm kilitleri enerjile (sabitle)    x: tümünü serbest bırak
//   o: portu aç (diğerlerini kart kilitler) c: açmayı iptal et
//   s: portun İŞLEM durumu   t: Al-Ver tuş değeri
//
// ÖNEMLİ (#221 saha): `s` kilidin FİZİKSEL durumunu değil kartın o porttaki
// işlem durumunu döner. k/x sonrası kart her zaman "boşta" (s:00) döner —
// kilitlerin enerjili/serbest olduğu `s` ile görülemez. Bu yüzden ekranda
// son kart geneli komutu (k/x) ayrıca gösterilir ve `o` sonrası teknisyen
// fiziksel sonucu işaretler.
//
// ÇEK / SAY / İT TESTİ (#263): port LED'i ve +/- tuşu yalnızca avadanlık
// çekildiğinde (s:02) aktiftir. Test k → o sonrası durumu ve tuş değerini
// canlı izler: çekme (s:02) → LED sorusu + tuş değeri → yerine itme (s:03).
//
// PORT KAPATMA (#277, yeni firmware): yerine itilen avadanlık s:03'te
// (close bekleniyor) kalır; port `c` (CLOSE) ile kapatılır → s:00 (boşta).
// Test s:03'ü görünce c gönderir ve s:00'ı bekler.
//
// TEK PORT TEŞHİSİ (#257): elle denemelerde o'dan önce x gönderilince kilitler
// zaten serbest olduğu için o ölçülemiyordu. Teşhis k → s → o → s sırasını
// tek tuşla çalıştırır, fiziksel gözleme göre olası nedeni rapora yazar ve
// portu c ile boşa alır.
// #260: o sonrası durum ~3 sn sorgulanır; kart s:01 bildirmese de fiziksel
// gözlem istenir ve yorum kartın bildirdiğiyle birlikte yazılır.
//
// OLMASI GEREKEN AKIŞ (x → kapak aç → k → o → çek/it → kapak kapan → x) raf
// tanımıyla birlikte Serum sayfasında test edilir (core/serum_hardware.dart).
// Bu bölüm yalnızca elle / ham komutlar içindir (Gelişmiş araçlar).

class TrayLockSection extends ConsumerStatefulWidget {
  const TrayLockSection({super.key, required this.address, required this.row, required this.idle});

  /// Yönetim kartı adresi (1 = A).
  final int address;

  /// Serum kartının satırı (bağımsız serum kabininde 26). null → kapak adımları kapalı.
  final int? row;

  /// Üst sayfada başka bir işlem sürmüyor.
  final bool idle;

  @override
  ConsumerState<TrayLockSection> createState() => _TrayLockSectionState();
}

// ── Kart yanıtının okunur hali ──────────────────────────────────────

/// Bir kart yanıtının ekranda gösterilecek hali.
class _Reading {
  const _Reading(this.tone, this.title, [this.note]);

  /// Renk ve ikon tonu (pharmed_ui ortak durum renkleri).
  final MedTone tone;
  final String title;
  final String? note;

  static _Reading of(TrayLockResponse r, {int? port}) {
    final p = port == null ? '' : 'Port $port: ';
    return switch (r) {
      TrayLockOk() => const _Reading(MedTone.success, 'Komut kabul edildi (okkk)'),
      TrayLockStatusResponse(:final status) => switch (status) {
        TrayLockStatus.unlocked => _Reading(
          MedTone.warning,
          '${p}kart kilidi AÇTI, avadanlık henüz çekilmedi (s:01)',
          'Avadanlık fiziksel olarak serbest değilse kilit kartın komutuna uymuyor demektir.',
        ),
        TrayLockStatus.pulled => _Reading(MedTone.info, '${p}avadanlık ÇEKİLDİ (s:02)'),
        TrayLockStatus.pushed => _Reading(
          MedTone.warning,
          '${p}avadanlık YERİNE İTİLDİ — port kapatma (c) bekleniyor (s:03)',
          'Yeni firmware\'de port, c (CLOSE) gönderilene kadar s:03\'te kalır; c sonrası s:00 (boşta) beklenir.',
        ),
        TrayLockStatus.idle => _Reading(
          MedTone.neutral,
          '${p}kart boşta — bu portta açma işlemi yok (s:00)',
          's:00 kilidin fiziksel durumunu göstermez. k / x sonrası kart her zaman boşta döner; '
              'kilitlerin enerjili mi serbest mi olduğu için "Kart geneli" satırına bakın.',
        ),
      },
      TrayLockKeypadResponse(:final value) => _Reading(MedTone.info, '${p}Al-Ver tuş değeri: $value'),
      TrayLockErrorResponse(:final failure) => _Reading(MedTone.error, '$p${_failureText(failure)}'),
    };
  }

  static String _failureText(TrayLockFailure f) => switch (f) {
    TrayLockFailure.invalidDeviceId => 'Geçersiz kart ID (noo1)',
    TrayLockFailure.trayOpen => 'Bir avadanlık çekili — önce yerine itin (noo2)',
    TrayLockFailure.invalidPort => 'Geçersiz port (noo3)',
    TrayLockFailure.busy => 'Kart meşgul — başka port açık (noo4)',
    TrayLockFailure.alreadyPulled => 'Avadanlık zaten çekildi, iptal edilemez (noo5)',
    TrayLockFailure.unknownCommand => 'Kart komutu tanımadı (noo6)',
    TrayLockFailure.noResponse => 'Kart cevap vermedi',
    TrayLockFailure.protocolError => 'Tanınmayan yanıt',
  };

  Color get color => MedSemanticColors.of(tone).foreground;

  IconData get icon => switch (tone) {
    MedTone.success => Icons.check_circle,
    MedTone.warning => Icons.lock_open,
    MedTone.info => Icons.info,
    MedTone.neutral => Icons.radio_button_unchecked,
    MedTone.error => Icons.error,
  };
}

/// Yanıtı renkli, açıklamalı bir kutu olarak gösterir.
class _ReadingTile extends StatelessWidget {
  const _ReadingTile({required this.reading, this.raw, this.label});

  final _Reading reading;
  final String? raw;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = reading.color;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.07),
        border: Border.all(color: c.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(reading.icon, size: 18, color: c),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label == null ? reading.title : '$label — ${reading.title}',
                  style: TextStyle(fontWeight: FontWeight.w600, color: c),
                ),
                if (reading.note != null)
                  Text(reading.note!, style: TextStyle(fontSize: 12, color: MedColors.text2)),
                if (raw != null)
                  Text(
                    'Ham: $raw',
                    style: monoStyle(fontSize: 11, color: MedColors.text3),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `o` sonrası teknisyenin fiziksel gözlemi: (etiket, doğru mu, olası neden).
///
/// Olası neden yalnızca teşhis sırası (k → o) ile anlamlıdır; k ile
/// enerjilenmemiş kilitlerde `o` tek port açmayı ölçmez (#257).
/// Çek / say / it testinin aşaması (#263).
enum _CycleStage {
  /// `o` gönderildi; avadanlığın çekilmesi (s:02) bekleniyor.
  waitPull,

  /// Çekildi (s:02): LED ve +/- tuşu denetleniyor; yerine itme (s:03) bekleniyor,
  /// ardından c ile port kapatılır (s:00, #277).
  pulled,

  /// Bitti (yerine itildi ya da teknisyen durdurdu).
  done,
}

const _observations = [
  ('Yalnız hedef serbest (doğru)', true, 'Tek port açma çalışıyor.'),
  (
    'Hedef kilitli, diğerleri kilitli',
    false,
    'Kart açtığını bildiriyor ama çıkışı bırakmıyor. Port uçlarında gerilimi ölçün: o sonrası düşmüyorsa '
        'kart/firmware (o, k ile enerjilenen çıkışı bırakmıyor), düşüyorsa kablolama veya kilit mekaniği.',
  ),
  (
    'Hedef kilitli, BAŞKA bir avadanlık serbest',
    false,
    'Port eşleşmesi kayık: protokoldeki port ile fiziksel avadanlık farklı. Hangi avadanlığın açıldığını not edin.',
  ),
  (
    'Hedef kilitli, diğerleri SERBEST (ters)',
    false,
    'Polarite ters: kart o sırasında hedefi enerjili bırakıp diğerlerini serbest bırakıyor '
        '("enerji = açık" tipi kilit varsayımı). Kilit tipi / kart yazılımı kontrol edilmeli.',
  ),
  ('Hepsi serbest', false, 'k kilitleri tutmuyor ya da o tüm kilitleri bırakıyor. Önce k / x testini tekrarlayın.'),
];

class _TrayLockSectionState extends ConsumerState<TrayLockSection> {
  final _deviceCtrl = TextEditingController(text: '1');
  int _port = 1;

  bool _busy = false;

  // Son komut
  String? _lastLabel;
  String? _lastRaw;
  _Reading? _lastReading;

  /// Son başarılı kart geneli komut: 'k' (enerjili), 'x' (serbest) ya da null.
  String? _cardMode;

  /// `o` sonrası fiziksel gözlem bekleyen port.
  int? _awaitingObservation;

  /// Gözlem "Tek port teşhisi" sırasından geliyor: gözlemden sonra yorum
  /// rapora yazılır ve port `c` ile boşa alınır.
  bool _diagnosing = false;

  /// Teşhis adımlarının sonuçları (etiket, ham, okuma).
  List<(String, String, _Reading)>? _diagSteps;

  /// Teşhis sonrası yorum.
  String? _diagVerdict;

  /// Teşhiste `o` sonrası kart en az bir kez `s:01` (kilit açık) bildirdi mi.
  bool _diagSeenUnlocked = false;

  /// `o` sonrası durum kaç kez, hangi aralıkla sorgulanır (#260).
  static const _diagPollCount = 6;
  static const _diagPollInterval = Duration(milliseconds: 500);

  // Çek / say / it testi (#263)
  Timer? _cycleTimer;
  _CycleStage? _cycleStage;
  int? _cyclePort;
  TrayLockStatus? _cycleStatus;
  int? _cycleKeypad;

  /// Çekili iken görülen tuş değerleri (değişim sırasıyla).
  final List<int> _cycleKeypadSeen = [];
  bool? _cycleLed;
  bool _cycleKeypadFailed = false;
  bool _cyclePullMissed = false;
  final Stopwatch _cycleClock = Stopwatch();
  String? _cycleVerdict;
  bool _cycleFinishing = false;
  bool _cycleSeenUnlocked = false;

  /// Yerine itme (s:03) görüldü mü ve c ile s:00'a kapatıldı mı (#277).
  bool _cyclePushedSeen = false;
  bool? _cycleClosed;

  // Kart ID taraması
  List<int>? _foundDevices;

  // Port tablosu (1–8 durum)
  Map<int, (String?, TrayLockResponse)>? _portTable;

  // Canlı durum
  Timer? _watch;
  int? _watchPort;
  bool _polling = false;
  _Reading? _liveReading;
  int? _liveKeypad;

  int? get _deviceId {
    final v = int.tryParse(_deviceCtrl.text.trim());
    return v != null && v >= TrayLockProtocol.minDeviceId && v <= TrayLockProtocol.maxDeviceId ? v : null;
  }

  ISerialCommunicationService get _serial => ref.read(serialServiceProvider);

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _watch?.cancel();
    _deviceCtrl.dispose();
    super.dispose();
  }

  // ── Kilit kartı komutları ──────────────────────────────────────

  Future<(String?, TrayLockResponse)> _tray(int deviceId, TrayLockAction action, {int? port, Duration? timeout}) async {
    final cmd = TrayLockProtocol.build(deviceId: deviceId, action: action, port: port);
    String? raw;
    try {
      raw = await _serial.sendAndReceive(cmd, timeout: timeout ?? const Duration(milliseconds: 1000));
    } catch (_) {
      raw = null;
    }
    final res = TrayLockProtocol.parse(raw);
    if (res is TrayLockOk && action.isCardWide && mounted) {
      setState(() => _cardMode = action == TrayLockAction.lockAll ? 'k' : 'x');
    }
    return (raw?.trim(), res);
  }

  static String _actionLabel(TrayLockAction a) => switch (a) {
    TrayLockAction.lockAll => 'Tümünü kilitle (k)',
    TrayLockAction.unlockAll => 'Tümünü serbest bırak (x)',
    TrayLockAction.open => 'Portu aç (o)',
    TrayLockAction.cancel => 'İptal / portu kapat (c)',
    TrayLockAction.status => 'Durum (s)',
    TrayLockAction.keypadValue => 'Tuş değeri (t)',
  };

  Future<void> _manual(TrayLockAction action) async {
    final deviceId = _deviceId;
    if (deviceId == null) return showMessage(context, 'Kart ID 1–99 olmalı.', error: true);
    final port = action.isCardWide ? null : _port;
    setState(() => _busy = true);
    final (raw, res) = await _tray(deviceId, action, port: port);
    final reading = _Reading.of(res, port: port);
    final label = 'Kart $deviceId · ${_actionLabel(action)}${port == null ? '' : ' · port $port'}';
    ref
        .read(testReportProvider)
        .add(
          label,
          res is TrayLockErrorResponse ? StepResult.fail : StepResult.info,
          detail: '${raw ?? '(cevap yok)'} → ${reading.title}',
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastLabel = label;
      _lastRaw = raw ?? '(cevap yok)';
      _lastReading = reading;
      _diagSteps = null;
      _diagVerdict = null;
      _awaitingObservation = action == TrayLockAction.open && res is TrayLockOk ? port : null;
      _diagnosing = false;
    });
    // #277: açılan port, itildiğinde (s:03) otomatik kapatılsın diye izlenir.
    if (action == TrayLockAction.open && res is TrayLockOk && port != null) {
      if (_watch != null && _watchPort != port) _toggleWatch(); // eski portun izlemesini bırak
      if (_watch == null) _toggleWatch();
    }
  }

  /// #277: izlenen port s:03'e (itildi) geçince c otomatik gönderilir → s:00.
  /// Kullanıcıdan elle kapatma beklenmez; client'taki akışın aynısıdır.
  Future<void> _autoClosePort(int deviceId, int port, String? statusRaw) async {
    final report = ref.read(testReportProvider);
    report.add(
      'Kart $deviceId · port $port yerine itildi (s:03)',
      StepResult.ok,
      detail: statusRaw ?? '/s:03\\',
    );
    final (raw, res) = await _tray(deviceId, TrayLockAction.cancel, port: port);
    report.add(
      'Kart $deviceId · Otomatik port kapatma (c) · port $port',
      res is TrayLockOk ? StepResult.ok : StepResult.fail,
      detail: '${raw ?? '(cevap yok)'} → ${_Reading.of(res, port: port).title}',
    );
  }

  /// Tek port teşhisi (#257): k → s → o → s, ardından fiziksel gözlem.
  /// Kilitler önce k ile enerjilenir; böylece `o`'nun yalnızca hedefi
  /// bırakıp bırakmadığı ölçülür (x sonrası `o` bunu ölçmez).
  ///
  /// #260: `o` sonrası durum ~3 sn sorgulanır (kart açılıp hemen boşa dönüyor
  /// mu görülür) ve kart `s:01` bildirmese de fiziksel gözlem istenir.
  Future<void> _diagnosePort() async {
    final deviceId = _deviceId;
    if (deviceId == null) return showMessage(context, 'Kart ID 1–99 olmalı.', error: true);
    final port = _port;
    setState(() {
      _busy = true;
      _diagSteps = [];
      _diagVerdict = null;
      _awaitingObservation = null;
      _diagnosing = false;
    });

    final report = ref.read(testReportProvider);
    report.add(
      'Tek port teşhisi başladı',
      StepResult.info,
      detail: 'Kart $deviceId · port $port · sıra: k → s → o → s ×$_diagPollCount',
    );

    // (komut, port, beklenen sonuç). o sonrası durum aşağıda ayrıca sorgulanır.
    final plan = <(TrayLockAction, int?, bool Function(TrayLockResponse))>[
      (TrayLockAction.lockAll, null, (r) => r is TrayLockOk),
      (TrayLockAction.status, port, (r) => r is TrayLockStatusResponse && r.status == TrayLockStatus.idle),
      (TrayLockAction.open, port, (r) => r is TrayLockOk),
    ];

    var allOk = true;
    for (final (action, p, expected) in plan) {
      final (raw, res) = await _tray(deviceId, action, port: p);
      if (!mounted) return;
      final reading = _Reading.of(res, port: p);
      final ok = expected(res);
      final label = '${_actionLabel(action)}${p == null ? '' : ' · port $p'}';
      report.add(
        'Teşhis — $label',
        ok ? StepResult.ok : StepResult.fail,
        detail: '${raw ?? '(cevap yok)'} → ${reading.title}',
      );
      setState(() => _diagSteps = [...?_diagSteps, (label, raw ?? '(cevap yok)', reading)]);
      if (!ok) {
        allOk = false;
        break;
      }
    }

    if (!mounted) return;
    if (!allOk) {
      // Kart beklenen cevabı vermedi; açık kalmış olabilecek portu boşa al.
      await _tray(deviceId, TrayLockAction.cancel, port: port);
      const verdict = 'Kart beklenen cevabı vermedi — yukarıdaki adıma bakın. Fiziksel gözlem istenmedi.';
      report.add('Tek port teşhisi yarıda kaldı', StepResult.fail, detail: verdict);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _diagVerdict = verdict;
      });
      return;
    }

    // o sonrası durum: kart s:01'e geçiyor mu, geçip hemen boşa mı dönüyor?
    var seenUnlocked = false;
    final statuses = <String>[];
    for (var i = 0; i < _diagPollCount; i++) {
      if (i > 0) await Future<void>.delayed(_diagPollInterval);
      if (!mounted) return;
      final sw = Stopwatch()..start();
      final (raw, res) = await _tray(deviceId, TrayLockAction.status, port: port);
      sw.stop();
      if (!mounted) return;
      final unlocked = res is TrayLockStatusResponse && res.status == TrayLockStatus.unlocked;
      seenUnlocked |= unlocked;
      statuses.add(raw ?? '(cevap yok)');
      final reading = _Reading.of(res, port: port);
      final label = 'Durum (s) · port $port · o sonrası ${i + 1}/$_diagPollCount (${sw.elapsedMilliseconds} ms)';
      report.add(
        'Teşhis — $label',
        unlocked ? StepResult.ok : StepResult.fail,
        detail: '${raw ?? '(cevap yok)'} → ${reading.title}',
      );
      setState(() => _diagSteps = [...?_diagSteps, (label, raw ?? '(cevap yok)', reading)]);
    }
    report.add(
      seenUnlocked ? 'Teşhis — kart kilidi açık bildirdi' : 'Teşhis — kart açma durumuna geçmedi',
      seenUnlocked ? StepResult.ok : StepResult.fail,
      detail: 'o sonrası durumlar: ${statuses.join(' ')}',
    );

    setState(() {
      _busy = false;
      _awaitingObservation = port;
      _diagnosing = true;
      _diagSeenUnlocked = seenUnlocked;
    });
  }

  // ── Çek / say / it testi (#263) ───────────────────────────────

  String get _cycleTime => '${(_cycleClock.elapsedMilliseconds / 1000).toStringAsFixed(1)} sn';

  Future<void> _startCycle() async {
    final deviceId = _deviceId;
    if (deviceId == null) return showMessage(context, 'Kart ID 1–99 olmalı.', error: true);
    _watch?.cancel();
    final port = _port;
    setState(() {
      _busy = true;
      _watch = null;
      _cycleStage = null;
      _cyclePort = port;
      _cycleStatus = null;
      _cycleKeypad = null;
      _cycleKeypadSeen.clear();
      _cycleLed = null;
      _cycleKeypadFailed = false;
      _cyclePullMissed = false;
      _cycleVerdict = null;
      _cycleFinishing = false;
      _cycleSeenUnlocked = false;
      _cyclePushedSeen = false;
      _cycleClosed = null;
      _awaitingObservation = null;
      _diagnosing = false;
    });
    final report = ref.read(testReportProvider);
    report.add('Çek / say / it testi başladı', StepResult.info, detail: 'Kart $deviceId · port $port · k → o → çek → say → it');

    for (final action in [TrayLockAction.lockAll, TrayLockAction.open]) {
      final p = action == TrayLockAction.open ? port : null;
      final (raw, res) = await _tray(deviceId, action, port: p);
      if (!mounted) return;
      final ok = res is TrayLockOk;
      report.add(
        'Çek/say/it — ${_actionLabel(action)}${p == null ? '' : ' · port $p'}',
        ok ? StepResult.ok : StepResult.fail,
        detail: '${raw ?? '(cevap yok)'} → ${_Reading.of(res, port: p).title}',
      );
      if (!ok) {
        await _finishCycle('Kart ${_actionLabel(action)} komutunu kabul etmedi — test başlamadı.', StepResult.fail);
        return;
      }
    }

    _cycleClock
      ..reset()
      ..start();
    setState(() => _cycleStage = _CycleStage.waitPull);
    _cycleTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _pollCycle(deviceId, port));
  }

  Future<void> _pollCycle(int deviceId, int port) async {
    if (_polling || !mounted || _cycleStage == null || _cycleStage == _CycleStage.done) return;
    _polling = true;
    try {
      final (sRaw, s) = await _tray(deviceId, TrayLockAction.status, port: port);
      final (_, t) = await _tray(deviceId, TrayLockAction.keypadValue, port: port);
      if (!mounted || _cycleStage == null || _cycleStage == _CycleStage.done) return;
      final report = ref.read(testReportProvider);

      final status = s is TrayLockStatusResponse ? s.status : null;
      if (status != null && status != _cycleStatus) {
        report.add(
          'Çek/say/it — durum değişti ($_cycleTime)',
          StepResult.info,
          detail: '${sRaw ?? ''} → ${_Reading.of(s, port: port).title}',
        );
      }

      final keypad = t is TrayLockKeypadResponse ? t.value : null;
      if (keypad != null && keypad != _cycleKeypad && status == TrayLockStatus.pulled) {
        _cycleKeypadSeen.add(keypad);
        report.add('Çek/say/it — tuş değeri: $keypad ($_cycleTime)', StepResult.info);
      }

      setState(() {
        _cycleStatus = status ?? _cycleStatus;
        _cycleKeypad = keypad ?? _cycleKeypad;
      });

      if (status == TrayLockStatus.unlocked) _cycleSeenUnlocked = true;
      if (_cycleStage == _CycleStage.waitPull && status == TrayLockStatus.idle && _cycleSeenUnlocked) {
        // Kart çekme beklerken kendiliğinden boşa döndü (zaman aşımı vb.).
        await _finishCycle(
          'Kart çekme beklerken boşa döndü (s:01 → s:00, $_cycleTime). Avadanlık çekildiyse kart çekmeyi '
          'algılamadı (sensör / bağlantı); çekilmediyse testi tekrarlayıp daha hızlı çekin.',
          StepResult.fail,
        );
      } else if (_cycleStage == _CycleStage.waitPull && status == TrayLockStatus.pulled) {
        report.add('Çek/say/it — kart çekmeyi algıladı (s:02)', StepResult.ok, detail: _cycleTime);
        setState(() => _cycleStage = _CycleStage.pulled);
      } else if (status == TrayLockStatus.pushed &&
          (_cycleStage == _CycleStage.pulled || _cycleStage == _CycleStage.waitPull)) {
        // #277: yerine itildi (s:03) → c ile port kapatılır, s:00 beklenir.
        if (_cycleStage == _CycleStage.waitPull) {
          report.add(
            'Çek/say/it — kart çekmeyi (s:02) bildirmeden itildi durumuna geçti (s:03)',
            StepResult.fail,
            detail: _cycleTime,
          );
        } else {
          report.add('Çek/say/it — kart yerine itmeyi algıladı (s:03)', StepResult.ok, detail: _cycleTime);
        }
        _cyclePushedSeen = true;
        _cycleClosed = await _closePort(deviceId, port);
        await _finishCycle(null, null);
      } else if (_cycleStage == _CycleStage.pulled && status == TrayLockStatus.idle) {
        // Eski firmware: itilince doğrudan boşa döner (s:03 görülmeden).
        report.add(
          'Çek/say/it — kart s:03 göstermeden boşa döndü (s:00)',
          StepResult.info,
          detail: 'Eski firmware davranışı olabilir · $_cycleTime',
        );
        await _finishCycle(null, null);
      }
    } finally {
      _polling = false;
    }
  }

  void _cycleMarkLed(bool lit) {
    ref
        .read(testReportProvider)
        .add(
          'Çek/say/it — port LED\'i ${lit ? 'yandı' : 'YANMADI'}',
          lit ? StepResult.ok : StepResult.fail,
          detail: 'Port $_cyclePort · $_cycleTime',
        );
    setState(() => _cycleLed = lit);
  }

  void _cycleMarkKeypadFailed() {
    ref
        .read(testReportProvider)
        .add(
          'Çek/say/it — +/- tuşuna basıldı, değer değişmedi',
          StepResult.fail,
          detail: 'Okunan: ${_cycleKeypad ?? '—'} · $_cycleTime',
        );
    setState(() => _cycleKeypadFailed = true);
  }

  Future<void> _cyclePullNotSeen() async {
    ref
        .read(testReportProvider)
        .add(
          'Çek/say/it — avadanlık çekildi ama kart görmedi',
          StepResult.fail,
          detail: 'Son durum: ${_cycleStatus == null ? '—' : _statusCode(_cycleStatus!)} · $_cycleTime',
        );
    setState(() => _cyclePullMissed = true);
    await _finishCycle(null, null);
  }

  static String _statusCode(TrayLockStatus s) => switch (s) {
    TrayLockStatus.unlocked => 's:01',
    TrayLockStatus.pulled => 's:02',
    TrayLockStatus.pushed => 's:03',
    TrayLockStatus.idle => 's:00',
  };

  /// #277: s:03'teki portu c (CLOSE) ile kapatır ve s:00'ı bekler (≤ 5 sn).
  Future<bool> _closePort(int deviceId, int port) async {
    final report = ref.read(testReportProvider);
    final (raw, res) = await _tray(deviceId, TrayLockAction.cancel, port: port);
    report.add(
      'Çek/say/it — Port kapat (c) · port $port',
      res is TrayLockOk ? StepResult.ok : StepResult.fail,
      detail: '${raw ?? '(cevap yok)'} → ${_Reading.of(res, port: port).title}',
    );
    if (res is! TrayLockOk) return false;
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    String last = '—';
    while (DateTime.now().isBefore(deadline)) {
      final (sRaw, s) = await _tray(deviceId, TrayLockAction.status, port: port);
      last = sRaw ?? '(cevap yok)';
      if (s is TrayLockStatusResponse) {
        if (mounted) setState(() => _cycleStatus = s.status);
        if (s.status == TrayLockStatus.idle) {
          report.add('Çek/say/it — port kapandı (s:00)', StepResult.ok, detail: '$last · $_cycleTime');
          return true;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    report.add('Çek/say/it — c sonrası s:00 görülmedi', StepResult.fail, detail: 'Son: $last');
    return false;
  }

  /// Testi bitirir; [verdict] verilmezse toplananlardan yorum üretilir.
  /// Port hâlâ "açık, çekilmedi" ise `c` ile boşa alınır.
  Future<void> _finishCycle(String? verdict, StepResult? result) async {
    if (_cycleFinishing) return;
    _cycleFinishing = true;
    _cycleTimer?.cancel();
    _cycleTimer = null;
    _cycleClock.stop();
    final deviceId = _deviceId;
    final port = _cyclePort;
    final report = ref.read(testReportProvider);
    if (deviceId != null &&
        port != null &&
        _cycleClosed == null &&
        (_cycleStatus == TrayLockStatus.unlocked || _cycleStatus == TrayLockStatus.pushed)) {
      // Açık kalan (s:01) ya da itilip kapatılmamış (s:03) port c ile kapatılır.
      final (raw, res) = await _tray(deviceId, TrayLockAction.cancel, port: port);
      report.add(
        'Çek/say/it — ${_cycleStatus == TrayLockStatus.pushed ? 'Port kapat' : 'Açmayı iptal'} (c) · port $port',
        res is TrayLockOk ? StepResult.ok : StepResult.info,
        detail: '${raw ?? '(cevap yok)'} → ${_Reading.of(res, port: port).title}',
      );
    }

    final pulledSeen = _cycleStage == _CycleStage.pulled || (_cycleStage == _CycleStage.done && !_cyclePullMissed);
    final returned =
        _cyclePushedSeen || (_cycleStage == _CycleStage.pulled && _cycleStatus == TrayLockStatus.idle);
    final keypadOk = _cycleKeypadSeen.any((v) => v != 0);
    final String text;
    final StepResult outcome;
    if (verdict != null) {
      text = verdict;
      outcome = result ?? StepResult.fail;
    } else if (_cyclePullMissed || !pulledSeen) {
      text =
          'Kart çekmeyi algılamadı (durum ${_cycleStatus == null ? '—' : _statusCode(_cycleStatus!)}\'de kaldı). '
          'LED ve +/- yalnızca çekildi (s:02) durumunda çalıştığı için yanmamaları bundan. Avadanlık '
          'algılama sensörü ve bağlantısı kontrol edilmeli.';
      outcome = StepResult.fail;
    } else {
      final problems = [
        if (_cycleLed == false) 'kart çekmeyi gördüğü hâlde port LED\'i yanmadı (LED / LED bağlantısı)',
        if (_cycleLed == null) 'LED sorusu cevaplanmadı',
        if (_cycleKeypadFailed || !keypadOk)
          'tuş değeri okunamadı (okunan: ${_cycleKeypadSeen.isEmpty ? '—' : _cycleKeypadSeen.join(' → ')}) — '
              '+/- tuş paneli / bağlantısı',
        if (!returned) 'yerine itme (s:03) görülmeden durduruldu',
        if (_cyclePushedSeen && _cycleClosed == false) 'itildikten sonra c ile port kapatılamadı (s:00 görülmedi)',
        if (returned && !_cyclePushedSeen) 'kart s:03 bildirmeden boşa döndü (eski firmware?)',
      ];
      text = problems.isEmpty
          ? 'Çekme, LED, tuş (${_cycleKeypadSeen.join(' → ')}), yerine itme (s:03) ve port kapatma (c → s:00) çalışıyor.'
          : 'Çekme algılandı; ${problems.join('; ')}.';
      outcome = problems.isEmpty ? StepResult.ok : StepResult.fail;
    }
    report.add('Çek / say / it testi bitti', outcome, detail: text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _cycleStage = _CycleStage.done;
      _cycleVerdict = text;
    });
  }

  /// Kartın bildirdiği durum ile fiziksel gözlemi birlikte yorumlar (#260).
  String _diagHint(String what, bool correct, String hint) {
    if (_diagSeenUnlocked) return hint;
    if (correct) {
      return 'Avadanlık açıldı ama kart açık durumu (s:01) bildirmedi — kartın durum bildirimi kontrol edilmeli.';
    }
    if (what == _observations[1].$1) {
      return 'Kart o komutunu kabul etti (okkk) ama açma durumuna hiç geçmedi (o sonrası hep s:00): kilit sürülmedi. '
          'Sorun kartta — firmware ya da kartın açma koşulu (ör. serum kapağı / avadanlık sensörü). Serum kapağı '
          'açıkken tekrar deneyin; değişmezse sonucu kart geliştiricisine iletin.';
    }
    return 'Kart açma durumuna geçmedi (o sonrası hep s:00). $hint';
  }

  Future<void> _observe(String what, bool correct, String observationHint) async {
    final port = _awaitingObservation;
    if (port == null) return;
    final hint = _diagnosing ? _diagHint(what, correct, observationHint) : observationHint;
    final report = ref.read(testReportProvider);
    report.add(
      'Gözlem: kart ${_deviceCtrl.text} · o port $port → $what',
      correct ? StepResult.ok : StepResult.fail,
      detail: [
        'Kart geneli son komut: ${_cardModeText()}',
        if (_diagnosing) 'Olası neden: $hint',
      ].join('\n'),
    );
    final diagnosing = _diagnosing;
    setState(() {
      _awaitingObservation = null;
      _diagnosing = false;
      if (diagnosing) _diagVerdict = hint;
    });
    if (!diagnosing) return;

    // Portu boşa al (teşhis kart durumunu açık bırakmasın).
    final deviceId = _deviceId;
    if (deviceId == null) return;
    setState(() => _busy = true);
    final (raw, res) = await _tray(deviceId, TrayLockAction.cancel, port: port);
    report.add(
      'Teşhis — Açmayı iptal (c) · port $port',
      res is TrayLockOk ? StepResult.ok : StepResult.info,
      detail: '${raw ?? '(cevap yok)'} → ${_Reading.of(res, port: port).title}',
    );
    report.add('Tek port teşhisi bitti', correct ? StepResult.ok : StepResult.fail, detail: '$what — $hint');
    if (!mounted) return;
    setState(() => _busy = false);
  }

  String _cardModeText() => switch (_cardMode) {
    'k' => 'tüm kilitler ENERJİLİ (k)',
    'x' => 'tüm kilitler SERBEST (x)',
    _ => 'bilinmiyor (bu oturumda k/x gönderilmedi)',
  };

  Future<void> _scanDevices() async {
    setState(() {
      _busy = true;
      _foundDevices = null;
    });
    final found = <int>[];
    for (var id = 1; id <= 16; id++) {
      final (_, res) = await _tray(id, TrayLockAction.status, port: 1, timeout: const Duration(milliseconds: 300));
      if (res is! TrayLockErrorResponse || res.failure != TrayLockFailure.noResponse) found.add(id);
      if (!mounted) return;
    }
    ref
        .read(testReportProvider)
        .add(
          'Kilit kartı ID taraması (1–16)',
          found.isEmpty ? StepResult.fail : StepResult.info,
          detail: 'Cevap veren kart ID\'leri: ${found.isEmpty ? '-' : found.join(', ')}',
        );
    setState(() {
      _busy = false;
      _foundDevices = found;
      if (found.isNotEmpty) _deviceCtrl.text = '${found.first}';
    });
  }

  Future<void> _queryAllPorts() async {
    final deviceId = _deviceId;
    if (deviceId == null) return showMessage(context, 'Kart ID 1–99 olmalı.', error: true);
    setState(() => _busy = true);
    final table = <int, (String?, TrayLockResponse)>{};
    for (var p = 1; p <= TrayLockProtocol.maxPort; p++) {
      table[p] = await _tray(deviceId, TrayLockAction.status, port: p);
      if (!mounted) return;
    }
    ref
        .read(testReportProvider)
        .add(
          'Kart $deviceId · tüm portların durumu',
          StepResult.info,
          detail: [
            'Kart geneli: ${_cardModeText()}',
            for (final e in table.entries)
              'Port ${e.key}: ${e.value.$1 ?? '(cevap yok)'} → ${_Reading.of(e.value.$2).title}',
          ].join('\n'),
        );
    setState(() {
      _busy = false;
      _portTable = table;
    });
  }

  void _toggleWatch() {
    if (_watch != null) {
      _watch?.cancel();
      setState(() => _watch = null);
      return;
    }
    final deviceId = _deviceId;
    if (deviceId == null) return;
    final port = _port;
    _watchPort = port;
    _watch = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_polling || !mounted) return;
      _polling = true;
      try {
        final (sRaw, s) = await _tray(deviceId, TrayLockAction.status, port: port);
        if (s is TrayLockStatusResponse && s.status == TrayLockStatus.pushed) {
          await _autoClosePort(deviceId, port, sRaw);
          if (!mounted) return;
          setState(() => _liveReading = _Reading.of(s, port: port));
          return;
        }
        final (_, t) = await _tray(deviceId, TrayLockAction.keypadValue, port: port);
        if (!mounted) return;
        setState(() {
          _liveReading = _Reading.of(s, port: port);
          _liveKeypad = t is TrayLockKeypadResponse ? t.value : null;
        });
      } finally {
        _polling = false;
      }
    });
    setState(() {});
  }

  // ── UI ─────────────────────────────────────────────────────────

  Widget _cyclePanel(TextStyle? titleStyle) {
    final stage = _cycleStage!;
    final status = _cycleStatus;
    final statusReading = status == null
        ? const _Reading(MedTone.neutral, 'Durum bekleniyor…')
        : _Reading(
            status == TrayLockStatus.pulled ? MedTone.success : MedTone.info,
            '${_statusCode(status)} — ${switch (status) {
              TrayLockStatus.unlocked => 'kilit açık, avadanlık çekilmedi',
              TrayLockStatus.pulled => 'avadanlık çekildi (LED ve +/- aktif olmalı)',
              TrayLockStatus.pushed => 'yerine itildi, port kapatılıyor (c)',
              TrayLockStatus.idle => 'boşta (port kapalı)',
            }}',
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Çek / say / it — port $_cyclePort${stage == _CycleStage.done ? '' : ' · $_cycleTime'}', style: titleStyle),
        _ReadingTile(label: 'Durum', reading: statusReading),
        _ReadingTile(
          label: 'Tuş değeri',
          reading: _Reading(
            _cycleKeypadSeen.any((v) => v != 0) ? MedTone.success : MedTone.neutral,
            _cycleKeypad == null ? '—' : '$_cycleKeypad',
            _cycleKeypadSeen.isEmpty ? null : 'Çekiliyken görülen: ${_cycleKeypadSeen.join(' → ')}',
          ),
        ),
        const SizedBox(height: 4),
        switch (stage) {
          _CycleStage.waitPull => Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('1) Port $_cyclePort avadanlığını ÇEKİN.'),
              ActionChip(label: const Text('Çektim, kart görmedi'), onPressed: _cyclePullNotSeen),
              ActionChip(label: const Text('Durdur'), onPressed: () => _finishCycle(null, null)),
            ],
          ),
          _CycleStage.pulled => Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('2) Port LED\'i yandı mı?'),
              ChoiceChip(label: const Text('Yandı'), selected: _cycleLed == true, onSelected: (_) => _cycleMarkLed(true)),
              ChoiceChip(
                label: const Text('Yanmadı'),
                selected: _cycleLed == false,
                onSelected: (_) => _cycleMarkLed(false),
              ),
              const Text('3) +/- tuşlarına basın (değer yukarıda canlı).'),
              ActionChip(
                label: const Text('Tuş değeri değişmedi'),
                onPressed: _cycleKeypadFailed ? null : _cycleMarkKeypadFailed,
              ),
              const Text('4) Avadanlığı yerine İTİN.'),
              ActionChip(label: const Text('Durdur'), onPressed: () => _finishCycle(null, null)),
            ],
          ),
          _CycleStage.done => _ReadingTile(
            label: 'Sonuç',
            reading: _Reading(
              _cycleVerdict != null && _cycleVerdict!.endsWith('çalışıyor.') ? MedTone.success : MedTone.error,
              _cycleVerdict ?? '',
            ),
          ),
        },
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));
    final free = connected && widget.idle && !_busy;
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    return SectionCard(
      title: '5. Avadanlık kilit kartı — elle komut',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Arıza teşhisi için ham komutlar. Kart ID = rafın kilit kartı, port = avadanlığın kart üzerindeki '
            'portu (en sağdan 1). Raf tanımına göre kilit testleri ve akış testi Serum sayfasındadır.',
          ),
          const SizedBox(height: 12),

          // ── Kart ve port ────────────────────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NumberField(label: 'Kart ID', controller: _deviceCtrl, width: 90),
              const Text('Port:'),
              DropdownButton<int>(
                value: _port,
                items: [for (var p = 1; p <= 8; p++) DropdownMenuItem(value: p, child: Text('$p'))],
                onChanged: free ? (v) => setState(() => _port = v ?? _port) : null,
              ),
              BusyButton(
                label: 'Kart ID bul (1–16)',
                icon: Icons.search,
                busy: _busy && _foundDevices == null,
                onPressed: free ? _scanDevices : null,
              ),
              if (_foundDevices != null)
                Text('Bulunan: ${_foundDevices!.isEmpty ? '-' : _foundDevices!.join(', ')}'),
            ],
          ),
          const SizedBox(height: 8),
          _ReadingTile(
            label: 'Kart geneli',
            reading: _Reading(
              switch (_cardMode) {
                'k' => MedTone.warning,
                'x' => MedTone.success,
                _ => MedTone.neutral,
              },
              _cardModeText(),
              'Kartın `s` cevabı bunu göstermez; son başarılı k / x komutundan izlenir.',
            ),
          ),

          // ── Elle komut ─────────────────────────────────────────
          const SizedBox(height: 16),
          Text('Elle komut', style: titleStyle),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final action in TrayLockAction.values)
                OutlinedButton(onPressed: free ? () => _manual(action) : null, child: Text(_actionLabel(action))),
              FilledButton.icon(
                onPressed: free ? _diagnosePort : null,
                icon: const Icon(Icons.troubleshoot),
                label: Text('Tek port teşhisi (port $_port)'),
              ),
              FilledButton.icon(
                onPressed: free ? _startCycle : null,
                icon: const Icon(Icons.swap_vert),
                label: Text('Çek / say / it testi (port $_port)'),
              ),
              OutlinedButton.icon(
                onPressed: free ? _queryAllPorts : null,
                icon: const Icon(Icons.table_rows),
                label: const Text('Tüm portları sorgula (1–8)'),
              ),
              OutlinedButton.icon(
                onPressed: connected && _deviceId != null ? _toggleWatch : null,
                icon: Icon(_watch != null ? Icons.visibility_off : Icons.visibility),
                label: Text(_watch != null ? 'İzlemeyi durdur' : 'Canlı durum (0,5 sn)'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tek port teşhisi: k (tümünü kilitle) → durum → o (portu aç) → 3 sn boyunca durum. Serum kapağı açıkken '
            'çalıştırın. Sonra avadanlıkları elle deneyip ne olduğunu işaretleyin; yorum rapora yazılır ve port c '
            'ile boşa alınır.',
            style: TextStyle(fontSize: 12, color: MedColors.text2),
          ),
          Text(
            'Çek / say / it testi: k → o, sonra durum ve tuş değeri canlı izlenir. Port LED\'i ve +/- tuşu yalnızca '
            'avadanlık çekildiğinde (s:02) çalışır.',
            style: TextStyle(fontSize: 12, color: MedColors.text2),
          ),
          if (_cycleStage != null) _cyclePanel(titleStyle),
          if (_diagSteps != null) ...[
            const SizedBox(height: 8),
            Text('Tek port teşhisi', style: titleStyle),
            for (final (label, raw, reading) in _diagSteps!) _ReadingTile(label: label, reading: reading, raw: raw),
            if (_diagVerdict != null)
              _ReadingTile(
                label: 'Yorum',
                reading: _Reading(
                  _diagVerdict == _observations.first.$3 ? MedTone.success : MedTone.error,
                  _diagVerdict!,
                ),
              ),
          ],
          if (_lastReading != null && _diagSteps == null)
            _ReadingTile(label: _lastLabel, reading: _lastReading!, raw: _lastRaw),
          if (_awaitingObservation != null) ...[
            const SizedBox(height: 8),
            if (!_diagnosing && _cardMode != 'k')
              _ReadingTile(
                reading: const _Reading(
                  MedTone.warning,
                  'Kilitler k ile enerjilenmeden o gönderildi',
                  'Kilitler zaten serbestken o tek port açmayı ölçmez. "Tek port teşhisi"ni kullanın.',
                ),
              ),
            Text('Port $_awaitingObservation açıldı. Avadanlıkları elle deneyin — fiziksel olarak ne oldu?'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (label, correct, hint) in _observations)
                  ActionChip(label: Text(label), onPressed: () => _observe(label, correct, hint)),
              ],
            ),
          ],
          if (_watch != null && _liveReading != null)
            _ReadingTile(
              label: 'Canlı${_liveKeypad != null ? ' · tuş $_liveKeypad' : ''}',
              reading: _liveReading!,
            ),
          if (_portTable != null) ...[
            const SizedBox(height: 10),
            Text('Port durumları (kart ${_deviceCtrl.text})', style: titleStyle),
            for (final e in _portTable!.entries)
              _ReadingTile(reading: _Reading.of(e.value.$2, port: e.key), raw: e.value.$1 ?? '(cevap yok)'),
          ],
        ],
      ),
    );
  }
}
