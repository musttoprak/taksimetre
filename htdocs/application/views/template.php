<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<title>Taksimetre</title>
</head>
<?php
// Mevcut sayfanın URL'sini alın
$current_url = $_SERVER['REQUEST_URI'];
?>
<body>
<!--PreLoader-->
<div class="loader">
	<div class="loader-inner">
		<div class="circle"></div>
	</div>
</div>
<!--PreLoader Ends-->

<!-- Header Kısmı -->
<header>
</header>
<!-- Header Kısmı Bitiş -->

<!-- Body İçeriği -->
<?php //$this->load->view($data['content'], $data); ?>
<!-- Body İçeriği Bitiş -->

<!-- footer -->
<footer>
</footer>
<!-- end footer -->


<!-- copyright -->
<div class="copyright">
	<div class="container">
		<div class="row">
			<div class="col-lg-6 col-md-12">
				<p>Telif Hakları &copy; 2024 - <a href="https://www.kocaeli.edu.tr/" target="_blank">Taksimetre</a>,
					Tarafından Tüm hakları saklıdır.</p>
			</div>
			<div class="col-lg-6 text-right col-md-12">
				<div class="social-icons">
					<ul>
						<li><a href="#" target="_blank"><i class="fab fa-facebook-f"></i></a></li>
						<li><a href="#" target="_blank"><i class="fab fa-twitter"></i></a></li>
						<li><a href="#" target="_blank"><i class="fab fa-instagram"></i></a></li>
						<li><a href="#" target="_blank"><i class="fab fa-linkedin"></i></a></li>
						<li><a href="#" target="_blank"><i class="fab fa-dribbble"></i></a></li>
					</ul>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- end copyright -->

</body>
</html>
