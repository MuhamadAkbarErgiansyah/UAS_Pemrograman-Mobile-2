
## DEMO APLIKASI
![abay](https://github.com/user-attachments/assets/12c92fca-1d38-4e88-9037-5a2e483961fc)



# 🛒 ShopZone - E-Commerce Mobile App

Aplikasi E-Commerce modern yang dibangun dengan Flutter untuk memenuhi tugas **UAS Pemrograman Mobile 2**.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

---

## ✨ Fitur Aplikasi

### 👤 User Features
- **Autentikasi**
  - Login dengan Email & Password
  - Login dengan Google
  - Register akun baru
  - Forgot Password
  - Biometric Authentication (Fingerprint/Face ID)
  
- **Beranda**
  - Banner promo carousel
  - Kategori produk
  - Produk unggulan
  - Search produk
  
- **Produk**
  - Daftar produk berdasarkan kategori
  - Detail produk lengkap
  - Galeri gambar produk
  - Rating & review
  
- **Keranjang & Checkout**
  - Tambah/hapus produk ke keranjang
  - Update quantity
  - Pilih alamat pengiriman
  - Pilih metode pembayaran (COD, Transfer Bank, E-Wallet)
  - Input voucher diskon
  
- **Wishlist**
  - Simpan produk favorit
  - Sync dengan Firestore
  
- **Pesanan**
  - Riwayat pesanan
  - Detail pesanan
  - Tracking status pesanan
  
- **Profil**
  - Lihat informasi profil
  - Kelola alamat pengiriman
  
- **Chat**
  - Live chat dengan admin
  - Real-time messaging

### 👨‍💼 Admin Features
- **Dashboard**
  - Statistik penjualan
  - Total pendapatan
  - Jumlah pesanan & pengguna
  
- **Manajemen Produk**
  - Tambah produk baru
  - Edit produk
  - Hapus produk
  - Upload gambar produk
  
- **Manajemen Pesanan**
  - Lihat semua pesanan
  - Update status pesanan (Pending → Confirmed → Processing → Shipped → Delivered)
  
- **Chat Pelanggan**
  - Balas chat dari pelanggan
  - Real-time notification
  
- **Manajemen Pengguna**
  - Lihat daftar pengguna
  - Filter user/admin
  
- **Analitik**
  - Grafik penjualan
  - Produk terlaris
  - Statistik pendapatan

---

## 🔧 Teknologi & API

### Backend Services

| Service | Kegunaan |
|---------|----------|
| **Firebase Authentication** | Autentikasi user (Email/Password, Google Sign-In) |
| **Cloud Firestore** | Database NoSQL untuk menyimpan data (users, products, orders, chats, dll) |
| **Supabase Storage** | Penyimpanan file/gambar (avatar user, gambar produk) |

### Firebase Collections Structure

```
📁 Firestore Database
├── 📂 users
│   └── {userId}
│       ├── email
│       ├── displayName
│       ├── photoUrl
│       ├── phone
│       ├── isAdmin
│       └── createdAt
│
├── 📂 products
│   └── {productId}
│       ├── name
│       ├── description
│       ├── price
│       ├── images[]
│       ├── category
│       ├── stock
│       ├── rating
│       └── reviewCount
│
├── 📂 orders
│   └── {orderId}
│       ├── userId
│       ├── items[]
│       ├── totalAmount
│       ├── status
│       ├── shippingAddress
│       ├── paymentMethod
│       └── createdAt
│
├── 📂 carts
│   └── {userId}
│       └── items[]
│
├── 📂 wishlists
│   └── {documentId}
│       ├── userId
│       └── productId
│
├── 📂 chats
│   └── {chatId}
│       ├── participants[]
│       ├── lastMessage
│       └── updatedAt
│
├── 📂 messages
│   └── {messageId}
│       ├── chatId
│       ├── senderId
│       ├── text
│       └── timestamp
│
├── 📂 addresses
│   └── {addressId}
│       ├── userId
│       ├── recipientName
│       ├── phone
│       ├── streetAddress
│       ├── city
│       ├── state
│       ├── postalCode
│       └── isDefault
│
└── 📂 vouchers
    └── {voucherId}
        ├── code
        ├── discountPercent
        ├── minPurchase
        ├── maxDiscount
        ├── validFrom
        ├── validUntil
        └── isActive
```

### Supabase Storage Buckets

```
📁 Supabase Storage
├── 📂 avatars/          # Foto profil user
│   └── {userId}.jpg
│
└── 📂 products/         # Gambar produk
    └── {productId}/
        └── {imageId}.jpg
```

---

## 📁 Struktur Folder Project

```
lib/
├── main.dart                    # Entry point aplikasi
├── firebase_options.dart        # Konfigurasi Firebase
│
├── config/                      # Konfigurasi aplikasi
│
├── core/                        # Core utilities
│   ├── constants/
│   │   ├── app_colors.dart      # Warna tema aplikasi
│   │   ├── app_sizes.dart       # Ukuran standar
│   │   ├── app_strings.dart     # String constants (EN)
│   │   └── app_strings_id.dart  # String constants (ID)
│   │
│   ├── themes/
│   │   └── app_theme.dart       # Light & Dark theme
│   │
│   └── utils/
│       ├── formatters.dart      # Format currency, date, dll
│       ├── helpers.dart         # Helper functions
│       └── validators.dart      # Form validators
│
├── data/
│   └── models/                  # Data models
│       ├── user_model.dart
│       ├── product_model.dart
│       ├── order_model.dart
│       ├── cart_item_model.dart
│       ├── address_model.dart
│       ├── chat_model.dart
│       ├── category_model.dart
│       └── voucher_model.dart
│
├── providers/                   # State management (Provider)
│   ├── auth_provider.dart       # Authentication state
│   ├── cart_provider.dart       # Shopping cart state
│   ├── product_provider.dart    # Products state
│   └── wishlist_provider.dart   # Wishlist state
│
├── services/                    # Backend services
│   ├── auth_service.dart        # Firebase Auth operations
│   ├── firestore_service.dart   # Firestore CRUD operations
│   ├── storage_service.dart     # Supabase Storage operations
│   ├── chat_service.dart        # Chat functionality
│   ├── order_service.dart       # Order management
│   ├── voucher_service.dart     # Voucher management
│   ├── session_service.dart     # Session management
│   ├── biometric_service.dart   # Biometric auth
│   └── seed_products.dart       # Seed sample data
│
├── screens/                     # UI Screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── admin_login_screen.dart
│   │
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── main_screen.dart
│   │
│   ├── product/
│   │   ├── product_detail_screen.dart
│   │   └── products_list_screen.dart
│   │
│   ├── cart/
│   │   └── cart_screen.dart
│   │
│   ├── checkout/
│   │   └── checkout_screen.dart
│   │
│   ├── wishlist/
│   │   └── wishlist_screen.dart
│   │
│   ├── orders/
│   │   ├── orders_screen.dart
│   │   └── order_detail_screen.dart
│   │
│   ├── profile/
│   │   └── profile_screen.dart
│   │
│   ├── address/
│   │   ├── addresses_screen.dart
│   │   └── add_address_screen.dart
│   │
│   ├── chat/
│   │   └── user_chat_screen.dart
│   │
│   ├── search/
│   │   └── search_screen.dart
│   │
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   │
│   └── admin/
│       ├── admin_main_screen.dart
│       ├── admin_dashboard_screen.dart
│       ├── admin_products_screen.dart
│       ├── add_product_screen.dart
│       ├── admin_orders_screen.dart
│       ├── admin_chats_screen.dart
│       ├── admin_chat_detail_screen.dart
│       ├── admin_users_screen.dart
│       └── admin_analytics_screen.dart
│
└── widgets/                     # Reusable widgets
    ├── common/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   ├── loading_indicator.dart
    │   └── empty_state.dart
    │
    ├── product/
    │   └── product_card.dart
    │
    └── cart/
        └── cart_item_tile.dart
```

---

## 🚀 Cara Menjalankan Project

### Prerequisites
- Flutter SDK (>=3.6.0)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Supabase account

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/MuhamadAkbarErgiansyah/UAS_Pemrograman-Mobile-2.git
   cd UAS_Pemrograman-Mobile-2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Buat project di [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password & Google)
   - Enable Cloud Firestore
   - Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
   - Jalankan `flutterfire configure`

4. **Setup Supabase**
   - Buat project di [Supabase](https://supabase.com)
   - Buat bucket storage: `avatars` dan `products`
   - Set bucket policy ke public
   - Copy URL dan Anon Key ke `lib/main.dart`

5. **Run aplikasi**
   ```bash
   # Android/iOS
   flutter run
   
   # Web
   flutter run -d chrome
   ```

### Build untuk Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 📦 Dependencies

| Package | Version | Kegunaan |
|---------|---------|----------|
| firebase_core | ^3.9.0 | Firebase initialization |
| firebase_auth | ^5.4.1 | Authentication |
| cloud_firestore | ^5.6.0 | NoSQL Database |
| supabase_flutter | ^2.8.3 | Storage & Realtime |
| provider | ^6.1.2 | State management |
| google_sign_in | ^6.2.2 | Google OAuth |
| local_auth | ^2.3.0 | Biometric auth |
| google_fonts | ^6.2.1 | Custom fonts |
| cached_network_image | ^3.4.1 | Image caching |
| carousel_slider | ^5.0.0 | Banner carousel |
| flutter_animate | ^4.5.2 | Animations |
| image_picker | ^1.1.2 | Pick images |
| intl | ^0.20.2 | Internationalization |
| shared_preferences | ^2.3.5 | Local storage |

---

## 👨‍💻 Developer

**Muhamad Akbar Ergiansyah**

- GitHub: [@MuhamadAkbarErgiansyah](https://github.com/MuhamadAkbarErgiansyah)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## LAMPIRAN
https://incandescent-bunny-d85809.netlify.app/



---

⭐ **Jika project ini bermanfaat, jangan lupa beri bintang!** ⭐
