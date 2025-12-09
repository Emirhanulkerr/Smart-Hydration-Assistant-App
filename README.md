# 💧 Hydration App - Su Takip Uygulaması

Sakin, huzurlu ve motive edici tasarımlı Flutter su takip uygulaması. Psikolojik tasarım ilkelerine dayanan UI/UX ile kullanıcıların sağlıklı hidrasyon alışkanlıkları geliştirmesine yardımcı olur.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Özellikler

### 🎯 Temel Özellikler
- **Günlük Su Takibi** - Kolay ve hızlı su ekleme
- **İlerleme Göstergesi** - Animasyonlu dalga efekti ile görsel takip
- **Akıllı Hedefler** - Kiloya göre otomatik hedef hesaplama
- **Detaylı İstatistikler** - Haftalık ve aylık grafikler
- **Başarı Rozetleri** - Yumuşak gamification elementleri
- **Seri Takibi** - Ardışık gün başarıları

### 💡 Sağlık Önerileri Sistemi (YENİ!)
- **Kişiselleştirilmiş Öneriler** - Su tüketimine göre dinamik mesajlar
- **İlerleme Bazlı Tavsiyeler** - Hedefe yakınlığa göre özel mesajlar
- **Streak Önerileri** - Seri durumuna göre motive edici mesajlar
- **Zaman Bazlı İpuçları** - Sabah/akşam özel sağlık önerileri
- **Guilt-free Yaklaşım** - Suçluluk hissi yaratmayan nazik ton

### 🔥 Gelişmiş Streak Sistemi (YENİ!)
- **Soft Reset Mekanizması** - %70 hedef = streak devam eder
- **Affetme Günleri** - Kötü günler için ikinci şans
- **Best Streak Takibi** - En iyi rekor kaydı
- **Risk Uyarıları** - Nazik ton ile streak tehlike uyarısı
- **Haftalık İlerleme Görselleştirmesi** - Son 7 günün durumu

### 🏆 Genişletilmiş Başarımlar (YENİ!)
**Streak Başarımları:**
- 🌱 3 gün serisi
- 🌟 7 gün serisi  
- 💪 14 gün serisi
- 🏆 30 gün serisi
- 👑 100 gün serisi

**Hedef Başarımları:**
- ✨ İlk hedef tamamlama
- 🎯 Art arda 3 gün hedef
- 💦 Günlük %120 aşma
- 🚀 Günlük %150 aşma

**Toplam Su Başarımları:**
- 💧 10 litre toplam
- 🌊 50 litre toplam
- 🎖️ 100 litre toplam
- 🌏 500 litre toplam

**Alışkanlık Başarımları:**
- 🌅 Sabah su içme (7 gün)
- 🌙 Akşam hedef tamamlama
- 📊 Günde 3+ kez su ekleme
- 🏅 Hafta sonu hedef tamamlama

### 🔔 Bildirimler
- Periyodik su hatırlatmaları
- Akıllı bildirim modu (uzun süre içilmezse)
- Özelleştirilebilir aktif saatler
- Nazik ve motive edici mesajlar

### 🎨 Tasarım Özellikleri
- **Sakinleştirici Renk Paleti** - Soft mavi, turkuaz, pastel tonları
- **Minimal & Temiz UI** - Beyaz alan bolluğu
- **Yumuşak Köşeler** - Soft UI prensibi
- **Dalga Animasyonları** - Su ekleme efektleri
- **Kutlama Efektleri** - Hedefe ulaşma animasyonları
- **Karanlık Mod** - Soğuk mavi tonları

## 🏗️ Proje Yapısı

```
lib/
├── controllers/       # Riverpod state management
│   └── water_controller.dart
├── models/           # Veri modelleri
│   ├── water_entry.dart
│   ├── user_settings.dart
│   ├── daily_stats.dart
│   └── health_tip.dart          # YENİ
├── screens/          # Uygulama ekranları
│   ├── home_screen.dart
│   ├── stats_screen.dart
│   ├── achievements_screen.dart  # YENİ
│   ├── settings_screen.dart
│   ├── onboarding_screen.dart
│   └── add_water_dialog.dart
├── services/         # İş mantığı servisleri
│   ├── storage_service.dart
│   ├── notification_service.dart
│   ├── health_tip_service.dart   # YENİ
│   ├── streak_service.dart       # YENİ
│   └── achievement_service.dart  # YENİ
├── themes/           # Tema ve renkler
│   ├── app_colors.dart
│   └── app_theme.dart
├── utils/            # Yardımcı fonksiyonlar
│   └── motivational_messages.dart
├── widgets/          # Özel widget'lar
│   ├── wave_animation.dart
│   ├── progress_ring.dart
│   ├── water_button.dart
│   ├── soft_card.dart
│   ├── health_tip_card.dart     # YENİ
│   ├── streak_widget.dart       # YENİ
│   └── achievement_grid.dart    # YENİ
└── main.dart
```

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.0+
- Dart 3.0+
- iOS 12.0+ / Android 6.0+

### Adımlar

1. **Projeyi klonla**
```bash
git clone <repo-url>
cd hydration_app
```

2. **Bağımlılıkları yükle**
```bash
flutter pub get
```

3. **Uygulamayı çalıştır**
```bash
flutter run
```

## 📦 Kullanılan Paketler

| Paket | Açıklama |
|-------|----------|
| `flutter_riverpod` | State management |
| `hive_flutter` | Yerel veri depolama |
| `fl_chart` | Grafikler |
| `flutter_local_notifications` | Bildirimler |
| `google_fonts` | Tipografi (Quicksand) |
| `lottie` | Animasyonlar |
| `equatable` | Model karşılaştırma |

## 🎨 Renk Paleti

| Renk | Hex | Kullanım |
|------|-----|----------|
| Primary Blue | `#5DADE2` | Ana vurgu rengi |
| Turquoise | `#88D8B0` | İkincil vurgu |
| Mint | `#D0ECE7` | Arka plan aksan |
| Water Blue | `#90CAF9` | Su animasyonları |
| Success | `#27AE60` | Başarı göstergeleri |
| Warning | `#F39C12` | Uyarı (nazik ton) |

## 💬 Sağlık Önerileri Örnekleri

### İlerlemeye Göre
- **%0-25:** "Bugün yavaş başlaman normal. Bir yudum iyi gelebilir."
- **%25-50:** "Küçük bir yudum metabolizmanı canlandırır."
- **%50-70:** "Güzel gidiyorsun! Hedefe yaklaşıyorsun."
- **%70-90:** "Harikasın! Biraz daha içersen hedefi tamamlıyorsun."
- **%100+:** "Harika iş çıkardın. Artık dengeyi koruma vakti 😊"

### Streak Durumuna Göre
- **3+ gün:** "Alışkanlık oluşuyor! ⭐"
- **7+ gün:** "Vücudun bu düzeni çok seviyor. Aynen devam! 🔥"
- **30+ gün:** "Bir ay boyunca düzenli su içtin! Vücudun buna çok mutlu. 🏆"

## 🔥 Streak Kuralları

| Durum | Sonuç |
|-------|-------|
| %70+ hedef | ✅ Streak devam |
| %50-69 hedef | 💝 Affetme günü kullanılır (varsa) |
| %50 altı (1 gün) | ⚠️ Streak risk altında |
| %50 altı (2 gün) | 🔄 Streak sıfırlanır (nazik mesajla) |

## 📱 Ekran Görüntüleri

### Ana Ekran
- Streak pill göstergesi 🔥
- Kişiselleştirilmiş sağlık önerisi kartı
- Dairesel ilerleme göstergesi
- Dalga animasyonlu su seviyesi
- Hızlı ekleme butonları
- Günlük kayıt listesi

### Başarımlar Ekranı
- İlerleme halkası
- Streak kartı
- Haftalık ilerleme göstergesi
- Kategorilere göre başarımlar
- Soft glow animasyonlu kilit açık rozeti

### İstatistikler
- Haftalık/Aylık grafikler
- Başarı rozetleri
- Seri göstergesi

### Ayarlar
- Profil bilgileri
- Hedef ayarları
- Bildirim tercihleri
- Tema seçimi

## 🔧 Özelleştirme

### Tema Değiştirme
`lib/themes/app_colors.dart` dosyasından renk paletini özelleştirebilirsiniz.

### Sağlık Önerileri
`lib/services/health_tip_service.dart` dosyasından mesajları düzenleyebilirsiniz.

### Başarımlar
`lib/services/achievement_service.dart` dosyasından yeni başarımlar ekleyebilirsiniz.

### Streak Kuralları
`lib/services/streak_service.dart` dosyasından streak mantığını özelleştirebilirsiniz.

## 📄 Lisans

MIT License - Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🤝 Katkıda Bulunma

1. Fork'layın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit'leyin (`git commit -m 'Add amazing feature'`)
4. Push'layın (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

**Sağlıklı yaşam için su içmeyi unutma! 💧**
