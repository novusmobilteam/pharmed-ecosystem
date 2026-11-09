// Sahte veri katmanı — backend hazır olana kadar panel bununla çalışır.
// Sözleşmedeki endpoint'lerin davranışını bellekte taklit eder ve gerçek
// pharmed-client loglarına benzeyen senaryolar üretir (alım check hataları,
// kural redleri, ağ kopması, yavaş yanıt, yakalanmamış hata…). Canlı izlemeyi
// denemek için birkaç saniyede bir yeni kayıt ekler.

import { fingerprintOf, normalizePath } from './fingerprint';
import type {
  Bucket,
  Device,
  Facets,
  GroupQuery,
  GroupStatus,
  LogApi,
  LogEntry,
  LogGroup,
  LogQuery,
  Page,
  SlowItem,
  StatusChange,
  TopDimension,
  TopItem,
} from './types';

// ── Sabit dünya ──────────────────────────────────────────────────────────

const STATIONS = [
  { id: 3, name: 'Dahiliye 2. Kat', serviceId: 7 },
  { id: 5, name: 'Acil Servis', serviceId: 2 },
  { id: 8, name: 'Yoğun Bakım', serviceId: 11 },
];

interface SimDevice {
  deviceId: string;
  hostName: string;
  stationId: number;
  appVersion: string;
  /** Bu kadar dakikadır log göndermiyor (sessiz kiosk). */
  silentForMin?: number;
}

const DEVICES: SimDevice[] = [
  { deviceId: '6f1c2a90-3b1e-4c8e-9a51-0f2d9b7e4c11', hostName: 'KIOSK-DAHILIYE-1', stationId: 3, appVersion: '0.4.1+14' },
  { deviceId: '1a7e4b22-9c0d-4f35-8e61-2b3c4d5e6f70', hostName: 'KIOSK-DAHILIYE-2', stationId: 3, appVersion: '0.4.0+12' },
  { deviceId: '9b2d6e14-5a8f-4c71-b3e2-7f1a0c9d8e45', hostName: 'KIOSK-ACIL-1', stationId: 5, appVersion: '0.4.1+14' },
  { deviceId: '3c8f1d07-2e6b-4a94-9d15-c0b7a6e5f412', hostName: 'KIOSK-ACIL-2', stationId: 5, appVersion: '0.4.1+14' },
  { deviceId: 'e4a90b36-7d21-4e8c-a5f3-1b9c2d0e7f68', hostName: 'KIOSK-YOGUNBAKIM-1', stationId: 8, appVersion: '0.3.9+10' },
  {
    deviceId: '5d3e7c81-0f4a-4b29-8c6d-e2f1a3b4c597',
    hostName: 'KIOSK-YOGUNBAKIM-2',
    stationId: 8,
    appVersion: '0.4.1+14',
    silentForMin: 190,
  },
];

const USERS = [
  { id: 14, name: 'Ayşe Yılmaz', stations: [3] },
  { id: 21, name: 'Mehmet Demir', stations: [3, 8] },
  { id: 9, name: 'Zeynep Kaya', stations: [5] },
  { id: 33, name: 'Can Öztürk', stations: [5] },
  { id: 27, name: 'Elif Şahin', stations: [8] },
  { id: 18, name: 'Burak Aydın', stations: [8, 5] },
];

// ── Rastgelelik (tekrarlanabilir) ────────────────────────────────────────

function mulberry32(seed: number) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

let rand = mulberry32(20261109);
const pick = <T,>(arr: T[]): T => arr[Math.floor(rand() * arr.length)];
const between = (min: number, max: number) => Math.round(min + rand() * (max - min));

function uuid(): string {
  const hex = () => Math.floor(rand() * 16).toString(16);
  const part = (n: number) => Array.from({ length: n }, hex).join('');
  return `${part(8)}-${part(4)}-4${part(3)}-${'89ab'[Math.floor(rand() * 4)]}${part(3)}-${part(12)}`;
}

const MIN = 60_000;
const HOUR = 60 * MIN;
const DAY = 24 * HOUR;

// ── Senaryolar ───────────────────────────────────────────────────────────

interface RunCtx {
  device: SimDevice;
  appRunId: string;
  user: (typeof USERS)[number];
  reqSeq: number;
  t: number;
}

type Draft = Omit<LogEntry, 'id' | 'deviceId' | 'appRunId' | 'appVersion' | 'timestamp' | 'session' | 'receivedAt'> & {
  dt?: number;
  noSession?: boolean;
  screen?: string;
};

function nextReq(c: RunCtx) {
  c.reqSeq += 1;
  return `r${c.reqSeq}`;
}

function fmtTime(ms: number) {
  const d = new Date(ms);
  const p = (n: number, l = 2) => String(n).padStart(l, '0');
  return `${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}.${p(d.getMilliseconds(), 3)}`;
}

/** Bir hatadan önceki "önceki adımlar" — başarılı GET'ler ve ekran verisi yüklemeleri. */
function breadcrumbs(c: RunCtx, paths: string[]): string[] {
  let t = c.t - between(4000, 9000);
  const lines: string[] = [];
  for (const path of paths) {
    const req = nextReq(c);
    lines.push(`${fmtTime(t)} → GET ${path} {"req":"${req}"}`);
    t += between(40, 400);
    lines.push(`${fmtTime(t)} ← GET ${path} {"req":"${req}","status":200,"ms":${between(40, 600)}}`);
    t += between(300, 1500);
  }
  return lines;
}

const INTAKE_PATHS = [
  '/Prescription/detail/patient/55',
  '/CabinAssignment/station',
  '/Hospitalization/service/7',
];

function scenarioLogin(): Draft[] {
  return [
    { level: 'INFO', unit: 'SW-UNIT-UI', swreq: 'SWREQ-CORE-LOG-003', message: 'Oturum açıldı', screen: 'dashboard' },
    { level: 'INFO', unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-NAV-001', message: 'Ekran: dashboard', dt: 400, screen: 'dashboard' },
  ];
}

function intakeStart(items: number): Draft {
  return {
    level: 'INFO',
    unit: 'SW-UNIT-UI',
    swreq: 'SWREQ-CLI-MINTAKE-006',
    message: 'Alım başlatıldı',
    screen: 'drug-intake',
    context: {
      type: 'ordered',
      hospitalizationId: between(400, 900),
      items: Array.from({ length: items }, () => ({
        itemId: between(700, 999),
        medicineId: between(10, 300),
        assignmentId: between(1000, 1400),
        stockId: between(400, 480),
        dose: pick([1, 1, 2, 0.5]),
      })),
    },
    dt: 2000,
  };
}

function scenarioIntakeOk(c: RunCtx): Draft[] {
  const r1 = nextReq(c);
  const r2 = nextReq(c);
  const ms = between(120, 900);
  return [
    { level: 'INFO', unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-NAV-001', message: 'Ekran: drug-intake', screen: 'drug-intake' },
    intakeStart(between(1, 3)),
    {
      level: 'INFO',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '→ POST /Prescription/detail/checkCollect',
      req: r1,
      http: { method: 'POST', path: '/Prescription/detail/checkCollect' },
      context: { req: r1, body: '{"type":0,"prescriptionDetailId":812,"details":[{"stockId":412,"dosePiece":1}],"userId":14}' },
      screen: 'drug-intake',
      dt: 300,
    },
    {
      level: 'INFO',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '← POST /Prescription/detail/checkCollect',
      req: r1,
      http: { method: 'POST', path: '/Prescription/detail/checkCollect', status: 200, ms },
      context: { req: r1, status: 200, ms },
      screen: 'drug-intake',
      dt: ms,
    },
    {
      level: 'INFO',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '→ POST /Prescription/detail/collect',
      req: r2,
      http: { method: 'POST', path: '/Prescription/detail/collect' },
      context: { req: r2, body: '{"prescriptionDetailId":812,"details":[{"stockId":412,"dosePiece":1,"censusQuantity":3}]}' },
      screen: 'drug-intake',
      dt: between(20000, 60000),
    },
    {
      level: 'INFO',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '← POST /Prescription/detail/collect',
      req: r2,
      http: { method: 'POST', path: '/Prescription/detail/collect', status: 200, ms: between(150, 800) },
      context: { req: r2, status: 200, operationId: between(30000, 40000) },
      screen: 'drug-intake',
      dt: 400,
    },
  ];
}

function scenarioIntakeCheckRejected(c: RunCtx): Draft[] {
  const crumbs = breadcrumbs(c, INTAKE_PATHS);
  const r = nextReq(c);
  const stockId = pick([412, 415, 431]);
  const response = pick([
    `{"statusCode":400,"isSuccess":false,"message":"Stok kaydı bulunamadı (stockId: ${stockId})"}`,
    `{"statusCode":400,"isSuccess":false,"message":"Seçilen gözde yeterli stok yok. İstenen: 2, mevcut: 1"}`,
  ]);
  const message = JSON.parse(response).message as string;
  const body = `{"type":0,"prescriptionDetailId":812,"hospitalizationId":611,"details":[{"stockId":${stockId},"dosePiece":2}],"userId":${c.user.id}}`;
  return [
    { level: 'INFO', unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-NAV-001', message: 'Ekran: drug-intake', screen: 'drug-intake' },
    intakeStart(1),
    {
      level: 'INFO',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '→ POST /Prescription/detail/checkCollect',
      req: r,
      http: { method: 'POST', path: '/Prescription/detail/checkCollect' },
      context: { req: r, body },
      screen: 'drug-intake',
      dt: 300,
    },
    {
      level: 'ERROR',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '✕ POST /Prescription/detail/checkCollect (badResponse)',
      req: r,
      errorType: 'ServiceException',
      http: { method: 'POST', path: '/Prescription/detail/checkCollect', status: 400, ms: between(90, 400) },
      context: { req: r, status: 400, response, dioMessage: 'This exception was thrown because the response has a status code of 400.' },
      breadcrumbs: crumbs,
      screen: 'drug-intake',
      dt: 250,
    },
    {
      level: 'WARN',
      unit: 'SW-UNIT-INTAKE',
      swreq: 'SWREQ-DATA-INTAKE-002',
      message: 'Alım check servisi kalemi reddetti',
      errorType: 'ServiceException',
      context: {
        type: 'ordered',
        prescriptionDetailId: 812,
        hospitalizationId: 611,
        dose: 2,
        resolvedStockId: stockId,
        resolvedStockQty: 1,
        assignmentId: 1203,
        assignmentStocks: [`${stockId}:1`, '418:4'],
        plan: [`${stockId}:2`],
        errorType: 'ServiceException',
        message,
        statusCode: 400,
      },
      screen: 'drug-intake',
      dt: 5,
    },
    {
      level: 'WARN',
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-MIXIN-001',
      message: 'MasterIntakeSelectionNotifier.start-intake → failed',
      rule: 'INTAKE_CHECK_FAILED',
      context: { message: 'Bazı kalemler kontrolden geçemedi', rule: 'INTAKE_CHECK_FAILED', failedItems: { '812': message } },
      screen: 'drug-intake',
      dt: 10,
    },
  ];
}

function scenarioIntakePlanInsufficient(c: RunCtx): Draft[] {
  return [
    { level: 'INFO', unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-NAV-001', message: 'Ekran: drug-intake', screen: 'drug-intake' },
    intakeStart(1),
    {
      level: 'WARN',
      unit: 'SW-UNIT-INTAKE',
      swreq: 'SWREQ-DATA-INTAKE-002',
      message: 'Kural reddi: INTAKE_PLAN_INSUFFICIENT — Alım planı istenen miktarı karşılamıyor, check gönderilmedi',
      rule: 'INTAKE_PLAN_INSUFFICIENT',
      context: {
        rule: 'INTAKE_PLAN_INSUFFICIENT',
        type: pick(['orderless', 'free']),
        prescriptionDetailId: between(700, 999),
        dose: 2,
        resolvedStockId: null,
        assignmentId: 1188,
        assignmentStocks: ['402:1', '403:0'],
        planned: 1,
        plan: ['402:1'],
      },
      breadcrumbs: breadcrumbs(c, ['/CabinAssignment/station', '/Medicine/orderless']),
      screen: 'drug-intake',
      dt: 400,
    },
    {
      level: 'WARN',
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-MIXIN-001',
      message: 'MasterIntakeSelectionNotifier.check-item-812 → failed',
      rule: 'INTAKE_ITEM_CHECK_FAILED',
      context: { message: 'Bu ilaç için kabinde yeterli stok yok', rule: 'INTAKE_ITEM_CHECK_FAILED', itemId: 812 },
      screen: 'drug-intake',
      dt: 5,
    },
  ];
}

function scenarioWitness(): Draft[] {
  return [
    intakeStart(2),
    {
      level: 'WARN',
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-CLI-MINTAKE-006',
      message: 'Kural reddi: INTAKE_WITNESS_REQUIRED — Şahit gerektiren kalemler için şahit seçilmedi',
      rule: 'INTAKE_WITNESS_REQUIRED',
      context: { rule: 'INTAKE_WITNESS_REQUIRED', itemIds: [between(700, 999)] },
      screen: 'drug-intake',
      dt: 200,
    },
  ];
}

function scenarioOverdue(): Draft[] {
  return [
    intakeStart(1),
    {
      level: 'WARN',
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-CLI-MINTAKE-006',
      message: 'Kural reddi: INTAKE_OVERDUE_DESCRIPTION_REQUIRED — Gecikmiş uygulama açıklaması girilmedi',
      rule: 'INTAKE_OVERDUE_DESCRIPTION_REQUIRED',
      context: { rule: 'INTAKE_OVERDUE_DESCRIPTION_REQUIRED', itemIds: [between(700, 999)] },
      screen: 'drug-intake',
      dt: 200,
    },
  ];
}

function scenarioMutationOk(c: RunCtx): Draft[] {
  const [screen, method, path, body] = pick([
    ['drug-refill', 'POST', '/FillingList/fiilingDetail/fill', '{"id":2231,"cabinDrawrId":88,"quantity":4,"miadDate":"2027-03-01"}'],
    ['drug-census', 'PUT', '/CabinDrawrStock/censusQuantity', '{"cabinDrawrStockId":412,"censusQuantity":6}'],
    ['drug-unload', 'POST', '/CabinDrawrStock/emptying', '{"cabinDrawrStockId":431,"quantity":2}'],
  ] as const);
  const r = nextReq(c);
  const ms = between(100, 1200);
  return [
    { level: 'INFO', unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-NAV-001', message: `Ekran: ${screen}`, screen },
    {
      level: 'INFO',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: `→ ${method} ${path}`,
      req: r,
      http: { method, path },
      context: { req: r, body },
      screen,
      dt: between(15000, 50000),
    },
    {
      level: 'INFO',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: `← ${method} ${path}`,
      req: r,
      http: { method, path, status: 200, ms },
      context: { req: r, status: 200, ms, operationId: between(30000, 40000) },
      screen,
      dt: ms,
    },
  ];
}

function scenarioRefund500(c: RunCtx): Draft[] {
  const r = nextReq(c);
  const id = between(800, 999);
  const path = `/Prescription/detail/${id}/refundDrawr`;
  return [
    { level: 'INFO', unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-NAV-001', message: 'Ekran: drug-refund', screen: 'drug-refund' },
    {
      level: 'INFO',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: `→ POST ${path}`,
      req: r,
      http: { method: 'POST', path },
      context: { req: r, body: `{"cabinDrawrId":91,"quantity":1,"qrCodes":["0108699…"]}` },
      screen: 'drug-refund',
      dt: 30000,
    },
    {
      level: 'ERROR',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: `✕ POST ${path} (badResponse)`,
      req: r,
      errorType: 'ServiceException',
      http: { method: 'POST', path, status: 500, ms: between(200, 900) },
      context: {
        req: r,
        status: 500,
        response: '{"message":"Object reference not set to an instance of an object.","traceId":"00-4bf92f3577b34da6a3ce929d0e0e4736-01"}',
        traceId: '00-4bf92f3577b34da6a3ce929d0e0e4736-01',
      },
      breadcrumbs: breadcrumbs(c, ['/Prescription/detail/refundable/611', '/CabinAssignment/station']),
      screen: 'drug-refund',
      dt: 600,
    },
  ];
}

function scenarioNetworkDown(c: RunCtx): Draft[] {
  const r = nextReq(c);
  const suppressed = rand() < 0.5 ? between(3, 40) : undefined;
  return [
    {
      level: 'ERROR',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '✕ GET /Dashboard/unReadQrCode (connectionError)',
      req: r,
      errorType: 'NetworkUnavailableException',
      http: { method: 'GET', path: '/Dashboard/unReadQrCode', ms: between(20, 80) },
      context: {
        req: r,
        dioMessage: 'The connection errored: Failed host lookup: agena.novusyazilim.com',
        cause: 'SocketException: Failed host lookup',
        ...(suppressed ? { suppressedRepeats: suppressed } : {}),
      },
      screen: 'dashboard',
    },
    {
      level: 'ERROR',
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-MIXIN-001',
      message: 'DashboardNotifier.fetch-unread-qr → failed',
      errorType: 'NetworkUnavailableException',
      context: { message: 'Sunucuya bağlanılamıyor', errorType: 'NetworkUnavailableException', isRetryable: true },
      screen: 'dashboard',
      dt: 3,
    },
  ];
}

function scenarioSlow(c: RunCtx): Draft[] {
  const r = nextReq(c);
  const ms = between(5100, 11800);
  const path = pick(['/CabinAssignment/station', '/Prescription/detail/patient/55', '/StockMovement/station/3']);
  return [
    {
      level: 'WARN',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: `← GET ${path} yavaş yanıt`,
      req: r,
      http: { method: 'GET', path, status: 200, ms },
      context: { req: r, status: 200, ms },
      breadcrumbs: breadcrumbs(c, ['/Dashboard/summary']),
      screen: pick(['drug-intake', 'drug-refill', 'stock-movements']),
    },
  ];
}

function scenarioTimeout(c: RunCtx): Draft[] {
  const r = nextReq(c);
  return [
    intakeStart(1),
    {
      level: 'INFO',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '→ POST /Prescription/detail/collect',
      req: r,
      http: { method: 'POST', path: '/Prescription/detail/collect' },
      context: { req: r, body: '{"prescriptionDetailId":905,"details":[{"stockId":420,"dosePiece":1,"censusQuantity":5}]}' },
      screen: 'drug-intake',
      dt: 40000,
    },
    {
      level: 'ERROR',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '✕ POST /Prescription/detail/collect (receiveTimeout)',
      req: r,
      errorType: 'TimeoutException',
      http: { method: 'POST', path: '/Prescription/detail/collect', ms: 60000 },
      context: { req: r, dioMessage: 'The request took longer than 0:01:00.000000 to receive data.' },
      breadcrumbs: breadcrumbs(c, ['/CabinAssignment/station']),
      screen: 'drug-intake',
      dt: 60000,
    },
  ];
}

function scenarioUncaught(): Draft[] {
  return [
    {
      level: 'ERROR',
      unit: 'SW-UNIT-APP',
      swreq: 'SWREQ-CORE-LOG-003',
      message: 'Yakalanmamış Flutter hatası',
      errorType: 'RangeError',
      error: 'RangeError (index): Invalid value: Not in inclusive range 0..3: 4',
      stackTrace: [
        '#0      List.[] (dart:core-patch/growable_array.dart:264:36)',
        '#1      CabinUnitDoseEntryTable._cellAt (package:pharmed_client/widgets/cabin_operation_execution/cabin_unit_dose_entry_table.dart:231:18)',
        '#2      CabinUnitDoseEntryTable.build.<anonymous closure> (package:pharmed_client/widgets/cabin_operation_execution/cabin_unit_dose_entry_table.dart:118:22)',
        '#3      SliverChildBuilderDelegate.build (package:flutter/src/widgets/scroll_delegate.dart:497:22)',
      ].join('\n'),
      context: { library: 'widgets library', context: 'building CabinUnitDoseEntryTable' },
      screen: 'drug-census',
    },
  ];
}

function scenarioSerum(): Draft[] {
  return [
    {
      level: 'WARN',
      unit: 'SW-UNIT-CABIN',
      swreq: 'SWREQ-DATA-CABIN-SERUM-001',
      message: 'Serum yerleşimi beklenmeyen veri içeriyor',
      rule: 'SERUM_LAYOUT_INCOMPLETE',
      context: { slotId: 31, rule: 'SERUM_LAYOUT_INCOMPLETE', shelves: '1201:1:3,1202:2:2,null:3:0' },
      screen: 'cabin-design',
    },
  ];
}

function scenarioUnauthorized(c: RunCtx): Draft[] {
  const r = nextReq(c);
  return [
    {
      level: 'ERROR',
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-006',
      message: '✕ GET /CurrentUser (badResponse)',
      req: r,
      errorType: 'ServiceException',
      http: { method: 'GET', path: '/CurrentUser', status: 401, ms: between(30, 120) },
      context: { req: r, status: 401, response: '{"message":"Token süresi doldu"}' },
      screen: 'dashboard',
    },
    {
      level: 'INFO',
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-CORE-LOG-003',
      message: 'Oturum kapandı',
      context: { reason: 'unauthorized' },
      dt: 20,
      noSession: true,
    },
  ];
}

type Scenario = { weight: number; run: (c: RunCtx) => Draft[]; only?: (d: SimDevice) => boolean };

const SCENARIOS: Scenario[] = [
  { weight: 30, run: scenarioIntakeOk },
  { weight: 22, run: scenarioMutationOk },
  { weight: 9, run: scenarioIntakeCheckRejected, only: (d) => d.stationId !== 8 },
  { weight: 4, run: scenarioIntakePlanInsufficient },
  { weight: 4, run: () => scenarioWitness() },
  { weight: 3, run: () => scenarioOverdue() },
  { weight: 5, run: scenarioSlow },
  { weight: 3, run: scenarioNetworkDown, only: (d) => d.stationId === 5 },
  { weight: 1.2, run: scenarioRefund500 },
  { weight: 1, run: scenarioTimeout },
  { weight: 2, run: () => scenarioUncaught(), only: (d) => d.appVersion.startsWith('0.3.9') },
  { weight: 0.6, run: () => scenarioSerum(), only: (d) => d.stationId === 8 },
  { weight: 1, run: scenarioUnauthorized },
];

function pickScenario(d: SimDevice): Scenario {
  const pool = SCENARIOS.filter((s) => !s.only || s.only(d));
  const total = pool.reduce((s, x) => s + x.weight, 0);
  let roll = rand() * total;
  for (const s of pool) {
    roll -= s.weight;
    if (roll <= 0) return s;
  }
  return pool[0];
}

function materialize(c: RunCtx, drafts: Draft[]): LogEntry[] {
  const station = STATIONS.find((s) => s.id === c.device.stationId)!;
  return drafts.map((d) => {
    c.t += d.dt ?? between(200, 1500);
    const { dt: _dt, noSession, screen, ...rest } = d;
    void _dt;
    const entry: LogEntry = {
      ...rest,
      id: uuid(),
      deviceId: c.device.deviceId,
      appRunId: c.appRunId,
      appVersion: c.device.appVersion,
      timestamp: new Date(c.t).toISOString(),
      receivedAt: new Date(c.t + between(500, 30000)).toISOString(),
      session: noSession
        ? undefined
        : {
            userId: c.user.id,
            user: c.user.name,
            stationId: station.id,
            serviceId: station.serviceId,
            screen: screen ?? 'dashboard',
          },
    };
    entry.fingerprint = fingerprintOf(entry);
    return entry;
  });
}

function generate(now: number): LogEntry[] {
  rand = mulberry32(20261109);
  const out: LogEntry[] = [];
  for (const device of DEVICES) {
    const end = now - (device.silentForMin ?? 0) * MIN;
    for (let day = 7; day >= 0; day--) {
      const dayStart = now - day * DAY;
      // Her gün 1-2 uygulama çalışması, 07:00-23:00 arası etkinlik.
      const runs = between(1, 2);
      for (let run = 0; run < runs; run++) {
        const users = USERS.filter((u) => u.stations.includes(device.stationId));
        const c: RunCtx = {
          device,
          appRunId: uuid(),
          user: pick(users),
          reqSeq: 0,
          t: dayStart - between(2, 10) * HOUR + run * 7 * HOUR,
        };
        const runEnd = Math.min(c.t + between(5, 8) * HOUR, end);
        if (c.t >= runEnd) continue;
        out.push(
          ...materialize(c, [
            {
              level: 'INFO',
              unit: 'SW-UNIT-APP',
              swreq: 'SWREQ-CORE-LOG-003',
              message: 'Uygulama başlatıldı',
              context: { flavor: 'prod', os: 'Windows 10 Pro 22H2', host: device.hostName },
              noSession: true,
            },
          ]),
        );
        out.push(...materialize(c, scenarioLogin()));
        while (c.t < runEnd) {
          if (rand() < 0.12) {
            c.user = pick(users);
            out.push(...materialize(c, scenarioLogin()));
          }
          const entries = materialize(c, pickScenario(device).run(c));
          out.push(...entries.filter((e) => Date.parse(e.timestamp) <= end));
          c.t += between(3, 25) * MIN;
        }
      }
    }
  }
  return out.filter((e) => Date.parse(e.timestamp) <= now).sort((a, b) => b.timestamp.localeCompare(a.timestamp));
}

// ── Sorgu motoru ─────────────────────────────────────────────────────────

const STATUS_KEY = 'pharmed-log-panel:mock-group-status';

interface StoredStatus {
  status: GroupStatus;
  note?: string;
  resolvedInVersion?: string;
  statusChangedAt: string;
  statusChangedBy: string;
}

function compareVersion(a = '', b = ''): number {
  const pa = a.split(/[.+]/).map(Number);
  const pb = b.split(/[.+]/).map(Number);
  for (let i = 0; i < Math.max(pa.length, pb.length); i++) {
    const d = (pa[i] ?? 0) - (pb[i] ?? 0);
    if (d) return d;
  }
  return 0;
}

function matches(e: LogEntry, q: LogQuery): boolean {
  const t = e.timestamp;
  if (t < q.from || t > q.to) return false;
  if (q.level?.length && !q.level.includes(e.level)) return false;
  if (q.stationId?.length && !q.stationId.includes(e.session?.stationId ?? -1)) return false;
  if (q.deviceId?.length && !q.deviceId.includes(e.deviceId)) return false;
  if (q.userId?.length && !q.userId.includes(e.session?.userId ?? -1)) return false;
  if (q.unit?.length && !q.unit.includes(e.unit)) return false;
  if (q.rule?.length && !q.rule.includes(e.rule ?? '')) return false;
  if (q.fingerprint && e.fingerprint !== q.fingerprint) return false;
  if (q.appRunId && e.appRunId !== q.appRunId) return false;
  if (q.req && e.req !== q.req) return false;
  if (q.appVersion && e.appVersion !== q.appVersion) return false;
  if (q.httpStatus && e.http?.status !== q.httpStatus) return false;
  if (q.httpPath) {
    const p = e.http?.path;
    if (!p || !(p.includes(q.httpPath) || normalizePath(p).includes(q.httpPath))) return false;
  }
  if (q.search) {
    const s = q.search.toLocaleLowerCase('tr');
    const hay = `${e.message} ${e.error ?? ''} ${e.rule ?? ''} ${JSON.stringify(e.context ?? {})}`.toLocaleLowerCase('tr');
    if (!hay.includes(s)) return false;
  }
  return true;
}

function intervalMs(interval: string): number {
  const m = /^(\d+)([mhd])$/.exec(interval);
  if (!m) return HOUR;
  const n = Number(m[1]);
  return n * (m[2] === 'm' ? MIN : m[2] === 'h' ? HOUR : DAY);
}

function bucketize(entries: LogEntry[], from: string, to: string, interval: string): Bucket[] {
  const step = intervalMs(interval);
  const start = Math.floor(Date.parse(from) / step) * step;
  const end = Date.parse(to);
  const buckets: Bucket[] = [];
  for (let t = start; t <= end; t += step) {
    buckets.push({ t: new Date(t).toISOString(), counts: { INFO: 0, WARN: 0, ERROR: 0 } });
  }
  for (const e of entries) {
    const i = Math.floor((Date.parse(e.timestamp) - start) / step);
    if (i >= 0 && i < buckets.length) buckets[i].counts[e.level] += 1;
  }
  return buckets;
}

const delay = <T,>(value: T, ms = 120 + Math.random() * 180) =>
  new Promise<T>((resolve) => setTimeout(() => resolve(value), ms));

export class MockLogApi implements LogApi {
  readonly isMock = true;
  private entries: LogEntry[];
  private statuses: Record<string, StoredStatus>;
  private liveCtx: RunCtx[];

  constructor() {
    const now = Date.now();
    this.entries = generate(now);
    this.statuses = this.loadStatuses();
    this.seedStatuses(now);
    this.liveCtx = DEVICES.filter((d) => !d.silentForMin).map((device) => ({
      device,
      appRunId: this.entries.find((e) => e.deviceId === device.deviceId)?.appRunId ?? uuid(),
      user: pick(USERS.filter((u) => u.stations.includes(device.stationId))),
      reqSeq: 900,
      t: now,
    }));
    setInterval(() => this.tick(), 6000);
  }

  /** Canlı izleme için yeni kayıtlar. */
  private tick() {
    const c = pick(this.liveCtx);
    c.t = Date.now() - 2000;
    const fresh = materialize(c, pickScenario(c.device).run(c))
      .map((e) => ({ ...e, timestamp: new Date(Math.min(Date.parse(e.timestamp), Date.now())).toISOString() }))
      .sort((a, b) => b.timestamp.localeCompare(a.timestamp));
    this.entries = [...fresh, ...this.entries].sort((a, b) => b.timestamp.localeCompare(a.timestamp));
    this.reopenRegressions(fresh);
  }

  private loadStatuses(): Record<string, StoredStatus> {
    try {
      return JSON.parse(localStorage.getItem(STATUS_KEY) ?? '{}');
    } catch {
      return {};
    }
  }

  private saveStatuses() {
    try {
      localStorage.setItem(STATUS_KEY, JSON.stringify(this.statuses));
    } catch {
      // önizleme ortamında depolama olmayabilir
    }
  }

  /** Örnek durumlar: çözülmüş ama eski sürümde süren hata, geri dönen hata, yok sayılan uyarı. */
  private seedStatuses(now: number) {
    if (Object.keys(this.statuses).length) return;
    const fp = (pred: (e: LogEntry) => boolean) => this.entries.find(pred)?.fingerprint;
    const uncaught = fp((e) => e.errorType === 'RangeError');
    const refund = fp((e) => e.http?.status === 500);
    const slow = fp((e) => e.message.includes('yavaş') && e.http?.path === '/StockMovement/station/3');
    const at = (msAgo: number) => new Date(now - msAgo).toISOString();
    if (uncaught)
      this.statuses[uncaught] = {
        status: 'resolved',
        note: 'Göz indeksi sınır kontrolü eklendi (#94). Eski sürümdeki kiosklar güncellenince kaybolacak.',
        resolvedInVersion: '0.4.1+14',
        statusChangedAt: at(4 * DAY),
        statusChangedBy: 'Feyzullah',
      };
    if (refund)
      this.statuses[refund] = {
        status: 'resolved',
        note: 'Backend null kontrolü eklendi.',
        statusChangedAt: at(3 * DAY),
        statusChangedBy: 'Feyzullah',
      };
    if (slow)
      this.statuses[slow] = {
        status: 'ignored',
        note: 'Rapor ekranı, büyük veri — kabul edilebilir.',
        statusChangedAt: at(5 * DAY),
        statusChangedBy: 'Feyzullah',
      };
    this.saveStatuses();
  }

  private reopenRegressions(fresh: LogEntry[]) {
    let changed = false;
    for (const e of fresh) {
      const s = e.fingerprint ? this.statuses[e.fingerprint] : undefined;
      if (s?.status !== 'resolved') continue;
      if (s.resolvedInVersion && compareVersion(e.appVersion, s.resolvedInVersion) < 0) continue;
      this.statuses[e.fingerprint!] = { ...s, status: 'open' };
      changed = true;
    }
    if (changed) this.saveStatuses();
  }

  private buildGroup(fingerprint: string, rangeEntries: LogEntry[]): LogGroup {
    const all = this.entries.filter((e) => e.fingerprint === fingerprint);
    const first = all[all.length - 1];
    const last = all[0];
    const stored = this.statuses[fingerprint];
    let status: GroupStatus = stored?.status ?? 'open';
    let regressed = false;
    if (stored?.status === 'resolved') {
      const after = all.filter(
        (e) =>
          e.timestamp > stored.statusChangedAt &&
          (!stored.resolvedInVersion || compareVersion(e.appVersion, stored.resolvedInVersion) >= 0),
      );
      if (after.length) {
        status = 'open';
        regressed = true;
      }
    }
    const inRange = rangeEntries.filter((e) => e.fingerprint === fingerprint);
    const uniq = <T,>(xs: T[]) => new Set(xs).size;
    return {
      fingerprint,
      title: first.message,
      level: first.level,
      unit: first.unit,
      rule: first.rule,
      errorType: first.errorType,
      httpMethod: first.http?.method,
      httpPath: first.http ? normalizePath(first.http.path) : undefined,
      status,
      count: inRange.length,
      totalCount: all.length,
      deviceCount: uniq(inRange.map((e) => e.deviceId)),
      userCount: uniq(inRange.map((e) => e.session?.userId).filter(Boolean)),
      stationCount: uniq(inRange.map((e) => e.session?.stationId).filter(Boolean)),
      firstSeen: first.timestamp,
      lastSeen: last.timestamp,
      firstSeenVersion: first.appVersion,
      lastSeenVersion: last.appVersion,
      sampleEntryId: last.id,
      note: stored?.note,
      statusChangedBy: stored?.statusChangedBy,
      statusChangedAt: stored?.statusChangedAt,
      resolvedInVersion: stored?.resolvedInVersion,
      regressed,
    };
  }

  async listLogs(q: LogQuery): Promise<Page<LogEntry>> {
    const filtered = this.entries.filter((e) => matches(e, q));
    const offset = q.cursor ? Number(q.cursor) : 0;
    const take = Math.min(q.take ?? 100, 200);
    const items = filtered.slice(offset, offset + take);
    const next = offset + take < filtered.length ? String(offset + take) : undefined;
    return delay({ items, nextCursor: next });
  }

  async getLog(id: string): Promise<LogEntry> {
    const e = this.entries.find((x) => x.id === id);
    if (!e) throw new Error('404 — kayıt bulunamadı');
    return delay(e);
  }

  async surrounding(id: string, before = 50, after = 50): Promise<LogEntry[]> {
    const e = this.entries.find((x) => x.id === id);
    if (!e) throw new Error('404 — kayıt bulunamadı');
    const run = this.entries
      .filter((x) => x.deviceId === e.deviceId && x.appRunId === e.appRunId)
      .sort((a, b) => a.timestamp.localeCompare(b.timestamp));
    const i = run.findIndex((x) => x.id === id);
    return delay(run.slice(Math.max(0, i - before), i + after + 1));
  }

  async trace(appRunId: string, req: string): Promise<LogEntry[]> {
    return delay(
      this.entries
        .filter((x) => x.appRunId === appRunId && x.req === req)
        .sort((a, b) => a.timestamp.localeCompare(b.timestamp)),
    );
  }

  async facets(from: string, to: string): Promise<Facets> {
    const inRange = this.entries.filter((e) => e.timestamp >= from && e.timestamp <= to);
    const count = (key: (e: LogEntry) => string | undefined, label?: (k: string) => string): TopItem[] => {
      const m = new Map<string, number>();
      for (const e of inRange) {
        const k = key(e);
        if (k) m.set(k, (m.get(k) ?? 0) + 1);
      }
      return [...m.entries()]
        .map(([k, n]) => ({ key: k, label: label ? label(k) : k, count: n }))
        .sort((a, b) => b.count - a.count);
    };
    return delay({
      units: count((e) => e.unit),
      rules: count((e) => e.rule),
      stations: count(
        (e) => (e.session?.stationId ? String(e.session.stationId) : undefined),
        (k) => STATIONS.find((s) => String(s.id) === k)?.name ?? k,
      ),
      devices: count(
        (e) => e.deviceId,
        (k) => DEVICES.find((d) => d.deviceId === k)?.hostName ?? k,
      ),
      users: count(
        (e) => (e.session?.userId ? String(e.session.userId) : undefined),
        (k) => USERS.find((u) => String(u.id) === k)?.name ?? k,
      ),
      versions: count((e) => e.appVersion),
    });
  }

  async listGroups(q: GroupQuery): Promise<LogGroup[]> {
    const inRange = this.entries.filter(
      (e) => e.fingerprint && e.timestamp >= q.from && e.timestamp <= q.to && (!q.level?.length || q.level.includes(e.level)),
    );
    const fps = [...new Set(inRange.map((e) => e.fingerprint!))];
    let groups = fps.map((fp) => this.buildGroup(fp, inRange));
    if (q.status) groups = groups.filter((g) => g.status === q.status);
    if (q.search) {
      const s = q.search.toLocaleLowerCase('tr');
      groups = groups.filter((g) =>
        `${g.title} ${g.rule ?? ''} ${g.httpPath ?? ''} ${g.errorType ?? ''}`.toLocaleLowerCase('tr').includes(s),
      );
    }
    const sort = q.sort ?? 'lastSeen';
    groups.sort((a, b) =>
      sort === 'count'
        ? b.count - a.count
        : sort === 'users'
          ? b.userCount - a.userCount || b.count - a.count
          : sort === 'firstSeen'
            ? b.firstSeen.localeCompare(a.firstSeen)
            : b.lastSeen.localeCompare(a.lastSeen),
    );
    return delay(groups);
  }

  async getGroup(fingerprint: string): Promise<LogGroup> {
    if (!this.entries.some((e) => e.fingerprint === fingerprint)) throw new Error('404 — grup bulunamadı');
    const from = new Date(Date.now() - 7 * DAY).toISOString();
    return delay(this.buildGroup(fingerprint, this.entries.filter((e) => e.timestamp >= from)));
  }

  async groupTimeline(fingerprint: string, from: string, to: string, interval: string): Promise<Bucket[]> {
    return delay(bucketize(this.entries.filter((e) => e.fingerprint === fingerprint), from, to, interval));
  }

  async setGroupStatus(fingerprint: string, change: StatusChange): Promise<LogGroup> {
    this.statuses[fingerprint] = {
      ...change,
      statusChangedAt: new Date().toISOString(),
      statusChangedBy: 'Siz',
    };
    this.saveStatuses();
    return this.getGroup(fingerprint);
  }

  async timeseries(q: LogQuery, interval: string): Promise<Bucket[]> {
    return delay(bucketize(this.entries.filter((e) => matches(e, q)), q.from, q.to, interval));
  }

  async top(q: LogQuery, dimension: TopDimension, limit = 10): Promise<TopItem[]> {
    const f = await this.facets(q.from, q.to);
    const filtered = this.entries.filter((e) => matches(e, q));
    const key = (e: LogEntry): string | undefined => {
      switch (dimension) {
        case 'rule':
          return e.rule;
        case 'httpPath':
          return e.http ? `${e.http.method} ${normalizePath(e.http.path)}` : undefined;
        case 'station':
          return e.session?.stationId ? String(e.session.stationId) : undefined;
        case 'device':
          return e.deviceId;
        case 'user':
          return e.session?.userId ? String(e.session.userId) : undefined;
        case 'unit':
          return e.unit;
      }
    };
    const labels: Record<string, string> = {};
    for (const list of [f.stations, f.devices, f.users]) for (const i of list) labels[i.key] = i.label;
    const m = new Map<string, number>();
    for (const e of filtered) {
      const k = key(e);
      if (k) m.set(k, (m.get(k) ?? 0) + 1);
    }
    return delay(
      [...m.entries()]
        .map(([k, count]) => ({ key: k, label: labels[k] ?? k, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, limit),
    );
  }

  async slow(from: string, to: string, limit = 10): Promise<SlowItem[]> {
    const m = new Map<string, number[]>();
    for (const e of this.entries) {
      if (e.timestamp < from || e.timestamp > to || !e.http?.ms || !e.http.status) continue;
      const k = `${e.http.method} ${normalizePath(e.http.path)}`;
      m.set(k, [...(m.get(k) ?? []), e.http.ms]);
    }
    const items = [...m.entries()].map(([k, ms]) => {
      const sorted = [...ms].sort((a, b) => a - b);
      const [method, ...rest] = k.split(' ');
      return {
        method,
        path: rest.join(' '),
        count: ms.length,
        avgMs: Math.round(ms.reduce((s, x) => s + x, 0) / ms.length),
        p95Ms: sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * 0.95))],
        maxMs: sorted[sorted.length - 1],
      };
    });
    return delay(items.sort((a, b) => b.p95Ms - a.p95Ms).slice(0, limit));
  }

  async devices(): Promise<Device[]> {
    const now = Date.now();
    const dayAgo = new Date(now - DAY).toISOString();
    return delay(
      DEVICES.map((d) => {
        const mine = this.entries.filter((e) => e.deviceId === d.deviceId);
        const recent = mine.filter((e) => e.timestamp >= dayAgo);
        const station = STATIONS.find((s) => s.id === d.stationId);
        return {
          deviceId: d.deviceId,
          hostName: d.hostName,
          stationId: d.stationId,
          stationName: station?.name,
          appVersion: d.appVersion,
          flavor: 'prod',
          // Canlı kiosklar 5 dakikada bir boş gönderim yapar.
          lastSeenAt: new Date(d.silentForMin ? now - d.silentForMin * MIN : now - between(10, 280) * 1000).toISOString(),
          lastEntryAt: mine[0]?.timestamp,
          errors24h: recent.filter((e) => e.level === 'ERROR').length,
          warns24h: recent.filter((e) => e.level === 'WARN').length,
        };
      }),
    );
  }

  async exportUrl(q: LogQuery, format: 'ndjson' | 'csv') {
    const rows = this.entries.filter((e) => matches(e, q)).slice(0, 50_000);
    let text: string;
    if (format === 'ndjson') {
      text = rows.map((r) => JSON.stringify(r)).join('\n');
    } else {
      const cols = ['timestamp', 'level', 'unit', 'message', 'rule', 'req', 'httpMethod', 'httpPath', 'httpStatus', 'deviceId', 'userId', 'stationId', 'screen'];
      const esc = (v: unknown) => {
        const s = v === undefined || v === null ? '' : String(v);
        return /[",\n;]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
      };
      text = [
        cols.join(','),
        ...rows.map((r) =>
          [
            r.timestamp,
            r.level,
            r.unit,
            r.message,
            r.rule,
            r.req,
            r.http?.method,
            r.http?.path,
            r.http?.status,
            r.deviceId,
            r.session?.userId,
            r.session?.stationId,
            r.session?.screen,
          ]
            .map(esc)
            .join(','),
        ),
      ].join('\n');
    }
    const blob = new Blob([text], { type: format === 'csv' ? 'text/csv' : 'application/x-ndjson' });
    return { url: URL.createObjectURL(blob), filename: `pharmed-logs.${format}` };
  }
}
