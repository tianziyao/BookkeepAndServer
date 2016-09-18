<?php
/**
 * Created by PhpStorm.
 * User: Tian
 * Date: 16/9/1
 * Time: 上午1:32
 */

//@file phpinput_server.php
$raw_post_data = file_get_contents('php://input', 'r');
//echo "-------\$_POST------------------\n";
//echo var_dump($_POST) . "\n";
//echo "-------php://input-------------\n";
//echo $raw_post_data . "\n";
$data_arr = json_decode($raw_post_data);
//print_r($data_arr);
//print_r($data_arr[0]->ID) ;
//echo "--------------\n";
//echo  $data_arr[0]->ID;

require_once 'connectdatabase.php';
$conndb = connectDataBase();

if ($conndb) {

    for ($i=0; $i<count($data_arr); $i++) {

        $ID = $data_arr[$i]->ID;
        $iconName = $data_arr[$i]->iconName;
        $iconTitle = $data_arr[$i]->iconTitle;
        $money = $data_arr[$i]->money;
        $date = date('Y-m-d',$data_arr[$i]->date);
        $remark = $data_arr[$i]->remark;
        $photo = $data_arr[$i]->photo;
        $dateString = $data_arr[$i]->dateString;
        $dayCost = $data_arr[$i]->dayCost;

        $insert_sql = "INSERT INTO `TIMI`.`Account` (`ID`, `iconName`, `iconTitle`, `money`, `date`, `remark`, `photo`, `dateString`, `dayCost`) VALUES ('$ID', '$iconName', '$iconTitle', '$money', '$date', '$remark', '$photo', '$dateString', '$dayCost')";
        $result = mysqli_query($conndb ,$insert_sql);
    }

    echo "写入成功";
}
else {
    die('数据库未成功连接');
}
