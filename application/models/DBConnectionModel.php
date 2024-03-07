<?php

class DBConnectionModel
{
	public function __construct()
	{
		// constructor
	}

	public function mysqlConn()
	{
		$db = 'umuttepe_turizm';
		$server = "localhost";
		$username = "root";
		$password = "";

		$link_mysql = mysqli_connect($server, $username, $password, $db);
		if (mysqli_connect_errno()) {
			die(print_r("Bağlantı Hatası: " . mysqli_connect_errno(), true));
		}
		mysqli_query($link_mysql, "SET NAMES 'utf8'");
		mysqli_query($link_mysql, "SET CHARACTER SET 'utf8_turkish_ci'");
		mysqli_query($link_mysql, "COLLATE 'utf8_turkish_ci'");
		return $link_mysql;
	}
	public function  createTicket($busRouteId,$contactFullName,$contactTel,$cartFullName,$cartNo,$cartMonth,$cartYear,$cartCvc,$price){
		$link_mysql = $this->mysqlConn();

		// Türkiye saatiyle ilgili zaman dilimini ayarla
		date_default_timezone_set('Europe/Istanbul');

		// Plaka Kodunu Çekme
		$query = "SELECT c.plate_code, br.departure_time, br.bus_plate_code FROM bus_routes AS br
				  INNER JOIN cities AS c ON br.from_city_id = c.id
				  WHERE br.id = $busRouteId";
		$result = mysqli_query($link_mysql, $query);
		$row = mysqli_fetch_assoc($result);
		$plateCode = $row['plate_code'];


		// Öğleden Önce veya Sonra Bilgisini Belirleme
		$departureTime = $row['departure_time'];
		$timeOfDay = (date('H', strtotime($departureTime)) < 12) ? "ÖÖ" : "ÖS";

		// Bilet Satış Zamanını Oluşturma
		$saleTime = date('dmYHis');

		// Peron Numarasını Oluşturma
		$peronNumarasi = chr(rand(65, 90)); // A'dan Z'ye rastgele bir harf seçme

		// Seferi Yapan Otobüsün Plakasını Alma
		$busPlateCode = $row['bus_plate_code'];

		// PNR Kodunu Oluşturma
		$pnr = $plateCode . $timeOfDay . $saleTime . $peronNumarasi . $busPlateCode;

		$query = "INSERT INTO tickets (bus_route_id, contact_full_name, contact_tel, cart_no, cart_full_name, cart_month, cart_year, cart_cvc, price, status,pnr, created_at)
		VALUES ($busRouteId, '$contactFullName', '$contactTel','$cartNo', '$cartFullName', '$cartMonth', '$cartYear', '$cartCvc', $price , 1, '$pnr',CURRENT_TIMESTAMP)";

		mysqli_query($link_mysql, $query);

		return mysqli_insert_id($link_mysql);

		mysqli_close($link_mysql);
	}

	public function createPassenger($ticketId,$passengerName,$passengerSurname,$passengerTc,$passengeSelector,$seatNumber){
		$link_mysql = $this->mysqlConn();

		$query = "INSERT INTO passenger (ticket_id, passenger_name, passenger_surname, passenger_tc, passenger_gender,seat_number,created_at)
		VALUES ($ticketId, '$passengerName', '$passengerSurname','$passengerTc', $passengeSelector,$seatNumber, CURRENT_TIMESTAMP)";

		$result = mysqli_query($link_mysql, $query);

		mysqli_close($link_mysql);

		return $result;
	}

	public function changeSeatAvailability($busRouteId,$seatNumber,$status){
		$link_mysql = $this->mysqlConn();

		$query = "UPDATE seat_availability SET  seat_status = $status WHERE bus_route_id = $busRouteId AND seat_number = $seatNumber";

		$result = mysqli_query($link_mysql, $query);

		mysqli_close($link_mysql);

		return $result;
	}

	public function  getBusRoute($id){
		$link_mysql = $this->mysqlConn();
		$query = "SELECT br.*, from_city.name AS from_city_name, to_city.name AS to_city_name
              FROM bus_routes AS br
              INNER JOIN cities AS from_city ON br.from_city_id = from_city.id
              INNER JOIN cities AS to_city ON br.to_city_id = to_city.id
              WHERE br.id = $id";

		$result = mysqli_query($link_mysql, $query);

		$data = mysqli_fetch_assoc($result);
		mysqli_close($link_mysql);

		return $data;
	}
	public function getBusRoutesWithSeats($fromCityId, $toCityId, $departureDate)
	{
		$link_mysql = $this->mysqlConn();

		$query = "SELECT br.*, from_city.name AS from_city_name, to_city.name AS to_city_name , from_city.plate_code AS plate_code
              FROM bus_routes AS br
              INNER JOIN cities AS from_city ON br.from_city_id = from_city.id
              INNER JOIN cities AS to_city ON br.to_city_id = to_city.id
              WHERE br.from_city_id = $fromCityId AND br.to_city_id = $toCityId
              AND DATE(br.departure_time) = '$departureDate'
              ORDER BY br.departure_time ASC";

		$result = mysqli_query($link_mysql, $query);

		$busRoutes = array();
		while ($row = mysqli_fetch_assoc($result)) {
			$query2 = "SELECT *
              FROM seat_availability WHERE bus_route_id = '".$row['id']."'" ;
			$result2 = mysqli_query($link_mysql, $query2);

			$seats = array();
			while ($row2 = mysqli_fetch_assoc($result2)) {
				$seats[] = $row2;
			}
			$busRoutes[] = array(
				'bus' => $row,
				'seat' => $seats
			);
		}

		mysqli_close($link_mysql);

		return $busRoutes;
	}

	public function getBus()
	{
		$link_mysql = $this->mysqlConn();

		$query = "SELECT br.*, from_city.name AS from_city_name, to_city.name AS to_city_name , from_city.plate_code AS plate_code
              FROM bus_routes AS br
              INNER JOIN cities AS from_city ON br.from_city_id = from_city.id
              INNER JOIN cities AS to_city ON br.to_city_id = to_city.id
              ORDER BY br.departure_time ASC";

		$result = mysqli_query($link_mysql, $query);

		$busRoutes = array();
		while ($row = mysqli_fetch_assoc($result)) {
			$busRoutes[] = $row;
		}

		mysqli_close($link_mysql);

		return $busRoutes;
	}

	public function getCities()
	{
		$link_mysql = $this->mysqlConn();

		$query = "SELECT * FROM cities";
		$result = mysqli_query($link_mysql, $query);

		$cities = array();
		while ($row = mysqli_fetch_assoc($result)) {
			$cities[] = $row;
		}

		mysqli_close($link_mysql);

		return $cities;
	}

	public function getUserInfo($id)
	{
		$link_mysql = $this->mysqlConn();

		$query = "SELECT * FROM account WHERE id=$id AND isActive = 1";
		$result = mysqli_query($link_mysql, $query);

		$data = mysqli_fetch_assoc($result);
		mysqli_close($link_mysql);

		return $data;
	}

	public function checkLogin($email, $password)
	{
		$link_mysql = $this->mysqlConn();

		$email = mysqli_real_escape_string($link_mysql, $email);
		$password = mysqli_real_escape_string($link_mysql, $password);

		$query = "SELECT id, email, fullName FROM account WHERE email = '$email' AND password = '$password' AND isActive = 1";
		$result = mysqli_query($link_mysql, $query);

		if ($result && mysqli_num_rows($result) == 1) {
			return mysqli_fetch_assoc($result);
		} else {
			return false;
		}

		mysqli_close($link_mysql);
	}

	public function updateUserInfo($id, $fullName, $tcKimlikNo, $email, $tel, $gender, $birthDate)
	{
		$link_mysql = $this->mysqlConn();

		$id = mysqli_real_escape_string($link_mysql, $id);
		$fullName = mysqli_real_escape_string($link_mysql, $fullName);
		$tcKimlikNo = mysqli_real_escape_string($link_mysql, $tcKimlikNo);
		$email = mysqli_real_escape_string($link_mysql, $email);
		$tel = mysqli_real_escape_string($link_mysql, $tel);
		$gender = mysqli_real_escape_string($link_mysql, $gender);
		$birthDate = mysqli_real_escape_string($link_mysql, $birthDate);

		$query = "UPDATE account SET fullName = '$fullName', tcKimlikNo = '$tcKimlikNo', email = '$email', tel = '$tel', gender = '$gender', birthDate = '$birthDate' WHERE id = $id";
		$result = mysqli_query($link_mysql, $query);

		if ($result) {
			return true;
		} else {
			return false;
		}

		mysqli_close($link_mysql);
	}

	public function updateUserPassword($id, $newPassword)
	{
		$link_mysql = $this->mysqlConn();

		$query = "UPDATE account SET password = '$newPassword' WHERE id = $id";
		$result = mysqli_query($link_mysql, $query);

		if ($result) {
			return true;
		} else {
			return false;
		}
		mysqli_close($link_mysql);
	}
	public function setBusPlateCode($plate,$id)
	{
		$link_mysql = $this->mysqlConn();

		$query = "UPDATE bus_routes SET bus_plate_code = '$plate' WHERE id = $id";
		$result = mysqli_query($link_mysql, $query);

		if ($result) {
			return true;
		} else {
			return false;
		}
		mysqli_close($link_mysql);
	}

	public function deleteAccount($id)
	{
		$link_mysql = $this->mysqlConn();

		$query = "UPDATE account SET isActive = 0 WHERE id = $id";
		$result = mysqli_query($link_mysql, $query);

		if ($result) {
			return true;
		} else {
			return false;
		}
		mysqli_close($link_mysql);
	}

	public function getUserByEmail($email)
	{
		$link_mysql = $this->mysqlConn();

		$email = mysqli_real_escape_string($link_mysql, $email);

		$query = "SELECT * FROM account WHERE email = '$email'";
		$result = mysqli_query($link_mysql, $query);

		if ($result && mysqli_num_rows($result) >= 1) {
			return true;
		} else {
			return false;
		}

		mysqli_close($link_mysql);
	}

	public function registerUser($fullName, $email, $birthDate, $gender, $tcKimlikNo, $tel, $password)
	{
		$link_mysql = $this->mysqlConn();

		$fullName = mysqli_real_escape_string($link_mysql, $fullName);
		$email = mysqli_real_escape_string($link_mysql, $email);
		$birthDate = mysqli_real_escape_string($link_mysql, $birthDate);
		$gender = mysqli_real_escape_string($link_mysql, $gender);
		$tcKimlikNo = mysqli_real_escape_string($link_mysql, $tcKimlikNo);
		$tel = mysqli_real_escape_string($link_mysql, $tel);
		$password = mysqli_real_escape_string($link_mysql, $password);

		$query = "INSERT INTO account (fullName, email, birthDate, gender, tcKimlikNo, tel, password, isActive) VALUES ('$fullName', '$email', '$birthDate', '$gender', '$tcKimlikNo', '$tel', '$password', 1)";
		$result = mysqli_query($link_mysql, $query);

		if ($result) {
			return true;
		} else {
			return false;
		}

		mysqli_close($link_mysql);
	}
}
