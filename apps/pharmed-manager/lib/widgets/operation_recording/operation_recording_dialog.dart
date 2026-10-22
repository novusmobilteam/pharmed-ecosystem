// [SWREQ-MGR-CAM-001] [IEC 62304 §5.5]
// Kabin operasyonu kamera kaydı izleme dialog'u. operationId taşıyan her
// tablodan açılabilir (tutarsızlık hareketleri, istasyon hareketleri...).
//
// Düzen: solda koyu "sahne" (kamera seçici + video + özel kontrol çubuğu,
// zaman çizelgesinde olay işaretleri), sağda özet ve dikey olay akışı.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:pharmed_manager/core/core.dart';

import 'operation_recording_notifier.dart';

Future<void> showOperationRecordingDialog(BuildContext context, {required int operationId}) {
  final getRecording = context.read<GetOperationRecordingUseCase>();
  final getVideoSource = context.read<GetRecordingVideoSourceUseCase>();
  return showMedDialog<void>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => OperationRecordingNotifier(
        operationId: operationId,
        getRecording: getRecording,
        getVideoSource: getVideoSource,
      )..load(),
      child: const OperationRecordingDialog(),
    ),
  );
}

abstract final class _Stage {
  static const surface = Color(0xFF131C2E);
  static const surface2 = Color(0xFF1B2539);
  static const border = Color(0xFF263149);
  static const track = Color(0xFF2A3650);
  static const text = Color(0xFFE6ECF5);
  static const text2 = Color(0xFF94A3BB);
}

class OperationRecordingDialog extends StatelessWidget {
  const OperationRecordingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<OperationRecordingNotifier>();
    final l10n = context.l10n;
    final detail = notifier.detail;

    return MedDialog(
      title: l10n.operationRecording_dialogTitle,
      subtitle: detail == null
          ? null
          : l10n.operationRecording_dialogSubtitle(
              detail.type?.label(context) ?? '-',
              detail.startedAt == null ? '-' : DateFormat('dd.MM.yyyy HH:mm:ss').format(detail.startedAt!),
            ),
      icon: PhosphorIcons.videoCamera(PhosphorIconsStyle.fill),
      width: 1160,
      padded: false,
      child: SizedBox(height: 640, child: _body(context, notifier)),
    );
  }

  Widget _body(BuildContext context, OperationRecordingNotifier notifier) {
    final l10n = context.l10n;
    if (notifier.isFetching) return const Center(child: CircularProgressIndicator());
    if (notifier.hasLoadError) {
      return _StateMessage(
        icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.duotone),
        color: MedColors.red,
        title: l10n.operationRecording_loadErrorMessage,
        action: MedButton(label: l10n.common_retryButton, onPressed: notifier.load),
      );
    }
    final detail = notifier.detail;
    if (detail == null) {
      return _StateMessage(
        icon: PhosphorIcons.videoCameraSlash(PhosphorIconsStyle.duotone),
        color: MedColors.text3,
        title: l10n.operationRecording_notFoundTitle,
        description: l10n.operationRecording_notFoundDescription,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _StageView(notifier: notifier, detail: detail),
        ),
        SizedBox(
          width: 340,
          child: _SidePanel(notifier: notifier, detail: detail),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sahne
// ═══════════════════════════════════════════════════════════════════════════

class _StageView extends StatelessWidget {
  const _StageView({required this.notifier, required this.detail});

  final OperationRecordingNotifier notifier;
  final OperationRecordingDetail detail;

  @override
  Widget build(BuildContext context) {
    final camera = notifier.selectedCamera;
    final playable = camera?.isPlayable ?? false;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CameraBar(notifier: notifier, cameras: detail.cameras),
          Spacer(),
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: MedRadius.lgAll,
                  border: Border.all(color: _Stage.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: _videoArea(context, camera),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          if (playable) _ControlBar(notifier: notifier, markers: detail.markers, cameraId: camera!.cameraId),
        ],
      ),
    );
  }

  Widget _videoArea(BuildContext context, RecordedCamera? camera) {
    final l10n = context.l10n;
    if (camera == null) {
      return _StageMessage(icon: PhosphorIcons.videoCameraSlash(), text: l10n.operationRecording_status_unavailable);
    }
    if (!camera.isPlayable) {
      final (icon, text, color) = switch (camera.status) {
        RecordedVideoStatus.pending => (
          PhosphorIcons.cloudArrowUp(),
          l10n.operationRecording_status_pending,
          MedColors.ledAmber,
        ),
        RecordedVideoStatus.purged => (PhosphorIcons.trash(), l10n.operationRecording_status_purged, _Stage.text2),
        _ => (PhosphorIcons.videoCameraSlash(), l10n.operationRecording_status_unavailable, _Stage.text2),
      };
      return _StageMessage(
        icon: icon,
        color: color,
        text: text,
        detail: camera.failure == null ? null : l10n.operationRecording_cameraFailedMessage(camera.failure!.name),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        // Tıklayınca oynat/duraklat — masaüstü oynatıcı alışkanlığı.
        GestureDetector(
          onTap: notifier.togglePlay,
          child: Video(controller: notifier.videoController, controls: NoVideoControls, fill: Colors.transparent),
        ),
        if (notifier.playbackFailed)
          _StageMessage(
            icon: PhosphorIcons.warningCircle(),
            color: MedColors.ledRed,
            text: l10n.operationRecording_playbackErrorMessage,
          ),
      ],
    );
  }
}

class _CameraBar extends StatelessWidget {
  const _CameraBar({required this.notifier, required this.cameras});

  final OperationRecordingNotifier notifier;
  final List<RecordedCamera> cameras;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cameras.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final camera = cameras[i];
          final selected = camera.cameraId == notifier.selectedCameraId;
          return _CameraPill(camera: camera, selected: selected, onTap: () => notifier.selectCamera(camera.cameraId));
        },
      ),
    );
  }
}

class _CameraPill extends StatelessWidget {
  const _CameraPill({required this.camera, required this.selected, required this.onTap});

  final RecordedCamera camera;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dot = switch (camera.status) {
      RecordedVideoStatus.available => MedColors.ledGreen,
      RecordedVideoStatus.pending => MedColors.ledAmber,
      _ => _Stage.text2,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? MedColors.blue : _Stage.surface2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? MedColors.blue : _Stage.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: selected ? Colors.white : dot, shape: BoxShape.circle),
              ),
              Text(
                camera.cameraName,
                style: MedTextStyles.bodySm(color: selected ? Colors.white : _Stage.text, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({required this.notifier, required this.markers, required this.cameraId});

  final OperationRecordingNotifier notifier;
  final List<RecordedMarker> markers;
  final String cameraId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: _Stage.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: _Stage.border),
      ),
      child: StreamBuilder<Duration>(
        stream: notifier.positionStream,
        initialData: notifier.position,
        builder: (context, posSnap) => StreamBuilder<Duration>(
          stream: notifier.durationStream,
          initialData: notifier.duration,
          builder: (context, durSnap) {
            final position = posSnap.data ?? Duration.zero;
            final duration = durSnap.data ?? Duration.zero;
            return Row(
              spacing: 12,
              children: [
                StreamBuilder<bool>(
                  stream: notifier.playingStream,
                  initialData: notifier.isPlaying,
                  builder: (context, snap) {
                    final playing = snap.data ?? false;
                    return Tooltip(
                      message: playing ? l10n.operationRecording_pauseTooltip : l10n.operationRecording_playTooltip,
                      child: _RoundButton(
                        icon: playing
                            ? PhosphorIcons.pause(PhosphorIconsStyle.fill)
                            : PhosphorIcons.play(PhosphorIconsStyle.fill),
                        onTap: notifier.togglePlay,
                      ),
                    );
                  },
                ),
                Text('${_fmt(position)} / ${_fmt(duration)}', style: MedTextStyles.monoSm(color: _Stage.text)),
                Expanded(
                  child: _Timeline(
                    position: position,
                    duration: duration,
                    markers: [
                      for (final m in markers)
                        if (m.offsetFor(cameraId) case final o?) (offset: o, color: m.type.visual.$2, marker: m),
                    ],
                    onSeek: notifier.seek,
                    onMarkerTap: notifier.seekTo,
                  ),
                ),
                Tooltip(
                  message: l10n.operationRecording_speedTooltip,
                  child: InkWell(
                    onTap: notifier.cycleRate,
                    borderRadius: MedRadius.mdAll,
                    child: Container(
                      width: 52,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _Stage.surface2,
                        borderRadius: MedRadius.mdAll,
                        border: Border.all(color: _Stage.border),
                      ),
                      child: Text(
                        '${_rateLabel(notifier.rate)}×',
                        style: MedTextStyles.monoSm(color: _Stage.text, weight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _rateLabel(double r) => r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toString();
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MedColors.blue,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 18, color: Colors.white)),
      ),
    );
  }
}

typedef _TimelineMarker = ({Duration offset, Color color, RecordedMarker marker});

/// İlerleme çubuğu + üzerinde olay noktaları. Tıklama/sürükleme ile sarar,
/// noktaya tıklama olayın anına gider.
class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.position,
    required this.duration,
    required this.markers,
    required this.onSeek,
    required this.onMarkerTap,
  });

  final Duration position;
  final Duration duration;
  final List<_TimelineMarker> markers;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<RecordedMarker> onMarkerTap;

  static const _dot = 10.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final total = duration.inMilliseconds;
        double fx(Duration d) => total <= 0 ? 0 : (d.inMilliseconds / total).clamp(0.0, 1.0) * width;
        void seekAt(double dx) {
          if (total <= 0) return;
          onSeek(Duration(milliseconds: ((dx / width).clamp(0.0, 1.0) * total).round()));
        }

        final progress = fx(position);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => seekAt(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => seekAt(d.localPosition.dx),
          child: SizedBox(
            height: 30,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(color: _Stage.track, borderRadius: BorderRadius.circular(2)),
                ),
                Container(
                  width: progress,
                  height: 4,
                  decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(2)),
                ),
                for (final m in markers)
                  Positioned(
                    left: fx(m.offset) - _dot / 2,
                    child: GestureDetector(
                      onTap: () => onMarkerTap(m.marker),
                      child: Container(
                        width: _dot,
                        height: _dot,
                        decoration: BoxDecoration(
                          color: m.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: _Stage.surface, width: 2),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: progress - 7,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: MedColors.blue.withValues(alpha: 0.5), blurRadius: 8)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StageMessage extends StatelessWidget {
  const _StageMessage({required this.icon, required this.text, this.detail, this.color = _Stage.text2});

  final IconData icon;
  final String text;
  final String? detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: MedTextStyles.bodyMd(color: _Stage.text, weight: FontWeight.w500),
              ),
            ),
            if (detail != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _Stage.surface2, borderRadius: BorderRadius.circular(6)),
                child: Text(detail!, style: MedTextStyles.monoXs(color: _Stage.text2)),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Yan panel
// ═══════════════════════════════════════════════════════════════════════════

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.notifier, required this.detail});

  final OperationRecordingNotifier notifier;
  final OperationRecordingDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = detail.startedAt, end = detail.endedAt;
    final duration = start == null || end == null ? null : end.difference(start);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: MedColors.surface,
        border: Border(left: BorderSide(color: MedColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (detail.type != null)
                      _Pill(text: detail.type!.label(context), fg: MedColors.blue, bg: MedColors.blueLight),
                    if (detail.endReason case final reason?)
                      _Pill(text: reason.label(context), fg: reason.tone.$1, bg: reason.tone.$2, dot: true),
                  ],
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.3,
                  children: [
                    _Stat(
                      label: l10n.operationRecording_startedAtLabel,
                      value: start == null ? '-' : DateFormat('HH:mm:ss').format(start),
                    ),
                    _Stat(label: l10n.operationRecording_durationLabel, value: duration == null ? '-' : _fmt(duration)),
                    _Stat(label: l10n.operationRecording_camerasLabel, value: '${detail.cameras.length}'),
                    _Stat(label: l10n.operationRecording_eventCountLabel, value: '${detail.markers.length}'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      l10n.operationRecording_operationIdsLabel,
                      style: MedTextStyles.bodySm(color: MedColors.text3),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final id in detail.operationIds)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: MedColors.surface3,
                              borderRadius: MedRadius.smAll,
                              border: Border.all(color: MedColors.border2),
                            ),
                            child: Text('#$id', style: MedTextStyles.monoSm(color: MedColors.text2)),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: MedColors.border2),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              l10n.operationRecording_eventsTitle.toUpperCase(),
              style: MedTextStyles.monoXs(color: MedColors.text3).copyWith(letterSpacing: 1.2),
            ),
          ),
          Expanded(
            child: _EventFeed(notifier: notifier, markers: detail.markers),
          ),
        ],
      ),
    );
  }
}

class _EventFeed extends StatelessWidget {
  const _EventFeed({required this.notifier, required this.markers});

  final OperationRecordingNotifier notifier;
  final List<RecordedMarker> markers;

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) {
      return Center(
        child: Text(
          context.l10n.operationRecording_noEventsMessage,
          style: MedTextStyles.bodySm(color: MedColors.text3),
        ),
      );
    }
    final cameraId = notifier.selectedCameraId;
    final canSeek = notifier.selectedCamera?.isPlayable ?? false;

    return StreamBuilder<Duration>(
      stream: notifier.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data;
        int? active;
        if (canSeek && cameraId != null && position != null) {
          for (var i = 0; i < markers.length; i++) {
            final o = markers[i].offsetFor(cameraId);
            if (o != null && o <= position) active = i;
          }
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          itemCount: markers.length,
          itemBuilder: (context, i) {
            final marker = markers[i];
            final offset = cameraId == null ? null : marker.offsetFor(cameraId);
            return _EventTile(
              marker: marker,
              offset: offset,
              active: i == active,
              isFirst: i == 0,
              isLast: i == markers.length - 1,
              onTap: canSeek && offset != null ? () => notifier.seekTo(marker) : null,
            );
          },
        );
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.marker,
    required this.offset,
    required this.active,
    required this.isFirst,
    required this.isLast,
    this.onTap,
  });

  final RecordedMarker marker;
  final Duration? offset;
  final bool active;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = marker.type.visual;
    final enabled = onTap != null;
    final tone = enabled ? color : MedColors.text4;

    return Tooltip(
      message: enabled ? context.l10n.operationRecording_seekTooltip : '',
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.mdAll,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: active ? MedColors.blueLight : Colors.transparent,
            borderRadius: MedRadius.mdAll,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                // Dikey akış çizgisi + olay rozeti
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      Expanded(child: _connector(visible: !isFirst)),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: tone.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: active ? tone : tone.withValues(alpha: 0.25), width: 1.5),
                        ),
                        child: Icon(icon, size: 14, color: tone),
                      ),
                      Expanded(child: _connector(visible: !isLast)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 2,
                      children: [
                        Text(
                          marker.type.label(context),
                          style: MedTextStyles.bodySm(
                            color: enabled ? MedColors.text : MedColors.text3,
                            weight: active ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm:ss').format(marker.at),
                          style: MedTextStyles.monoXs(color: MedColors.text3),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: enabled ? (active ? MedColors.blue : MedColors.surface3) : MedColors.surface2,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      offset == null ? '—' : _fmt(offset!),
                      style: MedTextStyles.monoXs(
                        color: enabled ? (active ? Colors.white : MedColors.blue) : MedColors.text4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _connector({required bool visible}) =>
      Center(child: Container(width: 2, color: visible ? MedColors.border : Colors.transparent));
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.fg, required this.bg, this.dot = false});

  final String text;
  final Color fg;
  final Color bg;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (dot)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          Text(
            text,
            style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Text(
            label,
            style: MedTextStyles.bodySm(color: MedColors.text3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(value, style: MedTextStyles.numericMd(color: MedColors.text), maxLines: 1),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.color, required this.title, this.description, this.action});

  final IconData icon;
  final Color color;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 34, color: color),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: MedTextStyles.titleSm(color: MedColors.text),
            ),
            if (description != null)
              Text(
                description!,
                textAlign: TextAlign.center,
                style: MedTextStyles.bodySm(color: MedColors.text3),
              ),
            if (action != null) ...[const SizedBox(height: 4), action!],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Etiketler / yardımcılar
// ═══════════════════════════════════════════════════════════════════════════

String _fmt(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

extension on RecordedOperationType {
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      RecordedOperationType.refill => l10n.operationRecording_type_refill,
      RecordedOperationType.census => l10n.operationRecording_type_census,
      RecordedOperationType.intake => l10n.operationRecording_type_intake,
      RecordedOperationType.refund => l10n.operationRecording_type_refund,
      RecordedOperationType.waste => l10n.operationRecording_type_waste,
      RecordedOperationType.unload => l10n.operationRecording_type_unload,
    };
  }
}

extension on OperationEndReason {
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      OperationEndReason.completed => l10n.operationRecording_endReason_completed,
      OperationEndReason.stoppedByUser => l10n.operationRecording_endReason_stoppedByUser,
      OperationEndReason.abortedAfterError => l10n.operationRecording_endReason_abortedAfterError,
      OperationEndReason.screenClosed => l10n.operationRecording_endReason_screenClosed,
      OperationEndReason.superseded => l10n.operationRecording_endReason_superseded,
      OperationEndReason.recovered => l10n.operationRecording_endReason_recovered,
    };
  }

  /// (yazı, zemin)
  (Color, Color) get tone => switch (this) {
    OperationEndReason.completed => (MedColors.green, MedColors.greenLight),
    OperationEndReason.abortedAfterError => (MedColors.red, MedColors.redLight),
    _ => (MedColors.amber, MedColors.amberLight),
  };
}

extension on RecordingMarkerType? {
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      RecordingMarkerType.drawerOpened => l10n.operationRecording_marker_drawerOpened,
      RecordingMarkerType.drawerClosed => l10n.operationRecording_marker_drawerClosed,
      RecordingMarkerType.drawerFailed => l10n.operationRecording_marker_drawerFailed,
      RecordingMarkerType.lidOpened => l10n.operationRecording_marker_lidOpened,
      RecordingMarkerType.lidClosed => l10n.operationRecording_marker_lidClosed,
      RecordingMarkerType.lidFailed => l10n.operationRecording_marker_lidFailed,
      RecordingMarkerType.recordingInterrupted => l10n.operationRecording_marker_recordingInterrupted,
      null => l10n.operationRecording_marker_unknown,
    };
  }

  (IconData, Color) get visual => switch (this) {
    RecordingMarkerType.drawerOpened => (PhosphorIcons.arrowLineDown(PhosphorIconsStyle.bold), MedColors.blue),
    RecordingMarkerType.lidOpened => (PhosphorIcons.arrowSquareOut(PhosphorIconsStyle.bold), MedColors.blue),
    RecordingMarkerType.drawerClosed ||
    RecordingMarkerType.lidClosed => (PhosphorIcons.check(PhosphorIconsStyle.bold), MedColors.green),
    RecordingMarkerType.drawerFailed ||
    RecordingMarkerType.lidFailed => (PhosphorIcons.warning(PhosphorIconsStyle.bold), MedColors.red),
    RecordingMarkerType.recordingInterrupted => (
      PhosphorIcons.videoCameraSlash(PhosphorIconsStyle.bold),
      MedColors.amber,
    ),
    null => (PhosphorIcons.circle(PhosphorIconsStyle.bold), MedColors.text3),
  };
}
