<?php
/**
 * Created by PhpStorm.
 * User: Tian
 * Date: 16/8/15
 * Time: 下午7:16
 */

define('MYSQL_HOST', 'localhost');
define('MYSQL_USER', 'root');
define('MYSQL_PASSWORD', 'root');

function connectDataBase() {

    return mysqli_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, 'TIMI');

}

function userisexist($username) {
    $conndb = connectDataBase();
    $result = mysqli_query($conndb ,"SELECT * FROM `UserInfo` WHERE `username` = ('".$username."')");
    return mysqli_fetch_assoc($result);
}



