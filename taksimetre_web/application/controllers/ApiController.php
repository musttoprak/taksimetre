<?php
defined('BASEPATH') or exit('No direct script access allowed');

class ApiController extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->config('custom');
    }

    public function index()
    {
        // buraya post edilen veriyi işleyip ekrana basacağız json deseni olarak
        $baseApiUrl = "https://maps.googleapis.com/maps/api/distancematrix/json?";
        $apiKey = $this->config->item('google_maps_api_key');
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
                // Örneğin, JSON verisinin tamamını ekrana basabiliriz
                $data = json_encode($responseData);
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


    private function calculateDistance($lat1, $lon1, $lat2, $lon2) {
        $theta = $lon1 - $lon2;
        $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) +  cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
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
                $radius = 5; // km

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
                usort($nearbyStands, function($a, $b) {
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

        echo "true";
    }


    public function register()
    {
        $name = $this->input->get('name');
        $password = $this->input->get('password');

        echo "true";
    }
}
