<?php
require __DIR__ . '/koneksi.php';
try {
    $stmt = $pdo->query('SELECT id, nama, kategori, harga, deskripsi, emoji FROM menu WHERE tersedia = 1 ORDER BY id ASC');
    $rows = $stmt->fetchAll();
    $items = array_map(function ($m) {
        $category = $m['kategori'];
        // Menyesuaikan kategori contoh database dengan filter yang sudah ada di antarmuka.
        if ($category === 'Makanan') $category = 'Nasi';
        if ($category === 'Camilan') $category = 'Snack';
        return [
            'id' => (int)$m['id'],
            'name' => $m['nama'],
            'category' => $category,
            'price' => (float)$m['harga'],
            'desc' => $m['deskripsi'] ?? '',
            'emoji' => $m['emoji'] ?: '🍽️'
        ];
    }, $rows);
    echo json_encode(['success' => true, 'data' => $items], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Data menu gagal dibaca. Pastikan tabel menu sudah dibuat.']);
}
