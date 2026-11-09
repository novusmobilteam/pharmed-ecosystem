// Teşhis kataloğu — bir kaydın ya da hata grubunun "ne oldu, neden olmuş
// olabilir, neye bakmalı" açıklaması. Kural kodları pharmed-client'taki
// MedLogger.ruleRejected / setFailed(rule:) çağrılarıyla birebir aynıdır;
// istemciye yeni bir kural eklendiğinde buraya da bir girdi eklenmeli.

import type { LogEntry, LogGroup } from './api';

export type DiagnosisKind = 'rule' | 'service' | 'network' | 'app' | 'performance' | 'unknown';

export interface Diagnosis {
  kind: DiagnosisKind;
  /** Ne oldu — tek cümle. */
  what: string;
  /** Muhtemel sebep. */
  cause: string;
  /** Sırayla bakılacaklar. */
  checks: string[];
  /** Bu kayda özgü, bağlamdan çıkarılan gerçekler. */
  facts: string[];
}

export const KIND_LABEL: Record<DiagnosisKind, string> = {
  rule: 'Uygulama kuralı',
  service: 'Servis reddi',
  network: 'Ağ',
  app: 'Uygulama hatası',
  performance: 'Performans',
  unknown: 'Sınıflandırılmamış',
};

type RuleInfo = Omit<Diagnosis, 'facts' | 'kind'>;

const RULES: Record<string, RuleInfo> = {
  INTAKE_PLAN_INSUFFICIENT: {
    what: 'Alım servise gönderilmeden durduruldu: kabindeki stoktan çıkarılan plan istenen dozu karşılamıyor.',
    cause:
      'Atamanın stok kayıtlarında istenen miktar yok. Ya kabinde gerçekten stok bitti ya da ekrandaki stok verisi güncel değil (dolum/sayım sonrası liste yenilenmemiş). Kullanıcı bunu "stokta yok" mesajı olarak görür, servis hatası gibi algılayabilir.',
    checks: [
      'Bağlamdaki "dose" ile "planned" ve "assignmentStocks" değerlerini karşılaştırın.',
      'Aynı göz için son dolum ve sayım işlemlerinin (POST/PUT) başarılı olup olmadığına bakın.',
      'Kabin Stok ekranındaki miktar ile backend kaydı farklıysa veri tutarsızlığıdır.',
    ],
  },
  INTAKE_CHECK_FAILED: {
    what: 'Alım başlatılamadı: seçili kalemlerden en az biri kontrolden geçemedi.',
    cause: 'Bu bir özet kayıttır; asıl sebep aynı istekteki servis yanıtında ya da kalem bazlı kural reddindedir.',
    checks: [
      'Bağlamdaki "failedItems" altında hangi kalemin hangi mesajla reddedildiğine bakın.',
      'Hemen öncesindeki ✕ POST …checkCollect kaydını açın; servis yanıtı orada.',
    ],
  },
  INTAKE_ITEM_CHECK_FAILED: {
    what: 'Bir alım kalemi kontrolden geçemedi.',
    cause: 'Kalem ya servis tarafından reddedildi ya da servise gönderilmeden bir uygulama kuralına takıldı.',
    checks: ['Aynı saniyedeki INTAKE_PLAN_INSUFFICIENT veya ✕ POST …checkCollect kaydına bakın.'],
  },
  INTAKE_TOTAL_EXCEEDS_STOCK: {
    what: 'Aynı gözden alınan kalemlerin toplamı gözdeki stoğu aşıyor; fazla olan kalem kuyruğa alınmadı.',
    cause: 'Backend kalemleri tek tek kontrol ediyor; aynı gözden birden fazla order seçildiğinde toplamı client sınırlıyor.',
    checks: ['Bağlamdaki "details" içinde capacity, alreadyUsed ve dose değerlerine bakın.'],
  },
  INTAKE_TARGET_DRAWER_NOT_FOUND: {
    what: 'Kontrol geçti ama alınacak fiziksel göz çözülemedi; kalem kuyruğa alınmadı.',
    cause: 'Stok kaydının bağlı olduğu göz, istasyonun güncel atamalarında yok. Çekmece değişimi veya atama silinmesi sonrası eski stok kaydı kalmış olabilir.',
    checks: [
      'Bağlamdaki stockId ve assignmentId ile Kabin Dizayn / İlaç Atama ekranlarını karşılaştırın.',
      'Yakın zamanda bu kabinde çekmece değişimi yapıldı mı?',
    ],
  },
  INTAKE_TARGET_UNRESOLVED: {
    what: 'Kalemin ne stoğu ne de ataması var; kontrol hiç gönderilmedi.',
    cause: 'Servis kalem için stok çözmemiş ve istasyonda bu ilacın ataması yok.',
    checks: ['İlacın bu istasyonda ataması var mı?', 'Order başka bir istasyona mı yönlendirilmiş?'],
  },
  INTAKE_NO_VALID_TARGETS: {
    what: 'Kontrolden sonra kuyruğa alınabilecek hiç kalem kalmadı.',
    cause: 'Tüm kalemler ya reddedildi ya da hedef göz çözülemedi.',
    checks: ['Aynı istekteki diğer kural redlerine bakın.'],
  },
  INTAKE_WITNESS_REQUIRED: {
    what: 'Şahit gerektiren kalemler için şahit seçilmeden alım başlatılmak istendi.',
    cause: 'Beklenen davranış — kullanıcı hatası. Sık tekrar ediyorsa ekranda şahit gerekliliği yeterince görünür değildir.',
    checks: ['Aynı kullanıcıda sık tekrar ediyorsa eğitim ya da arayüz iyileştirmesi değerlendirin.'],
  },
  INTAKE_OVERDUE_DESCRIPTION_REQUIRED: {
    what: 'Gecikmiş uygulama için açıklama girilmeden alım başlatılmak istendi.',
    cause: 'Beklenen davranış — kullanıcı açıklama girmeden ilerlemeye çalıştı.',
    checks: ['Sık tekrar ediyorsa açıklama alanının ekranda fark edilirliğini değerlendirin.'],
  },
  INTAKE_EQUIVALENT_CHECK_FAILED: {
    what: 'Muadil ilaçla alım kontrolü reddedildi.',
    cause: 'Servis muadil ilacın stoğunu veya uygunluğunu kabul etmedi.',
    checks: ['Bağlamdaki servis mesajına ve equivalentMaterialId değerine bakın.'],
  },
  INTAKE_EQUIVALENT_TARGET_NOT_FOUND: {
    what: 'Muadil ilacın alınacağı göz bulunamadı.',
    cause: 'Muadilin stoğu istasyondaki hiçbir atamaya bağlanamadı.',
    checks: ['Bağlamdaki equivalentStocks içindeki cellId değerlerini atamalarla karşılaştırın.'],
  },
  INTAKE_START_BLOCKED: {
    what: 'Alım başlatma isteği, ekran başlatılamaz durumdayken geldi.',
    cause: 'Genelde çift tıklama ya da kilitli seçim; tek başına sorun değildir.',
    checks: ['Bağlamdaki canStart / isStarting / overdueLocked değerlerine bakın.'],
  },
  SERUM_LAYOUT_INCOMPLETE: {
    what: 'Serum kabininin kayıtlı yerleşimi eksik; yerleşim düzenlemeye kapatıldı.',
    cause: 'Backend 3 raftan yalnızca bir kısmını kayıtlı döndürdü. Önceki bir kayıt yarıda kalmış olabilir.',
    checks: [
      'Bağlamdaki "shelves" (id:orderNo:avadanlık) listesinde id\'si null olan rafı bulun.',
      'Backend\'de bu cabinDesignId için raf kayıtlarını tamamlayın.',
    ],
  },
  SERUM_LAYOUT_INVALID_ORDER: {
    what: 'Serum kabininin kayıtlı rafları geçersiz ya da mükerrer numaralı.',
    cause: 'Raf orderNo değerleri 1–3 aralığında ve benzersiz değil.',
    checks: ['Backend\'deki raf kayıtlarının orderNo değerlerini düzeltin.'],
  },
  SERUM_SHELF_AREA_EXCEEDED: {
    what: 'Bir rafa 8 alanı aşan avadanlık yerleştirilmiş.',
    cause: 'Arayüz bunu engellediği için yalnızca bozuk kayıtlı veriyle görülür.',
    checks: ['Backend\'deki avadanlık kayıtlarını kontrol edin.'],
  },
};

function parseJson(text: unknown): Record<string, unknown> | undefined {
  if (typeof text !== 'string') return undefined;
  try {
    const v = JSON.parse(text);
    return v && typeof v === 'object' ? (v as Record<string, unknown>) : undefined;
  } catch {
    return undefined;
  }
}

/** Servisin döndürdüğü mesaj (yanıt gövdesinden ya da exception bağlamından). */
export function serviceMessage(e: LogEntry): string | undefined {
  const ctx = e.context ?? {};
  const body = parseJson(ctx.response);
  const fromBody = body?.message ?? body?.error ?? body?.title;
  if (typeof fromBody === 'string' && fromBody) return fromBody;
  if (typeof ctx.response === 'string' && ctx.response && !body) return ctx.response;
  if (e.errorType === 'ServiceException' && typeof ctx.message === 'string') return ctx.message;
  return undefined;
}

function factsOf(e: LogEntry): string[] {
  const ctx = e.context ?? {};
  const facts: string[] = [];
  const msg = serviceMessage(e);
  if (msg) facts.push(`Servis yanıtı: "${msg}"`);
  if (e.http?.status) facts.push(`HTTP ${e.http.status}${e.http.ms !== undefined ? `, ${e.http.ms} ms` : ''}`);
  if (typeof ctx.dose === 'number' && typeof ctx.planned === 'number') {
    facts.push(`İstenen ${ctx.dose}, planlanabilen ${ctx.planned}`);
  }
  if (Array.isArray(ctx.assignmentStocks) && ctx.assignmentStocks.length) {
    facts.push(`Gözdeki stoklar (stokId:miktar): ${ctx.assignmentStocks.join(', ')}`);
  }
  const trace = ctx.traceId ?? parseJson(ctx.response)?.traceId;
  if (typeof trace === 'string') facts.push(`Backend traceId: ${trace}`);
  if (typeof ctx.suppressedRepeats === 'number') {
    facts.push(`Son 5 dakikada ${ctx.suppressedRepeats} kez daha tekrarlandı (bastırıldı)`);
  }
  if (e.stackTrace) {
    const frame = e.stackTrace.split('\n').find((l) => l.includes('package:pharmed'));
    const m = frame && /\((package:[^)]+)\)/.exec(frame);
    if (m) facts.push(`İlk uygulama satırı: ${m[1].replace('package:', '')}`);
  }
  return facts;
}

interface Shape {
  level: LogEntry['level'];
  rule?: string;
  errorType?: string;
  status?: number;
  method?: string;
  message: string;
}

function diagnoseShape(s: Shape): Omit<Diagnosis, 'facts'> {
  if (s.rule && RULES[s.rule]) return { kind: 'rule', ...RULES[s.rule] };

  if (s.errorType === 'NetworkUnavailableException' || /connectionError/.test(s.message)) {
    return {
      kind: 'network',
      what: 'Kiosk sunucuya ulaşamadı.',
      cause: 'Kioskun ağ bağlantısı, DNS ya da sunucunun kendisi erişilemez durumdaydı. Aynı anda birden çok kioskta görülüyorsa sunucu/ağ tarafıdır; tek kioskta görülüyorsa o kioskun bağlantısıdır.',
      checks: [
        'Aynı zaman aralığında başka kiosklarda da aynı hata var mı? (Kiosk filtresini kaldırıp bakın.)',
        'Cihazlar ekranında bu kioskun son görülme zamanına bakın.',
        'Hata mesajındaki host adını ve DNS çözümlemesini kontrol edin.',
      ],
    };
  }
  if (s.errorType === 'TimeoutException' || /Timeout/.test(s.message)) {
    const mutating = s.method && s.method !== 'GET';
    return {
      kind: 'network',
      what: 'Servis yanıtı zamanında gelmedi.',
      cause: 'Sunucu isteği çok yavaş işledi ya da ağ yanıtı taşıyamadı.',
      checks: [
        ...(mutating
          ? ['Bu bir yazma isteği: işlem sunucuda tamamlanmış olabilir. Çift kayıt olmaması için backend\'de bu işlemin kaydını kontrol edin.']
          : []),
        'Aynı endpoint için Genel bakıştaki yavaş istek listesine bakın.',
        'Backend loglarında aynı zaman diliminde uzun süren sorgu var mı?',
      ],
    };
  }
  if (s.status === 401) {
    return {
      kind: 'service',
      what: 'Oturum token\'ı reddedildi; kullanıcı oturumdan çıkarıldı.',
      cause: 'Token süresi dolmuş ya da başka bir yerden oturum açılmış.',
      checks: ['Kullanıcı aynı anda başka bir kioskta oturum açtı mı?', 'Token süresi beklenenden kısa mı?'],
    };
  }
  if (s.status === 403) {
    return {
      kind: 'service',
      what: 'Kullanıcının bu işlem için yetkisi yok.',
      cause: 'Rol yetkileri ya da istasyon yetkisi işlemi kapsamıyor.',
      checks: ['Manager\'da kullanıcının rolünü ve istasyon yetkilerini kontrol edin.'],
    };
  }
  if (s.status === 404) {
    return {
      kind: 'service',
      what: 'Servis istenen kaydı ya da endpoint\'i bulamadı.',
      cause: 'Kayıt silinmiş, id yanlış ya da client ile backend sürümleri uyumsuz.',
      checks: ['İstek path\'indeki id\'nin backend\'de var olup olmadığına bakın.', 'Kioskun uygulama sürümünü kontrol edin.'],
    };
  }
  if (s.status && s.status >= 500) {
    return {
      kind: 'service',
      what: 'Backend isteği işlerken hata verdi.',
      cause: 'Sunucu tarafında yakalanmamış bir hata. Client\'ın gönderdiği veri beklenmedik olabilir ama sorun backend\'dedir.',
      checks: [
        'traceId ile backend loglarında hatanın tamamını bulun.',
        'İstek gövdesini (body) backend ekibine iletin.',
        'Aynı endpoint başka kiosklarda da hata veriyor mu?',
      ],
    };
  }
  if (s.status && s.status >= 400) {
    return {
      kind: 'service',
      what: 'Servis isteği iş kuralı gereği reddetti.',
      cause: 'Backend, gönderilen veriyi (stok, doz, durum) kabul etmedi. Gerekçe servis yanıtındaki mesajdadır.',
      checks: [
        'Servis yanıtındaki mesajı okuyun.',
        'İstek gövdesindeki id ve miktarları ekrandaki veriyle karşılaştırın.',
        'Önceki adımlarda bu veriyi getiren GET isteklerine bakın; veri bayat olabilir.',
      ],
    };
  }
  if (s.errorType === 'ServiceException') {
    // Durum kodu bilinmiyor (ör. grup listesinde) — servis reddi olarak ele alınır.
    return {
      kind: 'service',
      what: 'Servis isteği reddetti ya da işlerken hata verdi.',
      cause: 'Gerekçe servis yanıtındadır; 4xx iş kuralı reddi, 5xx backend hatasıdır.',
      checks: [
        'Bir tekrarı açıp servis yanıtındaki mesajı ve HTTP durum kodunu okuyun.',
        'İstek gövdesindeki id ve miktarları ekrandaki veriyle karşılaştırın.',
      ],
    };
  }
  if (/yavaş yanıt/.test(s.message)) {
    return {
      kind: 'performance',
      what: 'Servis yanıtı 5 saniyeyi aştı.',
      cause: 'Büyük veri, yavaş sorgu ya da ağ gecikmesi.',
      checks: ['Bu endpoint\'in p95 süresine Genel bakıştan bakın.', 'Ekranın bu veriyi her açılışta yeniden çekip çekmediğini kontrol edin.'],
    };
  }
  if (/isSuccess=false/.test(s.message)) {
    return {
      kind: 'service',
      what: 'Servis 200 döndü ama yanıtta işlemi başarısız bildirdi.',
      cause: 'Backend iş kuralı reddi; gerekçe yanıt gövdesinde.',
      checks: ['Yanıt gövdesindeki message alanını okuyun.'],
    };
  }
  if (s.errorType && /Error$/.test(s.errorType)) {
    return {
      kind: 'app',
      what: 'Uygulamada yakalanmamış bir hata oluştu.',
      cause: 'Koddaki bir hata (ör. liste sınırı aşımı, null erişimi). Kullanıcı ekranda boş/kırık bir bileşen görmüş olabilir.',
      checks: [
        'Stack trace\'teki ilk pharmed satırına gidin.',
        'Sadece eski sürümlerde mi görülüyor? Sürüm dağılımına bakın.',
      ],
    };
  }
  return {
    kind: 'unknown',
    what: s.level === 'ERROR' ? 'Bir hata kaydedildi.' : 'Bir uyarı kaydedildi.',
    cause: 'Bu kayıt türü için teşhis kataloğunda girdi yok.',
    checks: ['Bağlamı ve önceki adımları inceleyin.', 'Sık görülüyorsa diagnosis.ts\'e bir girdi ekleyin.'],
  };
}

export function diagnoseEntry(e: LogEntry): Diagnosis {
  return {
    ...diagnoseShape({
      level: e.level,
      rule: e.rule,
      errorType: e.errorType,
      status: e.http?.status,
      method: e.http?.method,
      message: e.message,
    }),
    facts: factsOf(e),
  };
}

export function diagnoseGroup(g: LogGroup, sample?: LogEntry): Diagnosis {
  return {
    ...diagnoseShape({
      level: g.level,
      rule: g.rule,
      errorType: g.errorType,
      status: sample?.http?.status,
      method: g.httpMethod,
      message: g.title,
    }),
    facts: sample ? factsOf(sample) : [],
  };
}
