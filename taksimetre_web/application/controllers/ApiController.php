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
}
