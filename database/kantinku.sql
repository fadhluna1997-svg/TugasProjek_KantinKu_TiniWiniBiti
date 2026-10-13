-- Database KantinKu untuk MySQL/MariaDB (import melalui phpMyAdmin)
CREATE DATABASE IF NOT EXISTS kantinku_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kantinku_db;

CREATE TABLE IF NOT EXISTS menu (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  kategori VARCHAR(50) NOT NULL,
  harga DECIMAL(12,2) NOT NULL DEFAULT 0,
  deskripsi TEXT,
  emoji VARCHAR(20) DEFAULT '🍽️',
  tersedia TINYINT(1) NOT NULL DEFAULT 1,
  dibuat_pada TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pesanan (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  nomor_antrean VARCHAR(10) NOT NULL UNIQUE,
  nama_pemesan VARCHAR(100) NOT NULL,
  catatan TEXT,
  total DECIMAL(12,2) NOT NULL DEFAULT 0,
  metode_pembayaran ENUM('Tunai','QRIS') NOT NULL DEFAULT 'Tunai',
  status_pembayaran ENUM('Belum dibayar','Lunas') NOT NULL DEFAULT 'Belum dibayar',
  status_pesanan ENUM('Menunggu pembayaran','Menunggu','Diproses','Selesai','Dibatalkan') NOT NULL DEFAULT 'Menunggu pembayaran',
  dibuat_pada TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS detail_pesanan (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  pesanan_id BIGINT NOT NULL,
  menu_id INT NULL,
  nama_menu VARCHAR(100) NOT NULL,
  harga_satuan DECIMAL(12,2) NOT NULL,
  jumlah INT NOT NULL DEFAULT 1,
  catatan_item VARCHAR(255),
  subtotal DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_detail_pesanan FOREIGN KEY (pesanan_id) REFERENCES pesanan(id) ON DELETE CASCADE,
  CONSTRAINT fk_detail_menu FOREIGN KEY (menu_id) REFERENCES menu(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS pembayaran (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  pesanan_id BIGINT NOT NULL,
  metode ENUM('Tunai','QRIS') NOT NULL,
  jumlah DECIMAL(12,2) NOT NULL,
  status ENUM('Menunggu','Berhasil','Gagal') NOT NULL DEFAULT 'Menunggu',
  referensi_transaksi VARCHAR(100) NULL,
  dibayar_pada DATETIME NULL,
  dibuat_pada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pembayaran_pesanan FOREIGN KEY (pesanan_id) REFERENCES pesanan(id) ON DELETE CASCADE
);

-- Contoh data awal menu; dapat diubah sesuai menu kantin sebenarnya.
INSERT INTO menu (nama, kategori, harga, deskripsi, emoji, tersedia) VALUES
('Nasi Goreng', 'Makanan', 15000, 'Nasi goreng hangat', '🍛', 1),
('Mie Goreng', 'Makanan', 12000, 'Mie goreng sederhana', '🍜', 1),
('Roti Bakar', 'Camilan', 10000, 'Roti bakar manis', '🍞', 1),
('Es Teh', 'Minuman', 5000, 'Teh dingin menyegarkan', '🧋', 1)
ON DUPLICATE KEY UPDATE nama=VALUES(nama);
