//
//  RoadMap.md
//  KingGame
//
//  Created by Akif AYDIN on 1.03.2026.
//

# 👑 KingGame — Proje Durumu

> macOS için SwiftUI ile geliştirilmiş King kart oyunu  
> Geliştirici: Akif AYDIN | Başlangıç: Şubat 2026

---

## 📁 Proje Yapısı

```
KingGame/
├── Models/
│   ├── Card.swift           ✅ Suit, Rank, Card modeli
│   ├── Deck.swift           ✅ Deste, dağıtım, Karo 2 bulma
│   ├── Player.swift         ✅ İnsan + 3 AI tipi, wonCards takibi
│   ├── ContractType.swift   ✅ 6 ceza + 4 koz, BiddingTracker
│   ├── Trick.swift          ✅ Tek löve modeli, kazanan hesabı
│   ├── Round.swift          ✅ 13 löve, trumpOpened flag
│   └── GameState.swift      ✅ Ana oyun kontrolcüsü
│
├── Engine/
│   ├── RuleEngine.swift     ✅ Kart geçerlilik kuralları
│   └── AIDecisionEngine.swift ✅ 3 AI kişiliği
│
├── Views/
│   ├── CardView.swift       ✅ SVG kart görünümü
│   ├── PlayerHandView.swift ✅ İnsan eli, kart seçimi
│   ├── TrickPileView.swift  ✅ Masadaki kartlar (K/G/B/D)
│   ├── BiddingView.swift    ✅ Kontrat seçim ekranı
│   ├── GameBoardView.swift  ✅ Ana oyun masası
│   ├── MainMenuView.swift   ✅ Başlangıç ekranı
│   ├── RoundEndView.swift   ✅ El sonu skorbordu ve geçiş ekranı
│   └── GameEndView.swift    ✅ Oyun sonu + skor tablosu
│
└── Assets.xcassets/
    └── Cards/               ✅ SVG kart seti (htdebeer/SVG-cards)
```

---

## ✅ Tamamlanan Özellikler

### Oyun Motoru
- [x] 52 kart, 4 oyuncu, 20 el
- [x] Karo 2 sahibi ilk kontratı seçer
- [x] Saat yönü tersine sıra: Güney → Doğu → Kuzey → Batı
- [x] Löve kazananı bir sonraki löveyi başlatır
- [x] **Ceza oyunları:** El Almaz, Kupa Almaz, Kız Almaz, Erkek Almaz, Son İki, Rıfkı
- [x] **Koz oyunları:** ♠ ♥ ♦ ♣
- [x] Kupa açılmadan kupa ile löve başlatılamaz
- [x] Koz açılmadan koz ile löve başlatılamaz
- [x] Koz oyununda geçmek zorunlu (hem renk hem koz)
- [x] Kız Almaz: masada As/K varsa Kız oynamak zorunlu
- [x] Rıfkı oynandığında löve anında biter

### Erken Bitiş
- [x] Kız Almaz → 4 kız alındığında biter
- [x] Erkek Almaz → 8 erkek (4K+4J) alındığında biter
- [x] Kupa Almaz → 13 kupa alındığında biter (13 löve oynanır)
- [x] Rıfkı → ♥K alındığında biter
- [x] El Almaz ve Son İki → mutlaka 13 löve oynanır

### Kontrat Seçimi
- [x] İlk 4 elde sadece ceza seçilebilir
- [x] Her oyuncu: max 2 koz + max 3 ceza
- [x] Her ceza türü oyun genelinde max 2 kez seçilebilir
- [x] İnsan oyuncu kendi sırasında manuel seçer
- [x] AI oyuncular otomatik seçer (1 sn gecikme ile)

### Puanlama
- [x] Koz: her löve +50
- [x] El Almaz: her löve -50
- [x] Kupa Almaz: her kupa -30
- [x] Kız Almaz: her kız -100
- [x] Erkek Almaz: her K/J -60
- [x] Son İki: 12. ve 13. löve -180
- [x] Rıfkı: ♥K -320
- [x] King (11 löve kozda): anında oyun biter, +12 / -4
- [x] Oyun sonu: kazanan +12, kaybeden -12, en iyi kazanan +3

### Görsel Arayüz (King HD Stili)
- [x] Ahşap arka plan + yeşil kadife masa
- [x] Altın/amber butonlar
- [x] Koyu oyuncu plakaları (isim + skor)
- [x] Aktif oyuncu vurgusu (altın çerçeve)
- [x] 4 yön sistemi: Güney/Kuzey/Batı/Doğu
- [x] Her oyuncunun kartı kendi önünde görünür
- [x] Son kart 1 sn görünür, sonra löve kapanır
- [x] Yenilen kartlar oyuncunun yanında görünür
  - Kız Almaz: aldığı kızlar
  - Erkek Almaz: aldığı K/J'ler
  - Kupa Almaz / Rıfkı: aldığı kupalar
  - El Almaz: löve sayısı
- [x] Bidding ekranında insan elini göster
- [x] Oyun sonu skor geçmişi tablosu
- [x] **Premium UI Güncellemesi:** Cam (Glassmorphism) efektleri, genişletilmiş kart boyutları, ortalanmış oyuncu plakaları ve lüks degrade (gradient) arka planlar eklendi.

---

## 🔧 Bilinen Hatalar / Eksikler

### Kritik
- [ ] AI bidding motoru yok — AI rastgele seçiyor (`AIDecisionEngine.selectContract` TODO)
- [ ] Sıra karışıklığı zaman zaman yaşanabiliyor (race condition riski)
- [ ] `Player.wonCards` ve `Round.trumpOpened` property'lerinin `Player.swift` / `Round.swift`'e eklendiği doğrulanmadı

### Orta Öncelik
- [ ] Kontrat seçiminde kendi eline göre karar verme (insan için öneri yok)
- [ ] AI'nın kontrat seçimi eline göre değil, sadece mevcut kurallara göre

---

## 🚀 Geliştirme Planı

### Faz 1 — Hata Düzeltmeleri (Öncelikli)
- [ ] AI bidding engine yaz (`AIDecisionEngine.selectContract`)
  - Eline göre koz mu ceza mı değerlendir
  - Kupa sayısına göre Kupa Almaz / Rıfkı riski hesapla
  - Erkek sayısına göre Erkek Almaz riski hesapla
- [ ] Saat yönü sırasını stres testi ile doğrula
- [ ] `Player.wonCards` reset'ini kontrol et (her el başında temizlenmeli)

### Faz 2 — Animasyonlar
- [ ] Kart dağıtım animasyonu (oyun başında)
- [x] Kart atma animasyonu (`matchedGeometryEffect` veya `transition`)
- [x] Löve toplama animasyonu (kartlar kazananın önüne uçar)
- [ ] King kutlama animasyonu (konfeti/parıltı)
- [x] El değişimi geçiş animasyonu (El sonu skorbordu)

### Faz 3 — Ses
- [ ] Kart atma sesi
- [ ] Löve kazanma sesi
- [ ] Ceza yeme sesi
- [ ] King fanfarı
- [ ] Arka plan müziği (isteğe bağlı, açık/kapalı)

### Faz 4 — UI Geliştirmeleri
- [ ] Bidding ekranında "bu kartla riskli" uyarısı
- [x] Oyun içi skor geçmişi paneli (yan panel yerine üst barda akıllı gösterge)
- [x] Her elin özet ekranı (el bittikten sonra kısa süre göster)
- [x] Yenilen ceza kartlarının mini deste olarak gösterimi
- [ ] Ayarlar ekranı (AI zorluğu, animasyon hızı, ses)
- [ ] Renk temaları (klasik yeşil, lacivert, bordo)
- [ ] iPad / iOS desteği (layout adaptasyonu)

### Faz 5 — Gelişmiş AI
- [ ] **Agresif AI:** Erken koz atar, rakibi cezalandırmaya çalışır
- [ ] **Dengeli AI:** Kart sayar, orta risk alır
- [ ] **Hesapçı AI:** Tam kart sayımı, optimal savunma
- [ ] AI'nın hangi kartların oynandığını takip etmesi (playedCards kullanımı)
- [ ] AI'nın diğer oyuncuların olası ellerini tahmin etmesi

### Faz 6 — Çok Oyunculu (Uzun Vadeli)
- [ ] GameKit ile yerel çok oyunculu
- [ ] iCloud skor tablosu
- [ ] Oyun kaydı / devam ettirme

---

## 🎴 Oyun Kuralları Özeti

| Kontrat | Ceza | Özel Kural |
|---------|------|-----------|
| El Almaz | Her löve -50 | 13 löve oynanır |
| Kupa Almaz | Her ♥ -30 | Kupa açılmadan ♥ ile başlanamaz |
| Kız Almaz | Her Q -100 | Masada A/K varsa Q oynamak zorunlu |
| Erkek Almaz | Her K/J -60 | — |
| Son İki | 12. ve 13. löve -180 | 13 löve oynanır |
| Rıfkı | ♥K -320 | ♥K oynandığında löve biter |
| Koz ♠♥♦♣ | Her löve +50 | Geçmek zorunlu, koz açılmadan koz çekilemez |

**King:** Koz oyununda 11 löve → Anında oyun biter, kazanan +12, diğerleri -4

---

## 🛠 Teknik Notlar

- **Platform:** macOS 13+, SwiftUI
- **Mimari:** ObservableObject + @Published
- **Kart Görselleri:** htdebeer/SVG-cards (LGPL)
- **AI Gecikme:** 0.8 sn (oynama) / 1.0 sn (bidding)
- **Sıra Algoritması:** `ccwNext = [3, 2, 0, 1]` (saat yönü tersine)
- **Oyuncu Dizisi:** `[0]Güney(insan) [1]Kuzey [2]Batı [3]Doğu`
