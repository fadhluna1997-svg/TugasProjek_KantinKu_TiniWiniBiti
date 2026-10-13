<?php
require __DIR__ . '/koneksi.php';
header('Content-Type: application/json; charset=utf-8');
function respond($success, $message = '', $data = null, $code = 200) {
    http_response_code($code);
    echo json_encode(['success' => $success, 'message' => $message, 'data' => $data], JSON_UNESCAPED_UNICODE);
    exit;
}
function getOrders(PDO $pdo) {
    $orders = $pdo->query('SELECT * FROM pesanan ORDER BY dibuat_pada DESC, id DESC')->fetchAll();
    $detail = $pdo->prepare('SELECT menu_id AS id, nama_menu AS name, harga_satuan AS price, jumlah AS qty, catatan_item AS note, subtotal FROM detail_pesanan WHERE pesanan_id = ? ORDER BY id');
    foreach ($orders as &$o) {
        $detail->execute([$o['id']]);
        $o['items'] = $detail->fetchAll();
        foreach ($o['items'] as &$it) { $it['id'] = $it['id'] === null ? null : (int)$it['id']; $it['price'] = (float)$it['price']; $it['qty'] = (int)$it['qty']; }
        unset($it);
        $o['id'] = (int)$o['id'];
        $o['total'] = (float)$o['total'];
        $o['queue'] = $o['nomor_antrean'];
        $o['name'] = $o['nama_pemesan'];
        $o['note'] = $o['catatan'];
        $o['payment'] = $o['metode_pembayaran'];
        $o['paid'] = $o['status_pembayaran'] === 'Lunas';
        $o['paymentStatus'] = $o['status_pembayaran'];
        $o['status'] = $o['status_pesanan'];
        $o['time'] = date('H:i', strtotime($o['dibuat_pada']));
    }
    unset($o);
    return $orders;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try { respond(true, '', getOrders($pdo)); }
    catch (Throwable $e) { respond(false, 'Gagal membaca pesanan. Periksa struktur tabel database.', null, 500); }
}
if ($_SERVER['REQUEST_METHOD'] !== 'POST') respond(false, 'Metode permintaan tidak didukung.', null, 405);
$input = json_decode(file_get_contents('php://input'), true) ?? [];
$action = $input['action'] ?? 'create';

try {
    if ($action === 'update') {
        $id = (int)($input['id'] ?? 0);
        $status = $input['status'] ?? '';
        $allowed = ['Menunggu pembayaran', 'Menunggu', 'Diproses', 'Selesai', 'Dibatalkan'];
        if (!$id || !in_array($status, $allowed, true)) respond(false, 'Data perubahan status tidak valid.', null, 422);
        $stmt = $pdo->prepare('UPDATE pesanan SET status_pesanan = ? WHERE id = ?');
        $stmt->execute([$status, $id]);
        respond(true, 'Status pesanan diperbarui.');
    }
    if ($action === 'paid') {
        $id = (int)($input['id'] ?? 0);
        if (!$id) respond(false, 'Nomor pesanan tidak valid.', null, 422);
        $stmt = $pdo->prepare('SELECT metode_pembayaran, total FROM pesanan WHERE id = ?');
        $stmt->execute([$id]); $order = $stmt->fetch();
        if (!$order) respond(false, 'Pesanan tidak ditemukan.', null, 404);
        $pdo->beginTransaction();
        $pdo->prepare("UPDATE pesanan SET status_pembayaran = 'Lunas', status_pesanan = 'Menunggu' WHERE id = ?")->execute([$id]);
        $pdo->prepare("INSERT INTO pembayaran (pesanan_id, metode, jumlah, status, dibayar_pada) VALUES (?, ?, ?, 'Berhasil', NOW())")
            ->execute([$id, $order['metode_pembayaran'], $order['total']]);
        $pdo->commit();
        respond(true, 'Pembayaran ditandai lunas.');
    }
    // Buat pesanan baru dan simpan semua detail dalam satu transaksi.
    $name = trim((string)($input['name'] ?? ''));
    $note = trim((string)($input['note'] ?? ''));
    $payment = $input['payment'] ?? 'Tunai';
    $items = $input['items'] ?? [];
    if ($name === '' || !in_array($payment, ['Tunai', 'QRIS'], true) || !is_array($items) || count($items) === 0) respond(false, 'Nama, metode pembayaran, dan item pesanan wajib diisi.', null, 422);
    $pdo->beginTransaction();
    $cleanItems = []; $total = 0;
    $findMenu = $pdo->prepare('SELECT id, nama, harga FROM menu WHERE id = ? AND tersedia = 1');
    foreach ($items as $item) {
        $menuId = (int)($item['id'] ?? 0); $qty = max(1, min(99, (int)($item['qty'] ?? 1)));
        $findMenu->execute([$menuId]); $m = $findMenu->fetch();
        if (!$m) throw new RuntimeException('Salah satu menu tidak tersedia. Muat ulang halaman dan coba lagi.');
        $price = (float)$m['harga']; $subtotal = $price * $qty; $total += $subtotal;
        $cleanItems[] = ['id' => (int)$m['id'], 'name' => $m['nama'], 'price' => $price, 'qty' => $qty, 'note' => substr(trim((string)($item['note'] ?? '')), 0, 255), 'subtotal' => $subtotal];
    }
    $queue = 'K' . date('ymd') . '-' . strtoupper(substr(bin2hex(random_bytes(2)), 0, 4));
    $status = 'Menunggu pembayaran';
    $stmt = $pdo->prepare('INSERT INTO pesanan (nomor_antrean, nama_pemesan, catatan, total, metode_pembayaran, status_pembayaran, status_pesanan) VALUES (?, ?, ?, ?, ?, ?, ?)');
    $stmt->execute([$queue, substr($name, 0, 100), $note, $total, $payment, 'Belum dibayar', $status]);
    $orderId = (int)$pdo->lastInsertId();
    $detail = $pdo->prepare('INSERT INTO detail_pesanan (pesanan_id, menu_id, nama_menu, harga_satuan, jumlah, catatan_item, subtotal) VALUES (?, ?, ?, ?, ?, ?, ?)');
    foreach ($cleanItems as $item) $detail->execute([$orderId, $item['id'], $item['name'], $item['price'], $item['qty'], $item['note'], $item['subtotal']]);
    $pdo->prepare("INSERT INTO pembayaran (pesanan_id, metode, jumlah, status) VALUES (?, ?, ?, 'Menunggu')")->execute([$orderId, $payment, $total]);
    $pdo->commit();
    respond(true, 'Pesanan berhasil disimpan.', ['id' => $orderId, 'queue' => $queue, 'total' => $total]);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    $msg = $e instanceof RuntimeException ? $e->getMessage() : 'Pesanan gagal disimpan. Pastikan struktur tabel database sesuai file kantinku.sql.';
    respond(false, $msg, null, 500);
}
