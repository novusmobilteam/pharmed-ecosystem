import { KIND_LABEL, type Diagnosis } from '../diagnosis';

/** Panelin "çözüm odaklı" kısmı: ne oldu, neden olmuş olabilir, neye bakmalı. */
export function DiagnosisCard({ d }: { d: Diagnosis }) {
  return (
    <section className={`diagnosis diagnosis-${d.kind}`} aria-label="Teşhis">
      <div className="diagnosis-kind">{KIND_LABEL[d.kind]}</div>
      <p className="diagnosis-what">{d.what}</p>
      {d.facts.length > 0 && (
        <ul className="diagnosis-facts">
          {d.facts.map((f) => (
            <li key={f}>{f}</li>
          ))}
        </ul>
      )}
      <dl>
        <dt>Muhtemel sebep</dt>
        <dd>{d.cause}</dd>
        <dt>Kontrol edin</dt>
        <dd>
          <ol>
            {d.checks.map((c) => (
              <li key={c}>{c}</li>
            ))}
          </ol>
        </dd>
      </dl>
    </section>
  );
}
