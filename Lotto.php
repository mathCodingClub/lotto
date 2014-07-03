<?php

require_once PATH_BITMCC . 'database/sql.php';

class Lotto {

  private $db = null;
  const databaseName = 'mcc_lotto';

  public function __construct() {
    $this->db = new \sql(self::databaseName);
    $this->db->setShowError(true);
  }

  public function get(){

    $query = $this->db->prepare("SELECT * FROM rivi WHERE pvm IN (SELECT max(pvm) FROM rivi)");

    $query->execute();

    $basic_numbers = [];
    $extra_numbers = [];
    $date = "";
    $round = 0;
    $year = 0;

    foreach($query as $row)
    {

      $basic = $row['varsiNroa'];
      $extra = $row['extraNroa'];
      $round = $row['kierros'];
      $year = $row['vuosi'];

      for($i = 1; $i <= $basic; $i++)
      {
        $nro = $row['num' . $i];
        if($nro != 0)
        {
          $basic_numbers[] = $nro;
        }
      }

      for($i = $basic+1; $i <= $basic+$extra; $i++)
      {
        $nro = $row['num' . $i];
        if($nro != 0)
        {
          $extra_numbers[] = $nro;
        }
      }

      $date = $row['pvm'];
      $date = date('d.m.Y', strtotime($date));
    }

    return "Correct row is: [ " . join(" ", $basic_numbers) . " + "
           . join(" ", $extra_numbers) . " ], cast on " . $date;
  }

  public function getLatestMatch($nro1,$nro2,$nro3,$nro4,$nro5,$nro6,$nro7){
return "not implemented yet, thanks for $nro1,$nro2,$nro3,$nro4,$nro5,$nro6,$nro7";
  }

}



?>
