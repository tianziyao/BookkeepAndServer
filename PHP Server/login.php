<?php
/**
 * Created by PhpStorm.
 * User: Tian
 * Date: 16/9/1
 * Time: 上午1:06
 */

require_once 'connectdatabase.php';

$username = $_POST['username'];
$password = $_POST['password'];
$useremail = $_POST['useremail'];

$conndb = connectDataBase();
$data = userisexist($username);

//print_r($data);
if ($data) {
    echo '用户名已存在';
}
else {
    $resultmodel = "INSERT INTO `TIMI`.`UserInfo` (`username`, `password`, `userid`, `useremail`) VALUES (('".$username."'), ('".$username."'), NULL, ('".$username."'))";
    $result = mysqli_query($conndb ,$resultmodel);
    if (mysqli_error()) {
        echo mysqli_error();
    }
    else {
        echo '注册成功';
    }
}

