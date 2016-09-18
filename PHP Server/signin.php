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

$conndb = connectDataBase();
$data = userisexist($username);

//print_r($data);
if ($data['username'] == $username && $data['password'] == $password) {
    echo '登录成功';
}
else {
    echo '用户名或密码错误';
}