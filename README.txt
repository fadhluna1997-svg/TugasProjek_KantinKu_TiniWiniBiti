KANTINKU — PROTOTIPE PEMESANAN KANTIN

CARA MENJALANKAN DI XAMPP
1. Ekstrak folder KantinKu ke C:\xampp\htdocs\ sehingga alamat foldernya C:\xampp\htdocs\KantinKu\
2. Buka XAMPP Control Panel, lalu jalankan Apache dan MySQL.
3. Pastikan database kantinku_db dan tabel menu, pesanan, detail_pesanan, pembayaran sudah dibuat melalui phpMyAdmin.
4. Buka http://localhost/KantinKu/ di browser. Jangan membuka index.html dengan klik dua kali.
5. Jika akun MySQL berbeda dari bawaan XAMPP, edit api/koneksi.php (host, db, user, pass).

INTEGRASI DATABASE
- api/koneksi.php: koneksi PHP PDO ke MySQL.
- api/menu.php: mengambil menu aktif dari tabel menu.
- api/pesanan.php: menyimpan pesanan dan detail, membaca riwayat, memperbarui status, dan mencatat konfirmasi pembayaran.
- script.js mengambil menu dan riwayat pesanan dari API, jadi data pesanan tetap tersedia setelah halaman dimuat ulang.

PENTING
- Nama database harus kantinku_db.
- Struktur tabel harus sesuai database/kantinku.sql. Jika tabel dibuat dengan kolom berbeda, API perlu disesuaikan.
- Jika daftar menu kosong, tambahkan menu melalui phpMyAdmin ke tabel menu dengan tersedia = 1.
- Pembayaran QRIS pada prototipe ini masih simulasi. Tombol konfirmasi hanya mengubah status di database, bukan memverifikasi pembayaran sungguhan.
- Untuk proyek yang akan dipakai publik, tambahkan login/otorisasi penjual, validasi keamanan, dan integrasi payment gateway resmi.

FILE PROYEK
index.html — antarmuka
style.css — desain responsif
script.js — interaksi dan koneksi API
api/ — backend PHP
 database/kantinku.sql — skema dan contoh data
