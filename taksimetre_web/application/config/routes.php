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
$route['users'] = 'ApiController/users';
$route['userChangeActive'] = 'ApiController/userChangeActive';
$route['getFeeTableValues'] = 'ApiController/getFeeTableValues';
$route['feeChangeValue'] = 'ApiController/feeChangeValue';
$route['getAllRoutes'] = 'ApiController/getAllRoutes';
$route['getAllTaxiStands'] = 'ApiController/getAllTaxiStands';






