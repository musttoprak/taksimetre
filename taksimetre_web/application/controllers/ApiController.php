<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class ApiController extends CI_Controller {

	public function __construct() {
		parent::__construct();
		$this->load->config('custom');
	}

	public function index() {
        var_dump("bağlantı sağlandı");
		// buraya post edilen veriyi işleyip ekrana basacağız json deseni olarak
		$baseApiUrl = "https://maps.googleapis.com/maps/api/distancematrix/json?";
		$apiKey = $this->config->item('google_maps_api_key');
		$destinations = $this->input->get('destinations');
		$origins = $this->input->get('origins');
		$units = "imperial";
		$apiUrl = $baseApiUrl."destinations=".$destinations."&origins=".$origins."&units=".$units."&key=".$apiKey;

		// API'ye istek gönderme
		$response = file_get_contents($apiUrl);

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
}
