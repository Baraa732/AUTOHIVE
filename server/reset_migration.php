<?php
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=autohive', 'root', 'JACK BA RA A');
    $pdo->exec("DELETE FROM migrations WHERE migration = '2025_12_27_103000_create_rental_applications_table'");
    echo "Migration record deleted\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
