import { useState } from 'react';
import { api, type GroupStatus, type LogGroup } from '../api';
import { BarList, StackedBars } from '../components/charts';
import { DiagnosisCard } from '../components/DiagnosisCard';
import { LogDetail } from '../components/LogDetail';
import { LogTable } from '../components/LogTable';
import { Empty, ErrorBox, LevelTag, Loading, Panel, StatusTag } from '../components/ui';
import { diagnoseGroup } from '../diagnosis';
import { fmtAgo, fmtCount, fmtDateTime, rangeBounds } from '../format';
import { useAsync, useNow } from '../hooks';
import { href, updateParams, type Route } from '../router';

export function IssueDetail({ route, fingerprint }: { route: Route; fingerprint: string }) {
  const now = useNow();
  const selected = route.params.get('sel') ?? undefined;
  const [nonce, setNonce] = useState(0);
  const week = rangeBounds('7d');

  const group = useAsync(() => api.getGroup(fingerprint), [fingerprint, nonce]);
  const sample = useAsync(
    () => (group.data ? api.getLog(group.data.sampleEntryId) : Promise.resolve(undefined)),
    [group.data?.sampleEntryId],
  );
  const extra = useAsync(async () => {
    const q = { ...week, fingerprint };
    const [timeline, devices, users, sampleSet] = await Promise.all([
      api.groupTimeline(fingerprint, week.from, week.to, '6h'),
      api.top(q, 'device', 6),
      api.top(q, 'user', 6),
      api.listLogs({ ...q, take: 200 }),
    ]);
    // Sürüm ve ekran dağılımı son 200 tekrardan çıkarılır.
    const countBy = (key: (e: (typeof sampleSet.items)[number]) => string) => {
      const m = new Map<string, number>();
      for (const e of sampleSet.items) m.set(key(e), (m.get(key(e)) ?? 0) + 1);
      return [...m.entries()].map(([k, count]) => ({ key: k, label: k, count })).sort((a, b) => b.count - a.count);
    };
    return {
      timeline,
      devices,
      users,
      versions: countBy((e) => e.appVersion ?? '?'),
      screens: countBy((e) => e.session?.screen ?? '—'),
      recent: sampleSet.items.slice(0, 10),
    };
  }, [fingerprint, nonce]);

  if (group.error) return <ErrorBox message={group.error} onRetry={group.reload} />;
  if (!group.data) return <Loading />;
  const g = group.data;
  const d = diagnoseGroup(g, sample.data);

  return (
    <div className={`with-detail${selected ? ' has-detail' : ''}`}>
      <div className="with-detail-main">
        <a className="back" href={href('/issues', { range: route.params.get('range') ?? undefined })}>
          Sorunlara dön
        </a>
        <header className="issue-head">
          <div className="issue-head-title">
            <LevelTag level={g.level} />
            <StatusTag status={g.status} regressed={g.regressed} />
          </div>
          <h1>{g.title}</h1>
          <div className="issue-sub">
            {g.rule && <code className="chip">{g.rule}</code>}
            {g.httpPath && (
              <code className="chip chip-muted">
                {g.httpMethod} {g.httpPath}
              </code>
            )}
            {g.errorType && <code className="chip chip-muted">{g.errorType}</code>}
            <code className="chip chip-muted">{g.unit}</code>
          </div>
        </header>

        <StatusBar group={g} onChanged={() => setNonce((n) => n + 1)} />

        <div className="issue-layout">
          <div>
            <DiagnosisCard d={d} />
            <Panel title="Son 7 gün">
              {extra.data ? <StackedBars buckets={extra.data.timeline} levels={[g.level]} height={96} /> : <Loading />}
            </Panel>
            <Panel
              title="Son tekrarlar"
              action={
                <a className="link" href={href('/logs', { fp: fingerprint, range: '7d' })}>
                  Loglarda aç
                </a>
              }
            >
              {extra.data?.recent.length ? (
                <LogTable items={extra.data.recent} selectedId={selected} onSelect={(e) => updateParams(route, { sel: e.id })} />
              ) : extra.loading ? (
                <Loading />
              ) : (
                <Empty title="Son 7 günde tekrar yok." />
              )}
            </Panel>
          </div>
          <aside className="issue-side">
            <dl className="stats">
              <div>
                <dt>Toplam</dt>
                <dd>{fmtCount(g.totalCount)}</dd>
              </div>
              <div>
                <dt>Kiosk</dt>
                <dd>{g.deviceCount}</dd>
              </div>
              <div>
                <dt>Kullanıcı</dt>
                <dd>{g.userCount}</dd>
              </div>
              <div>
                <dt>İstasyon</dt>
                <dd>{g.stationCount}</dd>
              </div>
            </dl>
            <dl className="facts">
              <dt>İlk görülme</dt>
              <dd>
                {fmtDateTime(g.firstSeen)} <span className="muted">· {g.firstSeenVersion}</span>
              </dd>
              <dt>Son görülme</dt>
              <dd>
                {fmtAgo(g.lastSeen, now)} <span className="muted">· {g.lastSeenVersion}</span>
              </dd>
            </dl>
            {extra.data && (
              <>
                <h3 className="side-h">Sürümler</h3>
                <BarList items={extra.data.versions} onPick={(v) => (window.location.hash = href('/logs', { fp: fingerprint, version: v, range: '7d' }))} />
                <h3 className="side-h">Kiosklar</h3>
                <BarList items={extra.data.devices} onPick={(v) => (window.location.hash = href('/logs', { fp: fingerprint, device: v, range: '7d' }))} />
                <h3 className="side-h">Kullanıcılar</h3>
                <BarList items={extra.data.users} onPick={(v) => (window.location.hash = href('/logs', { fp: fingerprint, user: v, range: '7d' }))} />
                <h3 className="side-h">Ekranlar</h3>
                <BarList items={extra.data.screens} />
              </>
            )}
          </aside>
        </div>
      </div>
      {selected && <LogDetail id={selected} onClose={() => updateParams(route, { sel: undefined })} />}
    </div>
  );
}

function StatusBar({ group: g, onChanged }: { group: LogGroup; onChanged: () => void }) {
  const [editing, setEditing] = useState<GroupStatus | null>(null);
  const [note, setNote] = useState(g.note ?? '');
  const [version, setVersion] = useState(g.resolvedInVersion ?? '');
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string>();

  async function save(status: GroupStatus) {
    setBusy(true);
    setErr(undefined);
    try {
      await api.setGroupStatus(g.fingerprint, {
        status,
        note: note.trim() || undefined,
        resolvedInVersion: status === 'resolved' ? version.trim() || undefined : undefined,
      });
      setEditing(null);
      onChanged();
    } catch (e) {
      setErr(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <section className="statusbar">
      {g.note && !editing && (
        <p className="statusbar-note">
          <strong>{g.statusChangedBy ?? 'Not'}:</strong> {g.note}
          {g.resolvedInVersion && <span className="muted"> · {g.resolvedInVersion} sürümünde çözüldü</span>}
          {g.statusChangedAt && <span className="muted"> · {fmtDateTime(g.statusChangedAt)}</span>}
        </p>
      )}
      {g.regressed && !editing && (
        <p className="statusbar-warn">Çözüldü olarak işaretlenmişti, sonra yeniden görüldü. Çözüm tam değil ya da başka bir sebepten tekrar ediyor.</p>
      )}
      {!editing ? (
        <div className="statusbar-actions">
          {g.status !== 'resolved' && (
            <button className="btn btn-primary" onClick={() => setEditing('resolved')}>
              Çözüldü olarak işaretle
            </button>
          )}
          {g.status !== 'ignored' && (
            <button className="btn" onClick={() => setEditing('ignored')}>
              Yok say
            </button>
          )}
          {g.status !== 'open' && (
            <button className="btn" onClick={() => save('open')} disabled={busy}>
              Yeniden aç
            </button>
          )}
        </div>
      ) : (
        <form
          className="statusbar-form"
          onSubmit={(e) => {
            e.preventDefault();
            save(editing);
          }}
        >
          <label>
            Not
            <textarea value={note} onChange={(e) => setNote(e.target.value)} rows={2} placeholder="Ne yapıldı? Örn. #94 ile sınır kontrolü eklendi." />
          </label>
          {editing === 'resolved' && (
            <label>
              Düzeltildiği sürüm (isteğe bağlı)
              <input value={version} onChange={(e) => setVersion(e.target.value)} placeholder="0.4.2+15" />
              <small>Verilirse yalnızca bu sürüm ve sonrasından gelen kayıtlar sorunu yeniden açar; eski sürümdeki kiosklar açmaz.</small>
            </label>
          )}
          {err && <p className="statusbar-warn">{err}</p>}
          <div className="statusbar-actions">
            <button className="btn btn-primary" type="submit" disabled={busy}>
              {editing === 'resolved' ? 'Çözüldü olarak kaydet' : 'Yok sayılan olarak kaydet'}
            </button>
            <button className="btn btn-ghost" type="button" onClick={() => setEditing(null)}>
              Vazgeç
            </button>
          </div>
        </form>
      )}
    </section>
  );
}
