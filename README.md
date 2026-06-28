# MySaku — Kelola Keuangan, Wujudkan Impian ✨

<div align="center">
  <img src="assets/logo_mysaku.png" alt="MySaku Logo" width="120" />
  <h3>Aplikasi Manajemen Keuangan & Target Impian Bersama secara Real-Time</h3>
</div>

---

**MySaku** adalah aplikasi pelacakan keuangan harian dan perencanaan target menabung (impian) modern yang dirancang untuk individu, pasangan, maupun keluarga. Dengan dukungan kolaborasi dompet secara real-time, Anda dapat mencatat pemasukan dan pengeluaran bersama serta mewujudkan impian finansial dengan lebih mudah dan terarah.

---

## 🌟 Fitur Utama

### 🔐 1. Autentikasi & Keamanan Akun
- **Login & Register Multi-Metode**: Dukungan pendaftaran menggunakan Email & Password serta **Google Sign-In** yang cepat dan aman.
- **Show/Hide Password Toggle**: Kolom kata sandi dilengkapi dengan ikon mata (*eye / eye slash*) interaktif untuk memudahkan pengecekan saat mengetik.
- **Sistem Undangan Kolaborasi**: Pengguna baru yang mendaftar melalui undangan otomatis terhubung langsung ke dompet/tabungan kolaboratif pengundang.

### 💰 2. Pencatatan Keuangan Harian
- **Pencatatan Pemasukan & Pengeluaran**: Input transaksi dengan mudah disertai nominal, kategori, tanggal, dan catatan tambahan.
- **Kalkulasi Saldo Otomatis**: Menampilkan total saldo, total pemasukan, dan total pengeluaran secara akurat dan real-time.
- **Manajemen Kategori Kustom**: Kategori transaksi yang fleksibel dan dapat dikelola sesuai kebutuhan gaya hidup Anda.

### 📊 3. Riwayat Transaksi Terperinci
- **Daftar Riwayat Keuangan**: Semua aliran dana masuk dan keluar tercatat rapi berdasarkan waktu.
- **Filter & Detail Transaksi**: Memudahkan penelusuran histori keuangan untuk analisis pengeluaran bulanan.

### 🎯 4. Target Impian (Dream Planner)
- **Tabungan Impian Bersama**: Buat target menabung untuk liburan, beli barang impian, atau dana darurat bersama pasangan/keluarga.
- **Indikator Progress Visual**: Pantau persentase pencapaian target secara langsung seiring bertambahnya tabungan.

### ⏰ 5. Pengingat Harian (Daily Reminders)
- **Notifikasi Lokal Pintar**: Pengingat harian agar Anda tidak lupa mencatat pengeluaran harian.
- **Dukungan Auto-Boot**: Jadwal pengingat otomatis tetap aktif dan terjadwal ulang setelah perangkat ponsel di-reboot.

### 🎨 6. Antarmuka Premium & Modern
- **Desain Elegan**: Dilengkapi dengan latar belakang gradien premium, kartu antarmuka modern (*glassmorphism & card layout*), serta tipografi bersih.
- **Responsif & Cepat**: Dibangun dengan standar performa tinggi untuk kenyamanan penggunaan sehari-hari.

---

## 🛠️ Teknologi & Tech Stack

Proyek ini dibangun menggunakan teknologi modern untuk menjamin keandalan, skalabilitas, dan performa tinggi:

| Kategori | Teknologi / Library | Kegunaan |
| :--- | :--- | :--- |
| **Framework Utama** | [Flutter](https://flutter.dev/) (Dart 3) | Pengembangan aplikasi mobile lintas platform |
| **State Management** | `flutter_riverpod` (^2.6.1) | Manajemen state yang aman, reaktif, dan terstruktur |
| **Navigasi & Routing** | `go_router` (^14.8.0) | Declarative routing & deep linking |
| **Backend & Cloud** | Firebase Core & Auth | Layanan autentikasi pengguna (Email & Google) |
| **Database Real-time** | Cloud Firestore | Penyimpanan data transaksi & dompet secara sinkron |
| **Local Notifications** | `flutter_local_notifications` | Penjadwalan notifikasi pengingat harian |
| **Timezone Management**| `timezone` & `flutter_timezone` | Penyesuaian waktu notifikasi lokal secara akurat |
| **UI & Tipografi** | `google_fonts`, `shimmer`, `gap` | Komponen visual modern dan animasi pemuatan |
| **Local Storage** | `shared_preferences` | Penyimpanan preferensi & sesi pengguna lokal |

---

## 🚀 Cara Menjalankan Proyek (Local Development)

### 1. Prasyarat
Pastikan Anda telah menginstal:
- Flutter SDK (^3.11.1 atau terbaru)
- Android Studio / VS Code
- Emulator Android atau perangkat fisik

### 2. Langkah Instalasi
Clone repositori dan pasang dependensi:
```bash
git clone https://github.com/ardhikaxx/mysaku-app.git
cd mysaku-app
flutter pub get
```

### 3. Menjalankan Aplikasi
Untuk menjalankan aplikasi di emulator atau perangkat lunak dalam mode debug:
```bash
flutter run
```

Untuk membuat build APK Release:
```bash
flutter build apk --release
```

---

<div align="center">
  <p>Dibuat dengan ❤️ untuk kemudahan pengelolaan finansial Anda.</p>
</div>
