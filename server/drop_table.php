<?php
try {
    $pdo = new PDO('mysql:host=127.0.0.1', 'root', 'JACK BA RA A');
    $pdo->exec('DROP TABLE IF EXISTS autohive.rental_applications');
    echo "Table dropped\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
