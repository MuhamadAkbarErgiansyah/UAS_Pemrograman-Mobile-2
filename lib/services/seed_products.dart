import 'package:cloud_firestore/cloud_firestore.dart';

/// Service untuk seed produk contoh ke Firebase Firestore
/// Setiap kategori memiliki minimal 10 produk dengan deskripsi lengkap
class SeedProducts {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed semua produk ke semua kategori
  static Future<void> seedAllProducts() async {
    await _seedWatches();
    await _seedLaptops();
    await _seedPhones();
    await _seedAudio();
    await _seedCameras();
    await _seedGaming();
  }

  static Future<void> _seedCollection(
      String categoryId, List<Map<String, dynamic>> products) async {
    final batch = _firestore.batch();

    for (var product in products) {
      final docRef = _firestore.collection('products').doc();
      product['id'] = docRef.id;
      product['categoryId'] = categoryId.toLowerCase();
      batch.set(docRef, product);
    }

    await batch.commit();
  }

  static Future<void> _seedWatches() async {
    final products = [
      {
        'name': 'Apple Watch Series 9',
        'description':
            'Smartwatch premium dengan chip S9 SiP yang revolusioner, memberikan performa 2x lebih cepat. Dilengkapi layar always-on Retina LTPO OLED yang sangat terang hingga 2000 nits. Fitur kesehatan lengkap termasuk sensor oksigen darah, ECG, dan deteksi suhu. Tahan air hingga 50 meter, cocok untuk berenang. Baterai tahan 18 jam dengan penggunaan normal. Tersedia berbagai pilihan band dan case. watchOS 10 dengan widget baru yang informatif.',
        'price': 7499000,
        'discountPrice': 6999000,
        'images': [
          'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 2456,
        'stock': 50,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Samsung Galaxy Watch 6 Classic',
        'description':
            'Smartwatch Android premium dengan bezel putar klasik yang iconic. Layar Super AMOLED 1.5" dengan Sapphire Crystal yang tahan gores. Sensor BioActive 3-in-1 untuk monitoring kesehatan komprehensif: detak jantung, tekanan darah, dan komposisi tubuh. GPS built-in dengan akurasi tinggi. Baterai 425mAh tahan hingga 40 jam. Prosesor Exynos W930 dual-core 1.4GHz. IP68 dan tahan air 5ATM. Wear OS 4 dengan akses ke ribuan aplikasi.',
        'price': 5999000,
        'discountPrice': 5499000,
        'images': [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 1823,
        'stock': 75,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Garmin Fenix 7 Sapphire Solar',
        'description':
            'Smartwatch outdoor ultimate untuk petualang sejati. Layar Power Sapphire dengan solar charging yang menambah 14 hari baterai. GPS multi-band dengan peta TopoActive seluruh dunia. Fitur khusus outdoor: altimeter, barometer, kompas elektronik 3-axis. Mode olahraga 60+ termasuk ski, golf, dan climbing. Bodi titanium yang ultra-ringan namun super kuat. Baterai hingga 37 hari mode smartwatch, 122 jam mode GPS. Fitur keselamatan: deteksi insiden dan LiveTrack.',
        'price': 15999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=500'
        ],
        'rating': 4.9,
        'reviewCount': 987,
        'stock': 25,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Amazfit GTR 4',
        'description':
            'Smartwatch all-rounder dengan harga terjangkau namun fitur lengkap. Layar AMOLED 1.43" dengan brightness 1000 nits yang jelas di bawah sinar matahari. 150+ mode olahraga dengan pengenalan otomatis 8 olahraga populer. GPS dual-band untuk tracking akurat. Alexa built-in untuk kontrol suara. Baterai monster 475mAh tahan hingga 14 hari. Zepp OS 2.0 dengan mini apps. Sensor kesehatan lengkap: SpO2, heart rate, stress level, dan sleep tracking.',
        'price': 2999000,
        'discountPrice': 2699000,
        'images': [
          'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=500'
        ],
        'rating': 4.5,
        'reviewCount': 3421,
        'stock': 100,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Huawei Watch GT 4',
        'description':
            'Smartwatch elegan dengan desain premium stainless steel. Layar AMOLED 1.46" dengan resolusi tinggi 466x466 pixel. TruSeen 5.5+ untuk monitoring detak jantung akurat 24/7. GPS L1+L5 dual-frequency untuk akurasi tinggi. 100+ mode workout termasuk free training dan custom workout. Stay Fit app untuk manajemen kalori dan berat badan. Baterai 524mAh tahan 14 hari. HarmonyOS dengan dukungan aplikasi third-party. Tersedia versi 41mm dan 46mm.',
        'price': 3499000,
        'discountPrice': 3199000,
        'images': [
          'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 1567,
        'stock': 80,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Fitbit Sense 2',
        'description':
            'Smartwatch kesehatan terlengkap dari Fitbit. Sensor EDA untuk deteksi stress tubuh. ECG app untuk kesehatan jantung. Skin temperature sensor untuk tracking siklus menstruasi. SpO2 monitoring 24 jam. Sleep Score dengan analisis sleep stages. 40+ mode olahraga dengan GPS built-in. Google Assistant dan Alexa. Baterai 6+ hari. Fitbit Premium membership dengan konten eksklusif. Cocok untuk yang fokus pada kesehatan dan wellness.',
        'price': 4599000,
        'discountPrice': 3999000,
        'images': [
          'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=500'
        ],
        'rating': 4.4,
        'reviewCount': 2134,
        'stock': 60,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Xiaomi Watch S3',
        'description':
            'Smartwatch modular pertama dari Xiaomi dengan bezel yang bisa diganti-ganti. Layar AMOLED 1.43" dengan brightness 600 nits. Hyper OS dengan UI yang smooth dan responsif. 150+ mode olahraga termasuk e-sports monitoring. GPS dual-band untuk outdoor activity. NFC untuk pembayaran contactless. Baterai 486mAh tahan 15 hari. Bluetooth calling dengan speaker dan mic berkualitas. Tersedia berbagai warna bezel dan strap.',
        'price': 1999000,
        'discountPrice': 1799000,
        'images': [
          'https://images.unsplash.com/photo-1617043786394-f977fa12eddf?w=500'
        ],
        'rating': 4.3,
        'reviewCount': 876,
        'stock': 120,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Fossil Gen 6',
        'description':
            'Smartwatch fashion dengan teknologi canggih. Snapdragon Wear 4100+ untuk performa cepat. Layar AMOLED 1.28" dengan always-on display. Wear OS 3 dengan akses Google Play Store. Fast charging: 0-80% dalam 30 menit. Sensor kesehatan lengkap: SpO2, heart rate, wellness. Water resistant 3ATM. Speaker dan mic untuk Google Assistant dan panggilan. Design klasik cocok untuk casual dan formal. Strap 22mm interchangeable.',
        'price': 4299000,
        'discountPrice': 3599000,
        'images': [
          'https://images.unsplash.com/photo-1508057198894-247b23fe5ade?w=500'
        ],
        'rating': 4.2,
        'reviewCount': 654,
        'stock': 45,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'OPPO Watch 4 Pro',
        'description':
            'Smartwatch flagship dengan LTPO AMOLED 1.91" yang luas dan curved. Apollo 4 Plus chipset untuk performa smooth. ECG dan Blood Pressure monitoring (approved). 100+ mode olahraga dengan coach AI. GPS dual-frequency dengan GLONASS, Galileo, BeiDou. eSIM standalone untuk telepon dan SMS tanpa HP. Baterai 500mAh tahan 5 hari mode pintar. VOOC flash charging: 5 menit untuk 1 hari. ColorOS Watch dengan rich notifications.',
        'price': 4999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1544117519-31a4b719223d?w=500'
        ],
        'rating': 4.5,
        'reviewCount': 432,
        'stock': 35,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Casio G-SHOCK GSW-H1000',
        'description':
            'Smartwatch tangguh dengan DNA G-SHOCK yang legendary. Shock resistant dengan struktur hollow case. Layar dual-layer: OLED untuk smartwatch + monokrom untuk selalu aktif. Wear OS untuk akses ribuan apps. 15+ mode aktivitas termasuk surfing dengan data gelombang. GPS + GLONASS + MICHIBIKI. Heart rate monitor dan akselerometer. Water resistant 200 meter. Baterai 1.5 hari mode smartwatch, timepiece mode berbulan-bulan. Desain bold 65.6mm yang statement.',
        'price': 9999000,
        'discountPrice': 8999000,
        'images': [
          'https://images.unsplash.com/photo-1533139502658-0198f920d8e8?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 321,
        'stock': 20,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    await _seedCollection('watch', products);
  }

  static Future<void> _seedLaptops() async {
    final products = [
      {
        'name': 'MacBook Pro 14" M3 Pro',
        'description':
            'Laptop profesional ultimate dengan chip Apple M3 Pro: CPU 12-core dan GPU 18-core. RAM unified 18GB dengan bandwidth 150GB/s. SSD 512GB super cepat. Layar Liquid Retina XDR 14.2" dengan ProMotion 120Hz, brightness 1600 nits HDR. Sistem audio 6-speaker dengan Spatial Audio. Baterai 17 jam video playback. MagSafe 3, 3x Thunderbolt 4, HDMI 2.1, SD card slot. macOS Sonoma dengan optimasi M3. Ideal untuk video editing 4K/8K, 3D rendering, dan development.',
        'price': 32999000,
        'discountPrice': 31499000,
        'images': [
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500'
        ],
        'rating': 4.9,
        'reviewCount': 1567,
        'stock': 30,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'ASUS ROG Zephyrus G14',
        'description':
            'Laptop gaming portabel paling powerful. AMD Ryzen 9 7940HS dengan 8 cores/16 threads. NVIDIA RTX 4060 8GB untuk raytracing smooth. RAM 16GB DDR5 5600MHz. SSD 1TB NVMe PCIe 4.0. Layar Nebula 14" QHD+ 165Hz dengan 500 nits. ROG Intelligent Cooling dengan Liquid Metal. AniMe Matrix LED di cover belakang. Keyboard per-key RGB dengan switch 1.7mm travel. Baterai 76WHr tahan 10+ jam produktivitas. Berat hanya 1.72kg.',
        'price': 24999000,
        'discountPrice': 23499000,
        'images': [
          'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 2134,
        'stock': 45,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Lenovo ThinkPad X1 Carbon Gen 11',
        'description':
            'Laptop bisnis ultralight legendaris. Intel Core i7-1365U (10 cores) dengan vPro Enterprise. RAM 16GB LPDDR5. SSD 512GB PCIe 4.0. Layar 14" 2.8K OLED 400 nits dengan low blue light. Berat hanya 1.12kg dengan ketebalan 15.36mm. Keyboard terkenal sebagai terbaik di laptop. Fingerprint reader dan IR camera untuk Windows Hello. Dolby Atmos speaker system. MIL-STD 810H durability tested. Carbon fiber reinforced body. Baterai 57WHr dengan rapid charge.',
        'price': 28999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 892,
        'stock': 35,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Dell XPS 15 OLED',
        'description':
            'Laptop premium dengan desain InfinityEdge iconic. Intel Core i7-13700H (14 cores). NVIDIA RTX 4050 6GB. RAM 16GB DDR5. SSD 512GB. Layar 15.6" 3.5K OLED 60Hz dengan DCI-P3 100% dan 400 nits. Four-sided InfinityEdge dengan 92.9% screen-to-body ratio. CNC machined aluminum body dengan carbon fiber palm rest. Quad speakers dengan Waves MaxxAudio Pro. Baterai 86WHr dengan ExpressCharge. Thunderbolt 4 x2, USB-C 3.2, SD card reader.',
        'price': 26999000,
        'discountPrice': 25499000,
        'images': [
          'https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 765,
        'stock': 40,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Acer Swift 3 OLED',
        'description':
            'Laptop tipis dengan layar OLED menakjubkan dan harga terjangkau. Intel Core i5-1340P 12 cores. Intel Iris Xe Graphics. RAM 16GB LPDDR5. SSD 512GB NVMe. Layar 14" 2.8K OLED 90Hz dengan 100% DCI-P3. Berat hanya 1.2kg, ketebalan 15.9mm. Fingerprint reader di power button. Keyboard backlit dengan travel 1.35mm. Baterai 65WHr tahan 10 jam. WiFi 6E dan Bluetooth 5.2. USB4 Type-C dengan Thunderbolt 4. Cocok untuk mahasiswa dan profesional mobile.',
        'price': 12999000,
        'discountPrice': 11999000,
        'images': [
          'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=500'
        ],
        'rating': 4.5,
        'reviewCount': 1456,
        'stock': 60,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'HP Spectre x360 16',
        'description':
            'Laptop convertible premium 2-in-1. Intel Core i7-13700H 14 cores. Intel Arc A370M GPU. RAM 16GB DDR5. SSD 1TB. Layar 16" 3K+ OLED 120Hz touchscreen dengan stylus support. Desain gem-cut yang menawan. 360° hinge untuk mode laptop, tent, stand, tablet. HP MPP 2.0 Tilt Pen included. Quad speakers Bang & Olufsen. 5MP IR camera dengan shutter fisik. Baterai 83WHr. Thunderbolt 4 x2, USB-A, microSD reader. Windows 11 Pro dengan HP Security features.',
        'price': 29999000,
        'discountPrice': 27999000,
        'images': [
          'https://images.unsplash.com/photo-1587614382346-4ec70e388b28?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 543,
        'stock': 25,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'ASUS ZenBook 14 OLED',
        'description':
            'Laptop OLED paling terjangkau dengan fitur lengkap. AMD Ryzen 7 7730U 8 cores. AMD Radeon Graphics. RAM 16GB LPDDR5. SSD 512GB. Layar 14" 2.8K OLED 90Hz dengan 550 nits dan PANTONE Validated. NumberPad 2.0 di touchpad. ErgoLift design untuk typing nyaman. Harman Kardon certified audio. Fingerprint sensor. Baterai 75WHr dengan fast charging. Military-grade MIL-STD 810H. Berat 1.39kg. WiFi 6E ready. USB4 dan Thunderbolt 4.',
        'price': 14999000,
        'discountPrice': 13999000,
        'images': [
          'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 1876,
        'stock': 70,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Microsoft Surface Laptop 5',
        'description':
            'Laptop elegan dengan Windows 11 experience terbaik. Intel Core i7-1265U 10 cores. Intel Iris Xe Graphics. RAM 16GB LPDDR5x. SSD 512GB removable. Layar PixelSense 15" 2496x1664 touchscreen 3:2 aspect ratio. Alcantara keyboard deck yang nyaman. Omnisonic speakers dengan Dolby Atmos. Windows Hello face authentication. Baterai 17+ jam. USB-A, USB-C, Surface Connect. Berat 1.56kg. Integrasi sempurna dengan Microsoft 365 dan ekosistem Surface.',
        'price': 21999000,
        'discountPrice': 19999000,
        'images': [
          'https://images.unsplash.com/photo-1516387938699-a93567ec168e?w=500'
        ],
        'rating': 4.5,
        'reviewCount': 654,
        'stock': 30,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Lenovo Legion 5 Pro',
        'description':
            'Laptop gaming dengan value terbaik. AMD Ryzen 7 7745HX 8 cores/16 threads. NVIDIA RTX 4070 8GB dengan 140W TGP. RAM 16GB DDR5 5600MHz. SSD 1TB NVMe Gen4. Layar 16" WQXGA 165Hz dengan NVIDIA G-Sync dan Dolby Vision. Coldfront 5.0 cooling dengan liquid metal. RGB keyboard 4-zone dengan anti-ghosting. Nahimic audio 3D. Baterai 80WHr dengan Super Rapid Charge 100W. USB-C dengan DisplayPort dan 140W PD charging.',
        'price': 22999000,
        'discountPrice': 21499000,
        'images': [
          'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 1234,
        'stock': 50,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'MacBook Air 15" M3',
        'description':
            'Laptop tipis ringan dengan layar besar. Apple M3 chip: CPU 8-core, GPU 10-core. RAM 8GB unified (upgradeable to 24GB). SSD 256GB (upgradeable to 2TB). Layar Liquid Retina 15.3" dengan P3 wide color dan 500 nits. Ketebalan 11.5mm, berat 1.51kg. MagSafe charging, 2x Thunderbolt ports, headphone jack. Sistem audio 6-speaker dengan Spatial Audio. 1080p FaceTime camera. Baterai 18 jam video playback. Touch ID. Fanless design = totally silent.',
        'price': 19999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 876,
        'stock': 55,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    await _seedCollection('laptop', products);
  }

  static Future<void> _seedPhones() async {
    final products = [
      {
        'name': 'iPhone 15 Pro Max',
        'description':
            'Smartphone flagship Apple dengan chip A17 Pro 3nm pertama di smartphone. Kamera utama 48MP dengan sensor shift OIS dan 5x optical zoom periscope. Dynamic Island untuk notifikasi interaktif. Body titanium grade 5 aerospace yang 10% lebih ringan. USB-C dengan USB 3 speeds. Action Button customizable. ProMotion 120Hz always-on display. Ceramic Shield depan. Video ProRes dan Log. Spatial Video untuk Apple Vision Pro. iOS 17 dengan Contact Poster dan StandBy mode.',
        'price': 21999000,
        'discountPrice': 20999000,
        'images': [
          'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=500'
        ],
        'rating': 4.9,
        'reviewCount': 5678,
        'stock': 80,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Samsung Galaxy S24 Ultra',
        'description':
            'Smartphone Android flagship dengan Galaxy AI. Snapdragon 8 Gen 3 for Galaxy yang paling powerful. S Pen built-in untuk produktivitas. Kamera 200MP dengan AI zoom 100x. Layar 6.8" Dynamic AMOLED 2X dengan Vision Booster 2600 nits. Titanium frame yang super kuat. One UI 6.1 dengan Circle to Search dan Live Translate. 12GB RAM dan storage hingga 1TB. Baterai 5000mAh dengan 45W fast charging. IP68 water resistance. 7 tahun update Android dan security.',
        'price': 19999000,
        'discountPrice': 18499000,
        'images': [
          'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 4321,
        'stock': 65,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Google Pixel 8 Pro',
        'description':
            'Smartphone dengan AI dan computational photography terbaik. Google Tensor G3 chip yang didesain khusus untuk AI. Kamera 50MP dengan Magic Eraser, Photo Unblur, dan Best Take. Layar 6.7" Super Actua LTPO OLED 120Hz dengan 2400 nits. Temperature sensor pertama di smartphone. 7 tahun OS dan security updates. Android 14 dengan AI features eksklusif: Call Screen, Recorder transcription, Circle to Search. 12GB RAM, storage 128GB-1TB. Baterai 5050mAh dengan 30W fast charging.',
        'price': 15999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 2345,
        'stock': 40,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Xiaomi 14 Ultra',
        'description':
            'Flagship killer dengan kamera Leica professional. Snapdragon 8 Gen 3 dengan performa tanpa kompromi. Kamera Leica Summilux quad 50MP dengan variable aperture f/1.63-f/4.0. Layar 6.73" LTPO AMOLED 120Hz dengan 3000 nits. Photography Kit optional untuk grip kamera profesional. HyperOS dengan AI features. RAM 16GB dan storage 512GB UFS 4.0. Baterai 5000mAh dengan 90W wired dan 80W wireless charging. IP68 water resistance. Satellite communication support.',
        'price': 16999000,
        'discountPrice': 15999000,
        'images': [
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 1876,
        'stock': 55,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'OnePlus 12',
        'description':
            'Flagship dengan performa gaming dan daily driver terbaik. Snapdragon 8 Gen 3 dengan vapor chamber cooling. Kamera 50MP Hasselblad dengan color tuning profesional. Layar 6.82" ProXDR 2K 120Hz dengan Dolby Vision. OxygenOS 14 berbasis Android 14 yang fluid. RAM 16GB LPDDR5X dan storage 256GB UFS 4.0. Baterai 5400mAh dengan 100W SUPERVOOC charging (100% dalam 26 menit). Dual stereo speakers Dolby Atmos. Alert slider iconic untuk silent/ring/vibrate.',
        'price': 12999000,
        'discountPrice': 11999000,
        'images': [
          'https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 1543,
        'stock': 70,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'OPPO Find X7 Ultra',
        'description':
            'Smartphone dengan sistem kamera terlengkap. Dual periscope telephoto: 3x dan 6x optical zoom. Kamera utama 50MP Sony LYT-900 1 inch sensor. Hasselblad color science untuk foto natural. Snapdragon 8 Gen 3 dengan performance mode. Layar 6.82" LTPO AMOLED 120Hz dengan 4500 nits lokal. ColorOS 14 dengan AI features. RAM 16GB dan storage 512GB. Baterai 5000mAh dengan 100W SUPERVOOC dan 50W wireless. IP68 + IP69 protection. Satellite communication untuk darurat.',
        'price': 17999000,
        'discountPrice': 16499000,
        'images': [
          'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 876,
        'stock': 35,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Vivo X100 Pro',
        'description':
            'Smartphone dengan Zeiss co-engineered camera system. MediaTek Dimensity 9300 flagship chip. Kamera 50MP dengan ZEISS APO floating telephoto 4.3x. Layar 6.78" LTPO AMOLED 120Hz dengan 3000 nits. V3 imaging chip untuk video 4K Cinematic Portrait. Funtouch OS 14 berbasis Android 14. RAM 16GB dan storage 512GB. Baterai besar 5400mAh dengan 100W flash charging. Sunlight display untuk visibility outdoor. IP68 water resistance.',
        'price': 14999000,
        'discountPrice': 13999000,
        'images': [
          'https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=500'
        ],
        'rating': 4.5,
        'reviewCount': 654,
        'stock': 45,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'ASUS ROG Phone 8 Pro',
        'description':
            'Gaming phone ultimate dengan spesifikasi tanpa kompromi. Snapdragon 8 Gen 3 dengan GameCool 8 cooling system. Layar 6.78" Samsung E6 LTPO AMOLED 165Hz dengan touch sampling 720Hz. AirTrigger 8 untuk kontrol game presisi. RAM 24GB LPDDR5X dan storage 1TB UFS 4.0. Kamera 50MP Sony IMX890 untuk foto dan streaming. Baterai 5500mAh dengan 65W HyperCharge. Dual front-facing stereo speakers Dirac HD Sound. Aura RGB lighting. ROG GameFX audio system.',
        'price': 18999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 543,
        'stock': 30,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Samsung Galaxy Z Fold 5',
        'description':
            'Foldable phone terbaik dengan form factor tablet. Snapdragon 8 Gen 2 for Galaxy. Layar utama 7.6" Dynamic AMOLED 2X saat terbuka. Layar cover 6.2" untuk one-handed use. Flex Mode untuk multitasking unik. IPX8 water resistance. RAM 12GB dan storage 256GB-1TB. Kamera triple 50MP dengan Space Zoom 30x. S Pen support (dijual terpisah). One UI dengan Multi Window dan App Continuity. Baterai 4400mAh dengan 25W fast charging. Corning Gorilla Glass Victus 2.',
        'price': 24999000,
        'discountPrice': 22999000,
        'images': [
          'https://images.unsplash.com/photo-1628744448840-55bdb2e61830?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 1234,
        'stock': 25,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'iPhone 15',
        'description':
            'iPhone terjangkau dengan fitur flagship. Chip A16 Bionic yang powerful dan efisien. Kamera 48MP dengan 2x optical quality zoom dan Smart HDR 5. USB-C untuk universal connectivity. Dynamic Island dari iPhone Pro. Layar 6.1" Super Retina XDR dengan Ceramic Shield. Face ID untuk keamanan dan Apple Pay. iOS 17 dengan Contact Poster, NameDrop, StandBy. MagSafe compatible. IP68 water resistance. Emergency SOS via satellite. 5G untuk koneksi cepat.',
        'price': 14999000,
        'discountPrice': 13999000,
        'images': [
          'https://images.unsplash.com/photo-1556656793-08538906a9f8?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 3456,
        'stock': 90,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    await _seedCollection('phone', products);
  }

  static Future<void> _seedAudio() async {
    final products = [
      {
        'name': 'Sony WH-1000XM5',
        'description':
            'Headphone wireless premium dengan ANC terbaik di industri. 8 microphone dengan dual noise sensor technology. 30 jam battery life dengan ANC on. Multipoint connection untuk 2 device sekaligus. 30mm driver yang didesain ulang untuk bass lebih deep. Speak-to-Chat otomatis pause musik saat bicara. LDAC codec untuk Hi-Res wireless audio. Fast charging: 3 menit untuk 3 jam. Lipat rata untuk portability. App Sony Headphones Connect untuk customization EQ dan ANC.',
        'price': 5499000,
        'discountPrice': 4999000,
        'images': [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500'
        ],
        'rating': 4.9,
        'reviewCount': 3456,
        'stock': 70,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Apple AirPods Pro 2 USB-C',
        'description':
            'Earbuds terbaik untuk ekosistem Apple dengan USB-C universal. H2 chip untuk ANC 2x lebih baik. Adaptive Transparency untuk suara natural. Personalized Spatial Audio dengan head tracking. Conversation Awareness auto lower volume saat bicara. Baterai 6 jam dengan ANC, 30 jam dengan case. Case dengan speaker untuk Find My dan volume control. MagSafe, Apple Watch, dan USB-C charging. IP54 sweat dan water resistant untuk earbuds dan case. Silicone tips 4 ukuran untuk fit sempurna.',
        'price': 3999000,
        'discountPrice': 3699000,
        'images': [
          'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 5678,
        'stock': 90,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'JBL Flip 6',
        'description':
            'Speaker Bluetooth portable dengan suara JBL signature. 12 jam playtime dengan baterai yang bisa di-charge ulang. IP67 waterproof dan dustproof - bisa terendam 1 meter. 2-way speaker system dengan tweeter terpisah untuk clarity tinggi. PartyBoost untuk pair 2+ JBL speaker. JBL Original Pro Sound yang powerful untuk ukurannya. Speakerphone built-in untuk panggilan. USB-C charging port. Warna-warna vibrant dengan strap terintegrasi. Cocok untuk outdoor, beach, poolside.',
        'price': 1799000,
        'discountPrice': 1599000,
        'images': [
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 4567,
        'stock': 120,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Bose QuietComfort Ultra Earbuds',
        'description':
            'Earbuds premium dengan Immersive Audio yang membungkus suara 360°. CustomTune technology yang adapt ke telinga Anda. World-class ANC dengan Quiet Mode dan Aware Mode with ActiveSense. Baterai 6 jam dengan ANC, 24 jam dengan case. Qualcomm aptX Adaptive untuk latensi rendah. Bluetooth 5.3 dengan multipoint 2 device. IPX4 sweat dan splash resistant. 3 ukuran ear tips dan stability bands. Touch controls intuitif. Bose Music app untuk personalisasi.',
        'price': 4999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 1234,
        'stock': 45,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sennheiser Momentum 4',
        'description':
            'Headphone audiophile dengan sound signature legendary Sennheiser. Driver 42mm yang direkayasa ulang untuk detail luar biasa. ANC adaptif dengan Transparency mode. 60 jam battery life - tertinggi di kelasnya. Fast charging: 7 menit untuk 4 jam. Aptx Adaptive untuk wireless Hi-Res. Multipoint untuk 2 device. Mic 4 buah untuk call clarity. Fold flat design dengan smart pause. EQ customization via Sennheiser app. Ear cushions memory foam ultra-nyaman.',
        'price': 5999000,
        'discountPrice': 5499000,
        'images': [
          'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 876,
        'stock': 35,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Samsung Galaxy Buds2 Pro',
        'description':
            'Earbuds Samsung paling advanced dengan 24bit Hi-Fi sound. ANC intelligent yang adapt ke lingkungan. 360 Audio dengan head tracking untuk Spatial sound. Voice Detect auto switch ke Ambient mode saat bicara. IPX7 water resistant. Seamless Galaxy ecosystem integration. SmartThings Find untuk lokasi. Bixby voice wake-up. Baterai 5 jam ANC on, 18 jam dengan case. Wireless charging compatible. Compact design untuk fit nyaman seharian. 3 ukuran ear tips dan wingtips.',
        'price': 2999000,
        'discountPrice': 2499000,
        'images': [
          'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=500'
        ],
        'rating': 4.5,
        'reviewCount': 2345,
        'stock': 80,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Marshall Stanmore III',
        'description':
            'Speaker Bluetooth dengan iconic rock n roll heritage. 50W sistem 3-way speaker: woofer, 2 tweeter. Bass dan treble analog control knobs di atas. Bluetooth 5.2 dengan aptX HD. Spotify Connect built-in untuk direct streaming. Marshall app untuk EQ dan Placement Compensation. Multi-host untuk switch device cepat. Dynamic Loudness untuk full sound di volume rendah. Desain vintage dengan brass details dan vinyl covering. Kabel power 2m included. Cocok untuk ruang tamu atau studio.',
        'price': 6999000,
        'discountPrice': 6499000,
        'images': [
          'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 654,
        'stock': 25,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Audio-Technica ATH-M50xBT2',
        'description':
            'Headphone studio monitor wireless edition. Driver 45mm dengan respons frekuensi 15-28,000Hz. Sound signature flat accurate untuk mixing dan mastering. 50 jam battery life via Bluetooth. LDAC codec support untuk Hi-Res wireless. Multipoint 2 device. Sidetone untuk natural voice saat call. Low latency mode untuk video. Kabel 1.2m detachable included untuk wired listening. Ear cups memory foam. Fold flat design. Beamforming mic untuk call jernih.',
        'price': 3299000,
        'discountPrice': 2999000,
        'images': [
          'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 987,
        'stock': 50,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sonos Era 300',
        'description':
            'Speaker smart dengan Spatial Audio Dolby Atmos. 6 driver termasuk 4 midwoofer dan 2 tweeter. Trueplay untuk room-corrected sound. Bluetooth, WiFi, dan AirPlay 2 connectivity. Voice control dengan Alexa atau Sonos Voice. Line-in dengan USB-C adapter. Sonos app untuk multi-room setup. Sustainability: 100% recycled plastic grille. Touch controls di atas. Wall mountable dengan accessories. Streaming services integration: Spotify, Apple Music, Amazon Music, dan 100+ lainnya.',
        'price': 7499000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 432,
        'stock': 20,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sony LinkBuds S',
        'description':
            'Earbuds terkecil dan teringan dengan ANC dari Sony. Berat hanya 4.8g per earbud. Driver 5mm yang kecil tapi powerful. Integrated Processor V1 untuk ANC dan audio processing. LDAC untuk Hi-Res wireless. Adaptive Sound Control otomatis switch mode. Speak-to-Chat dan Quick Attention. Multipoint 2 device. Baterai 6 jam, 20 jam dengan case. IPX4 water resistant. 360 Reality Audio certified. Sony Headphones Connect app untuk customization penuh.',
        'price': 2499000,
        'discountPrice': 2199000,
        'images': [
          'https://images.unsplash.com/photo-1631867675167-90a456a90863?w=500'
        ],
        'rating': 4.4,
        'reviewCount': 1567,
        'stock': 65,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    await _seedCollection('audio', products);
  }

  static Future<void> _seedCameras() async {
    final products = [
      {
        'name': 'Sony A7 IV',
        'description':
            'Kamera mirrorless full-frame serbaguna untuk foto dan video. Sensor 33MP Exmor R CMOS dengan detail luar biasa. BIONZ XR processor untuk performa cepat. 4K 60p 10-bit video recording. Real-time Eye AF untuk manusia, hewan, dan burung. 5-axis IBIS dengan 5.5 stop stabilization. 10fps continuous shooting dengan buffer besar. 759 phase-detection AF points covering 94% frame. Dual card slots: CFexpress Type A dan SD. Vari-angle touchscreen LCD. Body weather-sealed.',
        'price': 34999000,
        'discountPrice': 32999000,
        'images': [
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500'
        ],
        'rating': 4.9,
        'reviewCount': 1234,
        'stock': 25,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Canon EOS R6 Mark II',
        'description':
            'Kamera mirrorless untuk speed dan low-light excellence. Sensor 24.2MP full-frame dengan improved low-light performance. 40fps electronic shutter dan 12fps mechanical. 4K 60p video dengan Canon Log 3 dan HDR PQ. Dual Pixel CMOS AF II dengan vehicle detection. Up to ISO 204,800 untuk kondisi gelap. 5-axis IBIS dengan 8-stop compensation. 1,053 AF zones covering 100% x 100% frame. Vari-angle touchscreen. WiFi dan Bluetooth. USB-C untuk charging dan data.',
        'price': 37999000,
        'discountPrice': 35999000,
        'images': [
          'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 876,
        'stock': 20,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Nikon Z8',
        'description':
            'Flagship mirrorless dengan resolusi tinggi dan kecepatan. Sensor 45.7MP stacked CMOS untuk speed luar biasa. 20fps RAW continuous dengan minimal blackout. 8K 30p dan 4K 120p N-RAW internal recording. Nikon Z mount dengan lensa profesional. 3D-tracking AF yang presisi. 6-stop IBIS. Dual CFexpress Type B card slots. Body magnesium alloy weather-sealed. Tilting touchscreen 4-axis. Built-in GPS. Blackout-free EVF 3.69M dots.',
        'price': 54999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1495707902641-75cac588d2e9?w=500'
        ],
        'rating': 4.9,
        'reviewCount': 543,
        'stock': 15,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Fujifilm X-T5',
        'description':
            'Kamera APS-C dengan soul fotografer klasik. Sensor 40.2MP X-Trans CMOS 5 HR tertinggi di APS-C. X-Processor 5 untuk color science Fujifilm yang terkenal. Film Simulations termasuk Nostalgic Neg. 15fps electronic shutter dengan 1.0x crop. 4K 60p video dengan F-Log2. 3-way tilting LCD untuk shooting versatile. Dual SD card slots. Retro dials untuk shutter, ISO, exposure compensation. Compact body dengan build quality premium. Weather-sealed.',
        'price': 26999000,
        'discountPrice': 24999000,
        'images': [
          'https://images.unsplash.com/photo-1613462806906-58b6a60c6c9e?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 987,
        'stock': 35,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sony ZV-E10 II',
        'description':
            'Kamera vlogging terbaik dengan interchangeable lens. Sensor 26MP APS-C untuk 4K tanpa crop. Vari-angle screen untuk selfie vlogging. Product Showcase Setting untuk product review. Background Defocus button satu sentuhan. Directional 3-capsule mic built-in. Real-time Eye AF dan tracking. S-Cinetone untuk skin tones natural. 4K 60p dan 120fps slow-motion 1080p. USB streaming untuk direct webcam. Compact dan ringan 377g body only.',
        'price': 12999000,
        'discountPrice': 11999000,
        'images': [
          'https://images.unsplash.com/photo-1614624532983-4ce03382d63d?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 1567,
        'stock': 60,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Panasonic Lumix S5 II',
        'description':
            'Kamera mirrorless full-frame dengan phase-detect AF pertama dari Panasonic. Sensor 24.2MP full-frame dengan Dual Native ISO. Unlimited video recording dengan active cooling. 6K 30p dan 4K 60p internal. 5-axis IBIS dengan Active IS untuk handheld video smooth. Real-time LUT support. V-Log dan V-Gamut untuk color grading. USB-C PD untuk charge saat shooting. Dual SD card slots. Free upgrade ke raw video output. L-mount alliance lenses.',
        'price': 29999000,
        'discountPrice': 27999000,
        'images': [
          'https://images.unsplash.com/photo-1502982720700-bfff97f2ecac?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 654,
        'stock': 30,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'GoPro HERO12 Black',
        'description':
            'Action camera paling advanced untuk adventure. Sensor 1/1.9" untuk low-light lebih baik. 5.3K 60fps dan 4K 120fps video. HyperSmooth 6.0 stabilization yang super smooth. 8:7 aspect ratio untuk vertical crop tanpa kehilangan quality. HDR video dan photo. Max Lens Mod 2.0 support untuk 177° FOV. GP-Log untuk color grading. Wireless preview dan control via app. Waterproof 10m tanpa housing. USB-C charging. Voice control dalam bahasa Indonesia.',
        'price': 6999000,
        'discountPrice': 6499000,
        'images': [
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=500'
        ],
        'rating': 4.6,
        'reviewCount': 2345,
        'stock': 75,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'DJI Osmo Pocket 3',
        'description':
            'Gimbal camera pocket dengan sensor 1 inch terbesar. Sensor CMOS 1 inch untuk low-light excellence. 4K 120fps video dengan 10-bit D-Log M. 2" rotating AMOLED touchscreen untuk monitoring. 3-axis mechanical gimbal untuk footage buttery smooth. ActiveTrack 6.0 untuk subject tracking otomatis. Full-Pixel Fast Focusing untuk AF cepat. 2.5 hour battery life. DJI Mic 2 support untuk audio pro. Glamour Effects untuk enhanced selfie. Vertical shooting mode native.',
        'price': 8999000,
        'discountPrice': 8499000,
        'images': [
          'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 876,
        'stock': 40,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Insta360 X4',
        'description':
            'Kamera 360° dengan 8K resolusi pertama. 8K 30fps 360° video dan 72MP 360° photo. AI-powered reframing untuk edit post-capture. FlowState Stabilization untuk footage smooth. Me Mode untuk invisible selfie stick effect. 4K single-lens wide-angle mode. Active HDR untuk high dynamic range. 5.7K 60fps untuk slow-motion. Waterproof 10m built-in. GPS untuk tracking. Suara 360° dengan 4 microphones. Edit via mobile app atau desktop. Touch display untuk preview.',
        'price': 7999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?w=500'
        ],
        'rating': 4.5,
        'reviewCount': 543,
        'stock': 30,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Canon PowerShot V10',
        'description':
            'Vlog camera ultra-compact untuk content creator. Sensor 1 inch 20.9MP untuk quality tinggi. Built-in stand yang bisa berdiri sendiri. Ultra-wide 19mm lens f/2.8 untuk vlogging. 4K 30fps dan 1080p 60fps video. Smooth slow-motion 120fps 720p. 3 microphone capsules untuk audio berkualitas. Background Defocus mode. Face Tracking AF yang reliable. USB-C charging dan data. 35 menit continuous recording. Layar 2" tilt untuk selfie. Berat hanya 211g.',
        'price': 6499000,
        'discountPrice': 5999000,
        'images': [
          'https://images.unsplash.com/photo-1580707221190-bd94d9087b7f?w=500'
        ],
        'rating': 4.4,
        'reviewCount': 432,
        'stock': 50,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    await _seedCollection('camera', products);
  }

  static Future<void> _seedGaming() async {
    final products = [
      {
        'name': 'PlayStation 5 Slim',
        'description':
            'Konsol next-gen Sony dengan desain lebih slim. Custom SSD 1TB yang ultra-cepat dengan loading hampir instant. GPU berbasis AMD RDNA 2 untuk ray-tracing real-time. Tempest 3D AudioTech untuk immersive sound dengan headphone apapun. DualSense controller dengan haptic feedback dan adaptive triggers revolusioner. 4K 120Hz gaming dan 8K support. Backwards compatible dengan 99% game PS4. PlayStation VR2 ready. Game eksklusif seperti Spider-Man 2, God of War Ragnarok.',
        'price': 8999000,
        'discountPrice': 8499000,
        'images': [
          'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=500'
        ],
        'rating': 4.9,
        'reviewCount': 4567,
        'stock': 60,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Xbox Series X',
        'description':
            'Konsol gaming terkuat dari Microsoft. 12 teraflops GPU power untuk 4K 60fps native gaming. Custom NVME SSD 1TB dengan Velocity Architecture. Smart Delivery untuk optimized game version. Quick Resume untuk switch game instant. Xbox Game Pass access ke 100+ game. Backwards compatible dengan 4 generasi Xbox. Dolby Vision dan Dolby Atmos support. Variable Refresh Rate dan Auto Low Latency Mode. xCloud streaming untuk game di mobile. FPS Boost untuk game lama.',
        'price': 7999000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1621259182978-fbf93132d53d?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 3456,
        'stock': 45,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Nintendo Switch OLED',
        'description':
            'Konsol hybrid dengan layar OLED gorgeous. Layar 7" OLED dengan warna vibrant dan contrast tinggi. Tabletop mode dengan wide adjustable stand. Enhanced audio dengan speaker baru. 64GB internal storage (2x original Switch). Wired LAN port di dock untuk online gaming stable. Joy-Con dengan semua fitur: HD Rumble, IR Motion Camera, NFC. Bisa TV mode 1080p atau portable 720p. Game library massive: Zelda, Mario, Pokemon. Backward compatible dengan semua Switch game.',
        'price': 5499000,
        'discountPrice': 4999000,
        'images': [
          'https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 5678,
        'stock': 80,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Logitech G Pro X Superlight 2',
        'description':
            'Mouse gaming wireless paling ringan untuk esports. Berat hanya 60g tanpa kabel. HERO 2 sensor dengan 32K DPI dan 500+ IPS tracking. LIGHTSPEED wireless dengan sub-1ms response time. LIGHTFORCE hybrid optical-mechanical switches. 95 jam battery life. Onboard memory untuk 5 profile DPI. Zero-additive PTFE feet untuk glide mulus. Ambidextrous design yang cocok semua grip style. Pro-grade build quality untuk turnamen. Companion software G HUB untuk customization.',
        'price': 2499000,
        'discountPrice': 2299000,
        'images': [
          'https://images.unsplash.com/photo-1527814050087-3793815479db?w=500'
        ],
        'rating': 4.9,
        'reviewCount': 2345,
        'stock': 100,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'SteelSeries Arctis Nova Pro Wireless',
        'description':
            'Headset gaming wireless premium dengan dual wireless. Simultaneous 2.4GHz dan Bluetooth connection. Hot-swap battery system dengan 2 baterai included. Active Noise Cancellation 4 mic. Almighty Audio dengan 360° Spatial Audio. Hi-Fi speakers dengan Parametric EQ. Retractable ClearCast Gen 2 mic. ComfortMAX memory foam ear cushions. OLED Base Station untuk kontrol dan charging. Multi-platform: PC, PlayStation, Switch, mobile. Nova Pro Wireless melawan apapun.',
        'price': 5999000,
        'discountPrice': 5499000,
        'images': [
          'https://images.unsplash.com/photo-1599669454699-248893623440?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 1234,
        'stock': 40,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Razer Huntsman V3 Pro',
        'description':
            'Keyboard gaming terbaik dengan Analog Optical Switches. Razer Analog Optical Switches dengan adjustable actuation 0.1-4.0mm. Rapid Trigger untuk gaming kompetitif. Doubleshot PBT keycaps yang tahan lama. Razer Chroma RGB dengan 16.8 juta warna. Magnetic wrist rest dengan plush leatherette. Aluminum top plate yang premium. Multi-function Digital Dial dan 4 Media Keys. Hybrid on-board memory dengan cloud storage. USB Type-A braided cable. Full N-key rollover dan anti-ghosting.',
        'price': 3999000,
        'discountPrice': 3699000,
        'images': [
          'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 1567,
        'stock': 55,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'ASUS ROG Swift PG27AQN',
        'description':
            'Monitor gaming esports dengan refresh rate tertinggi. 27" 1440p IPS panel dengan 360Hz refresh rate. 1ms GTG response time untuk competitive gaming. NVIDIA G-SYNC dengan Reflex Analyzer. HDR10 dengan 97% DCI-P3 color gamut. Quantum Dot technology untuk warna akurat. ASUS ELMB Sync untuk motion clarity. ROG Light Signal RGB projection. Ergonomic stand dengan height, tilt, swivel, pivot. USB-C dengan 65W Power Delivery. Tripod socket untuk mounting fleksibel.',
        'price': 14999000,
        'discountPrice': 13999000,
        'images': [
          'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 654,
        'stock': 25,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Elgato Stream Deck +',
        'description':
            'Control center untuk streamer dan creator. 8 customizable LCD keys dengan ikon dinamis. 4 rotary dials + touch strips untuk kontrol analog. Integrasi dengan OBS, Twitch, YouTube, Spotify. 200+ plugin dari marketplace. Multi Actions untuk macro kompleks. Folder dan profile untuk organisasi. Adjustable stand dan detachable USB-C. SDK untuk developer. Upgrade stream control Anda dengan workflow yang seamless. Cocok untuk streaming, podcast, video production.',
        'price': 3499000,
        'discountPrice': null,
        'images': [
          'https://images.unsplash.com/photo-1593152167544-085d3b9c4938?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 876,
        'stock': 35,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Steam Deck OLED',
        'description':
            'Handheld PC gaming dengan layar OLED gorgeous. Layar 7.4" HDR OLED dengan 90Hz refresh rate dan 1000 nits peak. Custom AMD APU untuk AAA gaming portabel. 512GB atau 1TB NVMe SSD. Battery life 3-12 jam tergantung game. Steam library lengkap di tangan Anda. Trackpads haptic untuk mouse-like precision. Gyroscope untuk aiming. Deck Verified untuk game yang kompatibel. SteamOS berbasis Linux dengan Proton untuk Windows games. Dock untuk TV output 4K.',
        'price': 9999000,
        'discountPrice': 9499000,
        'images': [
          'https://images.unsplash.com/photo-1640955014216-75201056c829?w=500'
        ],
        'rating': 4.8,
        'reviewCount': 2345,
        'stock': 30,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Secretlab TITAN Evo 2024',
        'description':
            'Kursi gaming premium untuk marathon gaming session. 4-way L-ADAPT Lumbar Support System yang adjustable. Cold-cure foam dengan density tinggi untuk kenyamanan lama. Pebble seat base untuk weight distribution merata. Magnetic memory foam head pillow. Armrest 4D CloudSwap dengan magnetic attachment. Cobalt SoftWeave Plus fabric atau NAPA leather. Tilt mechanism dengan kunci multi-posisi. Garansi 5 tahun. Weight capacity 130kg. Tersedia dalam berbagai kolaborasi: League of Legends, Batman, etc.',
        'price': 7999000,
        'discountPrice': 7499000,
        'images': [
          'https://images.unsplash.com/photo-1605902711622-cfb43c4437b5?w=500'
        ],
        'rating': 4.7,
        'reviewCount': 1234,
        'stock': 20,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    await _seedCollection('gaming', products);
  }
}
