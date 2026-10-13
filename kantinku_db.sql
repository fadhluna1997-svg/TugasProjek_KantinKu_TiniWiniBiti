-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 13, 2026 at 05:46 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `kantinku_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `detail_pesanan`
--

CREATE TABLE `detail_pesanan` (
  `id` bigint(20) NOT NULL,
  `pesanan_id` bigint(20) NOT NULL,
  `menu_id` int(11) DEFAULT NULL,
  `nama_menu` varchar(100) NOT NULL,
  `harga_satuan` decimal(12,2) NOT NULL,
  `jumlah` int(11) NOT NULL DEFAULT 1,
  `catatan_item` varchar(255) DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `detail_pesanan`
--

INSERT INTO `detail_pesanan` (`id`, `pesanan_id`, `menu_id`, `nama_menu`, `harga_satuan`, `jumlah`, `catatan_item`, `subtotal`) VALUES
(1, 1, 1, 'Nasi Goreng', 15000.00, 1, '', 15000.00);

-- --------------------------------------------------------

--
-- Table structure for table `menu`
--

CREATE TABLE `menu` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `kategori` varchar(50) NOT NULL,
  `harga` decimal(12,2) NOT NULL DEFAULT 0.00,
  `deskripsi` text DEFAULT NULL,
  `emoji` varchar(20) DEFAULT '?️',
  `tersedia` tinyint(1) NOT NULL DEFAULT 1,
  `dibuat_pada` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `menu`
--

INSERT INTO `menu` (`id`, `nama`, `kategori`, `harga`, `deskripsi`, `emoji`, `tersedia`, `dibuat_pada`) VALUES
(1, 'Nasi Goreng', 'Makanan', 15000.00, 'Nasi goreng hangat', '🍛', 1, '2026-10-13 03:26:48'),
(2, 'Mie Goreng', 'Makanan', 12000.00, 'Mie goreng sederhana', '🍜', 1, '2026-10-13 03:26:48'),
(3, 'Roti Bakar', 'Camilan', 10000.00, 'Roti bakar manis', '🍞', 1, '2026-10-13 03:26:48'),
(4, 'Es Teh', 'Minuman', 5000.00, 'Teh dingin menyegarkan', '🧋', 1, '2026-10-13 03:26:48');

-- --------------------------------------------------------

--
-- Table structure for table `pembayaran`
--

CREATE TABLE `pembayaran` (
  `id` bigint(20) NOT NULL,
  `pesanan_id` bigint(20) NOT NULL,
  `metode` enum('Tunai','QRIS') NOT NULL,
  `jumlah` decimal(12,2) NOT NULL,
  `status` enum('Menunggu','Berhasil','Gagal') NOT NULL DEFAULT 'Menunggu',
  `referensi_transaksi` varchar(100) DEFAULT NULL,
  `dibayar_pada` datetime DEFAULT NULL,
  `dibuat_pada` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pembayaran`
--

INSERT INTO `pembayaran` (`id`, `pesanan_id`, `metode`, `jumlah`, `status`, `referensi_transaksi`, `dibayar_pada`, `dibuat_pada`) VALUES
(1, 1, 'Tunai', 15000.00, 'Menunggu', NULL, NULL, '2026-10-13 03:40:38'),
(2, 1, 'Tunai', 15000.00, 'Berhasil', NULL, '2026-10-13 10:40:52', '2026-10-13 03:40:52');

-- --------------------------------------------------------

--
-- Table structure for table `pesanan`
--

CREATE TABLE `pesanan` (
  `id` bigint(20) NOT NULL,
  `nomor_antrean` varchar(10) NOT NULL,
  `nama_pemesan` varchar(100) NOT NULL,
  `catatan` text DEFAULT NULL,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `metode_pembayaran` enum('Tunai','QRIS') NOT NULL DEFAULT 'Tunai',
  `status_pembayaran` enum('Belum dibayar','Lunas') NOT NULL DEFAULT 'Belum dibayar',
  `status_pesanan` enum('Menunggu pembayaran','Menunggu','Diproses','Selesai','Dibatalkan') NOT NULL DEFAULT 'Menunggu pembayaran',
  `dibuat_pada` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pesanan`
--

INSERT INTO `pesanan` (`id`, `nomor_antrean`, `nama_pemesan`, `catatan`, `total`, `metode_pembayaran`, `status_pembayaran`, `status_pesanan`, `dibuat_pada`) VALUES
(1, 'K261013-C1', 'luna', '-', 15000.00, 'Tunai', 'Lunas', 'Diproses', '2026-10-13 03:40:38');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `detail_pesanan`
--
ALTER TABLE `detail_pesanan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pesanan_id` (`pesanan_id`),
  ADD KEY `menu_id` (`menu_id`);

--
-- Indexes for table `menu`
--
ALTER TABLE `menu`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pesanan_id` (`pesanan_id`);

--
-- Indexes for table `pesanan`
--
ALTER TABLE `pesanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nomor_antrean` (`nomor_antrean`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `detail_pesanan`
--
ALTER TABLE `detail_pesanan`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `menu`
--
ALTER TABLE `menu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `pembayaran`
--
ALTER TABLE `pembayaran`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `pesanan`
--
ALTER TABLE `pesanan`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `detail_pesanan`
--
ALTER TABLE `detail_pesanan`
  ADD CONSTRAINT `detail_pesanan_ibfk_1` FOREIGN KEY (`pesanan_id`) REFERENCES `pesanan` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `detail_pesanan_ibfk_2` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD CONSTRAINT `pembayaran_ibfk_1` FOREIGN KEY (`pesanan_id`) REFERENCES `pesanan` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
