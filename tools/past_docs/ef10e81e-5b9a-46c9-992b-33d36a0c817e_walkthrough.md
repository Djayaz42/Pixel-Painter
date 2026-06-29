# Firebase & Google Play Hazırlık Rehberi

Uygulamanın kod ve Gradle yapılandırma tarafındaki hazırlıklarını tamamladım. Firebase entegrasyonu ve Google Play sürüm yayını için yapılması gereken kalan adımlar aşağıda belirtilmiştir.

---

## Yapılan Geliştirmeler
1. **Bağımlılıklar Eklendi:** `firebase_core`, `firebase_analytics` ve `firebase_crashlytics` paketleri [pubspec.yaml](file:///d:/FlutterProjects/pixel_painter/pubspec.yaml) dosyasına eklendi ve yüklendi.
2. **Firebase Başlatıldı:** [main.dart](file:///d:/FlutterProjects/pixel_painter/lib/main.dart) dosyasında uygulama başlangıcında Firebase'in başlatılması sağlandı.
3. **Uygulama Kimliği Güncellendi:** Android paket adı ve Application ID tüm dosyalarda **`com.vartix.pixelpainter`** olarak güncellendi.
4. **Gradle Yapılandırması:** `settings.gradle.kts` ve `app/build.gradle.kts` dosyalarında Google Services eklentileri yapılandırıldı.
5. **İmzalama Yapılandırıldı (Keystore & key.properties):** Yerel bilgisayarınızda otomatik olarak güvenli bir imzalama anahtarı (`upload-keystore.jks`) oluşturuldu ve [key.properties](file:///d:/FlutterProjects/pixel_painter/android/key.properties) dosyası bu anahtara uygun şekilde yapılandırıldı.

---

## Yapmanız Gereken Tek Kalan Adım

### Firebase Projesi Kurulumu & google-services.json
1. [Firebase Console](https://console.firebase.google.com/) adresine gidin.
2. Yeni bir proje oluşturun (veya mevcut projenizi seçin).
3. **Android** uygulamasını projeye ekleyin. Paket adı sorulduğunda **`com.vartix.pixelpainter`** girin.
4. Kurulum adımlarında size verilen **`google-services.json`** dosyasını indirin.
5. İndirdiğiniz dosyayı şu dizine yapıştırın:
   📂 [android/app/](file:///d:/FlutterProjects/pixel_painter/android/app/) dizinine, yani tam olarak **`d:\FlutterProjects\pixel_painter\android\app\google-services.json`** yoluna.

---

## 🚀 App Bundle (.aab) Üretimi

Yukarıdaki adımları tamamladıktan sonra, Google Play Console'a yükleyeceğimiz `.aab` dosyasını üretmek için terminalde şu komutu çalıştırmanız yeterli olacaktır:

```powershell
flutter build appbundle --release
```

Oluşan dosya şu adreste yer alacaktır:
`build/app/outputs/bundle/release/app-release.aab`

---

## 🐱 Bölüm 26 (Kedi) Güncellemesi

26. bölüm (eski adı "Para" / "Coin") kullanıcının yüklediği turuncu kedi görseli temel alınarak 48x48 boyutlarında piksel sanatı (pixel art) olarak güncellenmiştir:

1. **Şablon Tanımlandı:** [tools/build_levels.dart](file:///d:/FlutterProjects/pixel_painter/tools/build_levels.dart) dosyasında 26. bölümün ismi `"Kedi"` olarak değiştirildi ve kedi pikselleri şablona eklendi.
2. **Seviye Oluşturuldu:** `dart tools/build_levels.dart` scripti çalıştırılarak [lib/models/level_data.dart](file:///d:/FlutterProjects/pixel_painter/lib/models/level_data.dart) dosyası yeni seviye pikselleri ve otomatik hesaplanan boya miktarı bilgileriyle yeniden derlendi.
3. **Testler Güncellendi:** Test dosyalarındaki (`test/motor_path_engine_test.dart`) seviye adı beklentisi `"Para"` yerine `"Kedi"` olarak güncellendi ve tüm testlerin başarıyla geçmesi sağlandı.
4. **Kodlar GitHub'a Gönderildi:** Yapılan tüm değişiklikler başarıyla `main` branch'ine push edildi.
