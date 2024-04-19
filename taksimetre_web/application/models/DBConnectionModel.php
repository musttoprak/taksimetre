<?php

class DBConnectionModel
{
	public function __construct()
	{
		// constructor
	}

	public function mysqlConn()
	{
		$db = 'taksimetre';
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

    public function loginUser($name, $password)
    {
        $link_mysql = $this->mysqlConn();

        $name = mysqli_real_escape_string($link_mysql, $name);

        $query = "SELECT id, name, password FROM user WHERE name = '$name' AND active = 1";
        $result = mysqli_query($link_mysql, $query);

        if ($result && mysqli_num_rows($result) == 1) {
            $user = mysqli_fetch_assoc($result);
            $hashedPasswordFromDB = $user['password'];

            if (password_verify($password, $hashedPasswordFromDB)) {
                mysqli_close($link_mysql);
                unset($user['password']);
                return $user['id']; // Kullanıcı ID'sini döndür
            }
        }

        mysqli_close($link_mysql);
        return false;
    }

    public function changeRatingRoute($id, $rating)
    {
        $link_mysql = $this->mysqlConn();

        if ($link_mysql) {
            $id = mysqli_real_escape_string($link_mysql, $id);
            $rating = mysqli_real_escape_string($link_mysql, $rating);

            $query = "UPDATE route SET star_rating = $rating WHERE id = $id";

            if (mysqli_query($link_mysql, $query)) {
                return true;
            } else {
                return "Sorgu başarısız: " . mysqli_error($link_mysql);
            }

            mysqli_close($link_mysql);
        } else {
            return "MySQL bağlantısı başarısız.";
        }
    }


    public function getRoutes($userId)
    {
        // MySQL bağlantısını al
        $link_mysql = $this->mysqlConn();

        // MySQL bağlantısı başarılıysa
        if ($link_mysql) {
            // Kullanıcı girdisini güvenli hale getir
            $userId = mysqli_real_escape_string($link_mysql, $userId);

            // SELECT sorgusunu oluştur
            $query = "SELECT * FROM route WHERE userId = $userId ORDER BY created_at DESC";

            // Sorguyu çalıştır ve sonucu al
            $result = mysqli_query($link_mysql, $query);

            // Sorgu başarılıysa
            if ($result) {
                $routes = array();

                // Tüm sonuçları diziye ekleyerek döngü yap
                while ($row = mysqli_fetch_assoc($result)) {
                    $routes[] = array(
                        'routeId' => (int)$row['id'],
                        'duration' => (int)$row['duration'],
                        'price' => (double)$row['price'],
                        'destinationAddresses' => $row['destination_address'],
                        'originAddresses' => $row['origin_address'],
                        'destinations' => $row['destinations'],
                        'origins' => $row['origins'],
                        'starRating' => (int)$row['star_rating'],
                    );
                }

                // Sonuçları döndür
                return $routes;
            } else {
                // Sorgu başarısız olduysa hata döndür
                return "Sorgu başarısız: " . mysqli_error($link_mysql);
            }

            // MySQL bağlantısını kapat
            mysqli_close($link_mysql);
        } else {
            // MySQL bağlantısı başarısızsa hata döndür
            return "MySQL bağlantısı başarısız.";
        }
    }


    public function addRoute($userId,$destination_adress,$origin_adress,$destinations,$origins,$duration,$price)
    {
        // MySQL bağlantısını al
        $link_mysql = $this->mysqlConn();

        // MySQL bağlantısı başarılıysa
        if ($link_mysql) {
            // Kullanıcı girdilerini güvenli hale getir
            $userId = mysqli_real_escape_string($link_mysql, $userId);
            $destination_adress = mysqli_real_escape_string($link_mysql, $destination_adress);
            $origin_adress = mysqli_real_escape_string($link_mysql, $origin_adress);
            $destinations = mysqli_real_escape_string($link_mysql, $destinations);
            $origins = mysqli_real_escape_string($link_mysql, $origins);
            $price = mysqli_real_escape_string($link_mysql, $price);

            // INSERT INTO sorgusunu oluştur
            $query = "INSERT INTO route (userId, destination_address, origin_address,destinations,origins,duration, price, star_rating) VALUES ($userId, '$destination_adress', '$origin_adress','$destinations','$origins','$duration', $price,0)";
            // Sorguyu çalıştır ve sonucu kontrol et
            if (mysqli_query($link_mysql, $query)) {
                // Yeni eklenen route ID'sini döndür
                return mysqli_insert_id($link_mysql);
            } else {
                // Sorgu başarısız olduysa hata döndür
                return "Sorgu başarısız: " . mysqli_error($link_mysql);
            }

            // MySQL bağlantısını kapat
            mysqli_close($link_mysql);
        } else {
            // MySQL bağlantısı başarısızsa hata döndür
            return "MySQL bağlantısı başarısız.";
        }

    }


    public function registerUser($name, $password)
    {
        $link_mysql = $this->mysqlConn();

        // Güvenlik: SQL injection saldırılarına karşı koruma için kullanıcı girişlerini kaçış karakterleriyle işleyin
        $name = mysqli_real_escape_string($link_mysql, $name);

        // Kullanıcı adının veritabanında mevcut olup olmadığını kontrol et
        $check_query = "SELECT COUNT(*) FROM user WHERE name = ?";
        $check_stmt = mysqli_prepare($link_mysql, $check_query);
        mysqli_stmt_bind_param($check_stmt, 's', $name);
        mysqli_stmt_execute($check_stmt);
        mysqli_stmt_bind_result($check_stmt, $count);
        mysqli_stmt_fetch($check_stmt);
        mysqli_stmt_close($check_stmt);

        // Eğer kullanıcı adı mevcutsa false dön
        if ($count > 0) {
            mysqli_close($link_mysql); // veritabanı bağlantısını kapat
            return false;
        }

        // Güvenlik: Şifreleri hashleyerek güvence altına alın
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);

        // Şifreli şifreyi veritabanına kaydet
        $password = mysqli_real_escape_string($link_mysql, $hashed_password);

        // Güvenlik: Prepared statements kullanarak SQL sorgularını oluşturun
        $query = "INSERT INTO user (name, password, active) VALUES ('$name', '$password',1)";
        $result =  mysqli_query($link_mysql,$query);

        mysqli_close($link_mysql);
        if ($result) {
            return true;
        } else {
            return false;
        }
    }


}
