# PaiDuayDi — ไปด้วยดิ

> แพลตฟอร์ม Android สำหรับค้นหาและจับคู่ผู้ร่วมเดินทางที่มีต้นทาง ปลายทาง และช่วงเวลาใกล้เคียงกัน เพื่อช่วยให้เดินทางสะดวก ปลอดภัย และแบ่งค่าใช้จ่ายได้ง่ายขึ้น

<p align="center">
  <img src="assets/screens/06___Home__Updated_Style_.png" width="320" alt="PaiDuayDi Home screen">
</p>

## ภาพรวม

PaiDuayDi เป็น Flutter application ที่นำ Google Maps มาใช้กับการค้นหาสถานที่ การเลือกจุดขึ้น/จุดหมาย และการคำนวณเส้นทางจริง เมื่อผู้ใช้เลือกปลายทางแล้ว ระบบจะแสดงหน้า **Create Trip** เพื่อกำหนดรายละเอียด ก่อนเข้าสู่หน้า **Matching** เพื่อค้นหาผู้ร่วมทางที่มีเส้นทางใกล้เคียงกัน

โปรเจกต์นี้เป็น Core MVP ของแพลตฟอร์ม โดยเน้น flow หลักตั้งแต่เข้าสู่ระบบจนถึงการเตรียมสร้างทริป

## ฟีเจอร์ที่มีแล้ว

- Splash และหน้าทางเข้าสู่ระบบ
- เข้าสู่ระบบด้วยเบอร์โทรศัพท์และ OTP ผ่าน Firebase Authentication
- โครงสร้างการเข้าสู่ระบบด้วย Google และ Facebook
- หน้า Home พร้อม UX/UI สำหรับการค้นหาทริป
- แสดง Google Maps พร้อมตำแหน่งปัจจุบันของอุปกรณ์
- ค้นหาต้นทาง/ปลายทางด้วย Google Places API (New)
- เลือกจุดหมายด้วยการแตะปักหมุดบนแผนที่
- คำนวณเส้นทางรถยนต์จริงผ่าน Google Routes API
- แสดงเส้นทางสีเขียว ระยะทาง และเวลาเดินทางบนแผนที่
- แผง Home แบบเลื่อนได้ 3 ระดับ พร้อมปุ่ม `เลือกบน Maps`
- หน้า **Create Trip (06.5)** สำหรับกำหนดวัน เวลา ความยืดหยุ่น จำนวนคน งบประมาณ รูปแบบเดินทาง และความต้องการร่วมทริป
- หน้า **Matching (07)** พร้อมวงหมุนค้นหาผู้ร่วมทางและการแสดงผลการ์ดผู้ร่วมทางแบบ animated
- ปุ่ม `ขอร่วมทาง` ที่เปลี่ยนสถานะเป็น `ส่งคำขอแล้ว`
- Widget tests สำหรับ Splash/Auth, Create Trip และ Matching

## Flow ที่ใช้งานได้ในปัจจุบัน

```text
Sign in
  → Home + Google Maps
  → เลือกต้นทางและปลายทาง / ปักหมุดบนแผนที่
  → คำนวณเส้นทางด้วย Firebase Function + Google Routes API
  → Create Trip
  → กำหนดรายละเอียดทริป และกด Start
  → Matching: ค้นหาและแสดงผู้ร่วมทางที่เหมาะสม
  → ส่งคำขอร่วมทาง
```

> หน้า Matching ใน MVP ปัจจุบันจำลองขั้นตอนค้นหาและข้อมูลผู้ร่วมทางเพื่อทดสอบ UX/UI เท่านั้น ยังไม่ได้บันทึก Trip, ส่งคำขอร่วมทาง หรือจับคู่จากข้อมูลผู้ใช้จริงใน Firestore

## Tech stack

| ส่วน | เทคโนโลยี |
| --- | --- |
| Mobile app | Flutter / Dart |
| Authentication | Firebase Authentication |
| Backend route proxy | Firebase Cloud Functions (2nd Gen, TypeScript) |
| Map | Google Maps SDK for Android |
| Place search | Google Places API (New) |
| Route calculation | Google Routes API |
| Location | Geolocator |
| Design | Google Fonts, Material 3 |

## สถาปัตยกรรม

```text
Flutter app
 ├─ Firebase Authentication
 ├─ Google Maps SDK + Geolocator
 ├─ Google Places API (ค้นหาสถานที่)
 └─ Firebase Callable Function: computeTripRoute
       └─ Google Routes API
            └─ ระยะทาง + เวลา + encoded polyline
```

Routes API key ไม่ถูกเก็บในแอปหรือใน Git repository โดย Cloud Function จะอ่านจาก Firebase Secret เท่านั้น

## โครงสร้างโฟลเดอร์

```text
lib/
├─ core/
│  ├─ services/          # Route service และ service ส่วนกลาง
│  └─ theme/             # สีและ typography ของแอป
├─ features/auth/
│  ├─ data/models/       # User model
│  └─ presentation/screens/
│     ├─ splash_screen.dart
│     ├─ auth_entry_screen.dart
│     ├─ phone_entry_screen.dart
│     ├─ otp_verification_screen.dart
│     ├─ home_screen.dart
│     ├─ home_inside_feature_screen.dart
│     └─ matching_screen.dart
└─ main.dart

functions/
└─ src/index.ts          # computeTripRoute Cloud Function
```

## เริ่มต้นใช้งาน

### สิ่งที่ต้องมี

- Flutter SDK ที่รองรับ Dart `^3.13.1`
- Android Studio และ Android SDK
- Android emulator หรืออุปกรณ์ Android จริง
- Node.js 20 (สำหรับ Firebase Functions ตาม config ปัจจุบัน)
- Firebase CLI
- Google Cloud project ที่เปิดใช้ Maps, Places และ Routes API

### 1. Clone และติดตั้ง dependency

```bash
git clone https://github.com/Nawinnapat/PaiDuayDi.git
cd PaiDuayDi
flutter pub get
```

สำหรับ Firebase Functions:

```bash
cd functions
npm install
cd ..
```

### 2. ตั้งค่า Firebase

โปรเจกต์มี `firebase_options.dart` และ `.firebaserc` สำหรับ Firebase project ที่ใช้พัฒนาอยู่แล้ว หากต้องการเชื่อม Firebase project ใหม่ ให้รัน:

```bash
flutterfire configure
firebase login
```

จากนั้นเปิดใช้ผู้ให้บริการ Sign-in ที่ต้องการใน Firebase Authentication เช่น Phone, Google และ Facebook

### 3. ตั้งค่า Google Maps และ Places สำหรับ Android

ใน Google Cloud project เดียวกัน ให้เปิด API เหล่านี้:

- **Maps SDK for Android**
- **Places API (New)**

สร้างหรือแก้ไฟล์ `android/local.properties` ซึ่งถูก ignore โดย Git:

```properties
sdk.dir=C:\\Users\\YOUR_NAME\\AppData\\Local\\Android\\sdk
GOOGLE_MAPS_API_KEY=your_android_maps_key
```

ตั้งข้อจำกัดของ key ให้เป็น Android app โดยใช้:

- Package name: `com.paiduaydi.paiduaydi`
- SHA-1 ของ signing certificate ที่ใช้ build แอป

> ห้ามใส่ API key ลงใน `README.md`, Git หรือ source code ที่ commit ขึ้น repository

### 4. ตั้งค่า Google Routes API สำหรับ Cloud Functions

เปิด **Routes API** ใน Google Cloud project จากนั้นเก็บ key ไว้ใน Firebase Secret:

```bash
firebase functions:secrets:set GOOGLE_ROUTES_API_KEY
firebase deploy --only functions
```

Cloud Function `computeTripRoute` ทำงานที่ region `asia-southeast1` และคืนค่า polyline, ระยะทาง และเวลาให้ Flutter app

### 5. รันแอป

```bash
flutter run
```

ระบุอุปกรณ์เมื่อมีหลายตัว:

```bash
flutter devices
flutter run -d emulator-5554
```

## ตรวจสอบคุณภาพและ build APK

```bash
flutter analyze
flutter test
flutter build apk --release
```

ไฟล์ APK ที่สร้างจะอยู่ที่:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### หมายเหตุสำหรับการเผยแพร่จริง

Release build ในสถานะปัจจุบันใช้ debug signing เพื่อความสะดวกในการทดสอบเท่านั้น ก่อนนำขึ้น Google Play หรือแจกจ่ายจริง ควรสร้าง release keystore ของโปรเจกต์เองและตั้งค่า signing config ให้เหมาะสม

## การแก้ปัญหาเบื้องต้น

| อาการ | สิ่งที่ควรตรวจสอบ |
| --- | --- |
| แผนที่ว่างหรือไม่โหลด | `GOOGLE_MAPS_API_KEY`, การเปิด Maps SDK for Android และ package/SHA-1 restriction |
| ค้นหาสถานที่ไม่เจอ | เปิด Places API (New), ตรวจสอบ billing และ Android Maps key |
| คำนวณเส้นทางไม่สำเร็จ | เปิด Routes API, ตรวจสอบ Firebase Secret `GOOGLE_ROUTES_API_KEY` และ deploy Functions ล่าสุด |
| ตำแหน่งปัจจุบันไม่แสดง | เปิด Location ของ emulator/อุปกรณ์ และอนุญาต Location permission ให้แอป |
| Firebase Function ไม่อัปเดต | รัน `firebase deploy --only functions` อีกครั้ง แล้วดู log ใน Firebase Console |

## Roadmap

- [ ] บันทึก Trip และ Profile ลง Cloud Firestore
- [x] หน้า Matching และ animation ค้นหาผู้ร่วมทาง (ข้อมูลจำลอง)
- [ ] ระบบ Matching จากเส้นทาง เวลา งบประมาณ และจำนวนที่นั่งจริง
- [ ] Join Trip, การบันทึกคำขอ และสถานะคำขอร่วมทาง
- [ ] Chat แบบ real-time
- [ ] การยืนยันตัวตนและระดับความน่าเชื่อถือ
- [ ] Rating / Review หลังจบทริป
- [ ] Release signing และ deployment production

---

พัฒนาเป็นส่วนหนึ่งของ PaiDuayDi Core MVP
