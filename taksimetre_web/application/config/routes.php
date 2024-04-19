<?php
defined('BASEPATH') OR exit('No direct script access allowed');

$route['default_controller'] = 'homecontroller/index';
$route['index'] = 'HomeController/changePage/index';
$route['api'] = 'ApiController/index';
$route['text'] = 'ApiController/text';
$route['durak'] = 'ApiController/getNearbyTaxiStands';
$route['login'] = 'ApiController/login';
$route['register'] = 'ApiController/register';
$route['route'] = 'ApiController/route';
$route['getRoutes'] = 'ApiController/getRoutes';
$route['changeRatingRoute'] = 'ApiController/changeRatingRoute';





