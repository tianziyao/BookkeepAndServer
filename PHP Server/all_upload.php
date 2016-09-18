<?php
/**
 * Created by PhpStorm.
 * User: Tian
 * Date: 16/9/5
 * Time: 下午6:43
 */

require_once 'connectdatabase.php';
?>

<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>记账记录</title>
</head>
<body>

<table width="70%"><tr><th>ID</th><th>iconName</th><th>iconTitle</th><th>money</th><th>date</th></tr>

    <?php

    $coon = connectDataBase();
    $data_count = mysqli_fetch_array(mysqli_query($coon, 'SELECT COUNT(*) FROM Account'));
    $sql = "SELECT * FROM `Account`" . "ORDER BY `Account`.`ID` ASC";
    $result = mysqli_query($coon, $sql);

    for ($i=0; $i<$data_count[0]; $i++) {

        $data = mysqli_fetch_assoc($result);
        $ID = $data['ID'];
        $iconName = $data['iconName'];
        $iconTitle = $data['iconTitle'];
        $money = $data['money'];
        $date = $data['date'];

        echo "<tr><td>$ID</td><td>$iconName</td><td>$iconTitle</td><td>$money</td><td>$date</td></tr>";
    }

    ?>
</table>
</body>
</html>