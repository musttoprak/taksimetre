<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class HomeController extends CI_Controller {

	public function __construct() {
		parent::__construct();
		$this->load->model('DBConnectionModel');
		$this->load->library('session');
		$this->load->helper('url');
	}

	public function index() {
		$data['content'] = "home/index";
		$this->load->view('template', array('data' => $data));
	}
	public function changePage($page) {
		$data['content'] = "home/$page";
		$this->load->view('template', array('data' => $data));
	}

}
