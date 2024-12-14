<?php
var_dump("work");
function loadEnv($filePath) {
    if (!file_exists($filePath)) {
        throw new Exception(".env file not found at $filePath");
    }

    $lines = file($filePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        // Пропускаем комментарии
        if (strpos(trim($line), '#') === 0) {
            continue;
        }

        // Разделяем по знаку "="
        [$name, $value] = explode('=', $line, 2);

        // Удаляем пробелы и кавычки
        $name = trim($name);
        $value = trim($value, " \t\n\r\0\x0B\"'");

        // Устанавливаем переменную окружения
        putenv("$name=$value");
        $_ENV[$name] = $value;
        $_SERVER[$name] = $value;
    }
}

// Загрузка переменных из .env файла
loadEnv(__DIR__ . '../.env');

// Использование переменных
$dbName = getenv('MYSQL_DATABASE');
$dbHost = getenv('MYSQL_USER_HOST');
$dbUser = getenv('MYSQL_USER');
$dbPassword = getenv('MYSQL_PASSWORD');
$charset = getenv('MYSQL_CHARSET');

$dsn = "mysql:host=$dbHost;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];

try {
    // Подключение к базе данных
    $pdo = new PDO($dsn, $dbUser, $dbPassword, $options);

    // Выполнение запроса
    $stmt = $pdo->query("SELECT * FROM test_table");

    // Отображение данных
    echo "<table border='1'>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Created At</th>
            </tr>";
    while ($row = $stmt->fetch()) {
        echo "<tr>
                <td>{$row['id']}</td>
                <td>{$row['name']}</td>
                <td>{$row['email']}</td>
                <td>{$row['created_at']}</td>
              </tr>";
    }
    echo "</table>";
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}