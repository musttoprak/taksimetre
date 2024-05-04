<?php
defined('BASEPATH') or exit('No direct script access allowed');

class ApiController extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->model('DBConnectionModel');
        $this->load->config('custom');
    }

    public function getRoutes()
    {
        $userId = $this->input->get('userId');

        $routes = $this->DBConnectionModel->getRoutes($userId);

        echo json_encode($routes);
    }

    public function route()
    {
        // buraya post edilen veriyi işleyip ekrana basacağız json deseni olarak
        $baseApiUrl = "https://maps.googleapis.com/maps/api/directions/json?";
        $apiKey = $this->config->item('google_maps_api_key');
        $destination = $this->input->get('destination');
        $origin = $this->input->get('origin');
        $apiUrl = $baseApiUrl . "destination=" . $destination . "&origin=" . $origin . "&mode=walking&language=tr" . "&key=" . $apiKey;

        $response = file_get_contents($apiUrl);

        // API'den gelen veriyi ekrana basma
        if ($response !== false) {
            // Veriyi JSON'dan diziye çevirme
            $responseData = json_decode($response, true);

            // Dizi olarak veriyi işleme veya ekrana basma
            if ($responseData !== null) {

                $legs = $responseData['routes'][0]['legs'][0];

                $distance_meters_legs = $legs['distance']['value'];
                $duration_seconds_legs = $legs['duration']['value'];

                $arr = $this->distanceAndDurationCalculator($distance_meters_legs, $duration_seconds_legs);

                $steps = $responseData['routes'][0]['legs'][0]['steps'];
                $stepsArray = array();
                foreach ($steps as $step) {
                    $distance_meters = $step['distance']['value'];
                    $duration_seconds = $step['duration']['value'];

                    $arrSteps = $this->distanceAndDurationCalculator($distance_meters, $duration_seconds);

                    $recipe = strip_tags($step['html_instructions']); // text hali
                    $stepsArray[] = array(
                        'distance' => $arrSteps[0],
                        'duration' => $arrSteps[1],
                        'recipe' => $recipe,
                    );
                }
                $result = array(
                    'distance' => $arr[0],
                    'duration' => $arr[1],
                    'steps' => $stepsArray
                );

                $data = json_encode($result);
            } else {
                // JSON çözümleme hatası
                $data = "JSON verisi çözümlenemedi.";
            }
        } else {
            // API'ye istek gönderme hatası
            $data = "API'ye istek gönderilirken bir hata oluştu.";
        }

        $this->load->view('api/index', array('data' => $data));
    }

    public function changeRatingRoute()
    {
        $id = $this->input->get('id');
        $rating = $this->input->get('rating');

        $result = $this->DBConnectionModel->changeRatingRoute($id, $rating);

        echo $result;
    }

    private function distanceAndDurationCalculator($distance_meters, $duration_seconds)
    {
        // Uzaklık değeri km olarak hesaplanıyor
        if ($distance_meters < 1000) {
            $distance = $distance_meters . " m";
        } else {
            $distance = ($distance_meters / 1000) . " km";
        }

        // Süre değeri dakika ve saniye olarak hesaplanıyor
        if ($duration_seconds < 60) {
            $duration = $duration_seconds . " s";
        } else {
            $minutes = floor($duration_seconds / 60);
            $seconds = $duration_seconds % 60;
            if ($seconds > 0) {
                $duration = $minutes . " dk " . $seconds . " s";
            } else {
                $duration = $minutes . " dk";
            }
        }


        return array($distance, $duration);
    }

    public function index()
    {
        // buraya post edilen veriyi işleyip ekrana basacağız json deseni olarak
        $baseApiUrl = "https://maps.googleapis.com/maps/api/distancematrix/json?";
        $apiKey = $this->config->item('google_maps_api_key');

        $userId = $this->input->get('userId');
        $destinations = $this->input->get('destinations');
        $origins = $this->input->get('origins');
        $units = "imperial";
        $apiUrl = $baseApiUrl . "destinations=" . $destinations . "&origins=" . $origins . "&units=" . $units . "&key=" . $apiKey;

        $response = file_get_contents($apiUrl);

        if ($response === false) {
            $error = "Hata: " . print_r(error_get_last(), true);
            echo $error;
        }

        // API'den gelen veriyi ekrana basma
        if ($response !== false) {
            // Veriyi JSON'dan diziye çevirme
            $responseData = json_decode($response, true);

            // Dizi olarak veriyi işleme veya ekrana basma
            if ($responseData !== null) {
                $duration_value = $responseData['rows'][0]['elements'][0]['duration']['value'];
                $duration_value = ceil($duration_value / 60); // Dakika cinsine çevir

                // Taksi ücretini hesapla (örneğin, km başına sabit bir ücret varsayalım)
                $distance_value = $responseData['rows'][0]['elements'][0]['distance']['value'];
                //$fare_per_km = 17.61;
                $fare_per_km = $this->DBConnectionModel->getFeeTableValueById(1);
                $distance_km = $distance_value / 1000; // metre cinsinden mesafeyi kilometreye çevir
                //$departure_price = 24.55;
                $departure_price = $this->DBConnectionModel->getFeeTableValueById(2);
                $price = round($distance_km * $fare_per_km, 2) + $departure_price; // 2 ondalık basamak ile yuvarla

                $routeId = $this->DBConnectionModel->addRoute($userId, $responseData['destination_addresses'][0], $responseData['origin_addresses'][0], $destinations, $origins, $duration_value, $price);
                // JSON formatında sonuçları düzenle
                $result = json_encode(array(
                    'routeId' => $routeId,
                    'duration' => $duration_value,
                    'price' => $price,
                    'destinationAddresses' => $responseData['destination_addresses'][0],
                    'originAddresses' => $responseData['origin_addresses'][0],
                    'destinations' => $destinations,
                    'origins' => $origins,
                    'starRating' => 0
                ));

                // Sonuçları ekrana bas
                $data = $result;
            } else {
                // JSON çözümleme hatası
                $data = "JSON verisi çözümlenemedi.";
            }
        } else {
            // API'ye istek gönderme hatası
            $data = "API'ye istek gönderilirken bir hata oluştu.";
        }

        $this->load->view('api/index', array('data' => $data));
    }

    public function text()
    {
        $query = $this->input->get('query');
        // buraya post edilen veriyi işleyip ekrana basacağız json deseni olarak
        $baseApiUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?";
        $apiKey = $this->config->item('google_maps_api_key');
        $apiUrl = $baseApiUrl . "query=" . $query . "&key=" . $apiKey;
        $response = file_get_contents($apiUrl);

        if ($response !== false) {
            // Veriyi JSON'dan diziye çevirme
            $responseData = json_decode($response, true);
            // Dizi olarak veriyi işleme veya ekrana basma
            if ($responseData !== null) {
                // "formatted_address" değerini ekleyerek yeni bir dizi oluşturma
                $formattedAddress = $responseData['results'][0]['formatted_address'];
                $location = $responseData['results'][0]['geometry']['location'];
                $result = array(
                    "latitude" => $location['lat'],
                    "longitude" => $location['lng'],
                    "formatted_address" => $formattedAddress
                );
                // Oluşturulan sonucu JSON formatına çevirme
                $jsonResult = json_encode($result);
                // JSON sonucunu ekrana yazdırma
                echo $jsonResult;
            } else {
                // JSON çözümleme hatası
                echo json_encode(array("error" => "JSON verisi çözümlenemedi."));
            }
        } else {
            // API'ye istek gönderme hatası
            echo json_encode(array("error" => "API'ye istek gönderilirken bir hata oluştu."));
        }
    }

    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $theta = $lon1 - $lon2;
        $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
        $dist = acos($dist);
        $dist = rad2deg($dist);
        $miles = $dist * 60 * 1.1515;
        $km = $miles * 1.609344;
        return $km;
    }

    public function getNearbyTaxiStands()
    {
        $latitude = $this->input->get('latitude');
        $longitude = $this->input->get('longitude');

        $apiUrl = "https://data.ibb.gov.tr/dataset/10fc48d1-ba69-423d-9414-8bb3487e6e2a/resource/33c384f3-f456-474c-90cf-1c4e65ac221f/download/istanbul_taksi_duraklari.geojson";
        $response = file_get_contents($apiUrl);

        if ($response !== false) {
            // Veriyi JSON'dan diziye çevirme
            $responseData = json_decode($response, true);

            // Dizi olarak veriyi işleme veya hata mesajı döndürme
            if ($responseData !== null) {
                $features = $responseData['features'];

                // Yakınlık kontrolü için 5 km'lik bir yarıçap belirleme
                //$radius = 5; // km
                $radius = $this->DBConnectionModel->getFeeTableValueById(3); // km
                // Yakınlık kontrolü ve uygun durakları tutan bir dizi oluşturma
                $nearbyStands = array();
                foreach ($features as $feature) {
                    $coordinates = $feature['geometry']['coordinates'];
                    $distance = $this->calculateDistance($latitude, $longitude, $coordinates[1], $coordinates[0]); // Latitude ve longitude sırasıyla alınıyor

                    // Eğer durak 5 km içindeyse, listeye ekle
                    if ($distance <= $radius) {
                        $name = $feature['properties']['DURAK_ADI'];
                        $nearbyStands[] = array(
                            'name' => $name,
                            'distance' => $distance,
                            'latitude' => $coordinates[1],
                            'longitude' => $coordinates[0]
                        );
                    }
                }
                // En yakın 10 taksi durağını sırala ve al
                usort($nearbyStands, function ($a, $b) {
                    if ($a['distance'] == $b['distance']) {
                        return 0;
                    }
                    return ($a['distance'] < $b['distance']) ? -1 : 1;
                });
                $nearestTenStands = array_slice($nearbyStands, 0, 10);
                // JSON sonucunu döndürme
                echo json_encode($nearestTenStands);
            } else {
                // JSON çözümleme hatası
                return json_encode(array("error" => "JSON verisi çözümlenemedi."));
            }
        } else {
            // API'ye istek gönderme hatası
            return json_encode(array("error" => "API'ye istek gönderilirken bir hata oluştu."));
        }
    }

    public function login()
    {
        $name = $this->input->get('name');
        $password = $this->input->get('password');

        $result = $this->DBConnectionModel->loginUser($name, $password);

        echo !$result ? "null" : $result;
    }

    public function register()
    {
        $name = $this->input->get('name');
        $password = $this->input->get('password');

        $result = $this->DBConnectionModel->registerUser($name, $password);

        echo $result ? 1 : 0;
    }

    public function users()
    {
        $result = $this->DBConnectionModel->getUsers();

        echo json_encode($result);
    }

    public function userChangeActive()
    {
        $id = $this->input->get('id');
        $isActive = $this->input->get('isActive');

        $this->DBConnectionModel->userChangeActive($id, $isActive);

        $result = $this->DBConnectionModel->getUsers();

        echo json_encode($result);
    }

    public function getFeeTableValues()
    {
        $result = $this->DBConnectionModel->getFeeTableValues();
        echo json_encode($result);
    }

    public function feeChangeValue()
    {
        $id = $this->input->get('id');
        $value = $this->input->get('value');

        $this->DBConnectionModel->feeChangeValue($id, $value);

        $result = $this->DBConnectionModel->getFeeTableValues();

        echo json_encode($result);
    }

    public function getAllRoutes()
    {
        $result = $this->DBConnectionModel->getAllRoutes();
        echo json_encode($result);
    }

    public function getAllTaxiStands()
    {
        $latitude = $this->input->get('latitude');
        $longitude = $this->input->get('longitude');

        $apiUrl = "https://data.ibb.gov.tr/dataset/10fc48d1-ba69-423d-9414-8bb3487e6e2a/resource/33c384f3-f456-474c-90cf-1c4e65ac221f/download/istanbul_taksi_duraklari.geojson";
        $response = file_get_contents($apiUrl);

        if ($response !== false) {
            $responseData = json_decode($response, true);

            if ($responseData !== null) {
                $features = $responseData['features'];

                $nearbyStands = array();
                foreach ($features as $feature) {
                    $coordinates = $feature['geometry']['coordinates'];
                    $distance = $this->calculateDistance($latitude, $longitude, $coordinates[1], $coordinates[0]); // Latitude ve longitude sırasıyla alınıyor
                    $name = $feature['properties']['DURAK_ADI'];
                    $nearbyStands[] = array(
                        'name' => $name,
                        'distance' => $distance,
                        'latitude' => $coordinates[1],
                        'longitude' => $coordinates[0]
                    );
                }
                usort($nearbyStands, function ($a, $b) {
                    if ($a['distance'] == $b['distance']) {
                        return 0;
                    }
                    return ($a['distance'] < $b['distance']) ? -1 : 1;
                });
                echo json_encode($nearbyStands);
            } else {
                // JSON çözümleme hatası
                return json_encode(array("error" => "JSON verisi çözümlenemedi."));
            }
        } else {
            // API'ye istek gönderme hatası
            return json_encode(array("error" => "API'ye istek gönderilirken bir hata oluştu."));
        }
    }
}
