# Firebase Entegrasyonu ve Google Play App Bundle (AAB) Hazırlık Planı

Bu plan, Pixel Painter oyununu Google Play Store'a yükleyebilmemiz için Firebase entegrasyonunun tamamlanmasını, benzersiz bir uygulama kimliği (Application ID) atanmasını, uygulamanın imzalanmasını (signing key) ve son olarak `.aab` (Android App Bundle) formatında derlenmesini hedefler.

## Kullanıcı İncelemesi Gereken Konular

> [!IMPORTANT]
> **1. Benzersiz Uygulama Kimliği (Package Name / Application ID)**
> Google Play'e yüklemek için benzersiz uygulama kimliği belirlenmiştir: **`com.vartix.pixelpainter`**.
> 
> **2. Firebase Projesi Kurulumu & google-services.json**
> Firebase entegrasyonunun çalışabilmesi için Firebase Console üzerinden bir proje oluşturup **`com.vartix.pixelpainter`** uygulama kimliği ile bir Android uygulaması eklemeniz gerekmektedir. Firebase'den indireceğiniz `google-services.json` dosyasını `android/app/` dizinine koymamız gerekecektir.

> [!WARNING]
> **3. Uygulama İmzalama Anahtarı (Keystore)**
> Uygulamayı Google Play'e yüklemeden önce imzalamamız gerekir. Bunun için yerel bilgisayarınızda bir keystore dosyası oluşturacağız. Aşağıdaki adımlarda bu keystore'un nasıl oluşturulacağını ve yapılandırılacağını belirttik.

## Açık Sorular

- Firebase Analytics ve Crashlytics dışında entegre etmemizi istediğiniz başka bir Firebase servisi var mı? (örn. Auth, Firestore, Remote Config?)

---

## Önerilen Değişiklikler

### Flutter Yapılandırması

#### [MODIFY] [pubspec.yaml](file:///d:/FlutterProjects/pixel_painter/pubspec.yaml)
- Firebase bağımlılıkları eklenecek:
  - `firebase_core: ^3.1.0`
  - `firebase_analytics: ^11.1.0`
  - `firebase_crashlytics: ^4.0.0`

#### [MODIFY] [main.dart](file:///d:/FlutterProjects/pixel_painter/lib/main.dart)
- Flutter binding ve Firebase başlatma kodları eklenecek:
  ```dart
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ```

### Android Gradle Yapılandırması

#### [MODIFY] [settings.gradle.kts](file:///d:/FlutterProjects/pixel_painter/android/settings.gradle.kts)
- Firebase Google Services eklentisi (plugin) tanımlanacak:
  ```kotlin
  id("com.google.gms.google-services") version "4.4.2" apply false
  ```

#### [MODIFY] [build.gradle.kts](file:///d:/FlutterProjects/pixel_painter/android/app/build.gradle.kts)
- Eklentiler (plugins) kısmına Google Services dahil edilecek:
  ```kotlin
  id("com.google.gms.google-services")
  ```
- `applicationId` güncellenecek: **`com.vartix.pixelpainter`**
- `key.properties` dosyasından imzalama bilgileri okunacak ve `signingConfigs { release { ... } }` tanımlanarak `buildTypes.release` altına eklenecek.

#### [NEW] [key.properties](file:///d:/FlutterProjects/pixel_painter/android/key.properties)
- Keystore şifreleri ve yollarını barındıran yerel dosya oluşturulacak (bu dosya gitignore'a dahil edilmelidir):
  ```properties
  storePassword=SizinSifreniz
  keyPassword=SizinSifreniz
  keyAlias=upload
  storeFile=upload-keystore.jks
  ```

#### [MODIFY] [.gitignore](file:///d:/FlutterProjects/pixel_painter/android/.gitignore)
- Güvenlik için `key.properties` ve `.jks` dosyaları gitignore listesine eklenecek.

---

## Doğrulama ve Adım Adım Çalıştırma Planı

### 1. Adım: Uygulama Kimliği Güncelleme & Bağımlılıkların Yüklenmesi
1. `pubspec.yaml` dosyası güncellenip `flutter pub get` çalıştırılacak.
2. Gradle ve manifest dosyalarındaki paket isimleri güncellenecek.

### 2. Adım: Firebase Yapılandırması
1. Kullanıcı Firebase Console'dan projeyi açacak ve Android uygulaması ekleyecek.
2. `google-services.json` dosyası `d:\FlutterProjects\pixel_painter\android\app\` içine yerleştirilecek.
3. Firebase entegrasyonu kod bazında etkinleştirilecek.

### 3. Adım: Keystore Oluşturma (İmzalama)
Kullanıcı bilgisayarında aşağıdaki komutla keystore üretecektir (Bunu sizin yerinize biz de tetikleyebiliriz):
```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore d:\FlutterProjects\pixel_painter\android\app\upload-keystore.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*Bu komut esnasında şifre belirlemeniz gerekecektir.*

### 4. Adım: App Bundle (.aab) Üretimi
Her şey tamamlandıktan sonra şu komutla paket üretilecek:
```powershell
flutter build appbundle --release
```
Oluşan `.aab` dosyası `build/app/outputs/bundle/release/app-release.aab` yolunda hazır olacaktır.
