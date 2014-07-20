$(document).ready(function() {
	var $window = $(window);

	$window.scroll(function() {
	    if ($window.scrollTop() > $window.height())
	    {
	      $("#nav").css({
	      	background: "rgba(0, 0, 0, 1)",
	      	position: "fixed",
	      	top: "0",
	      	width: "100%",
	      	// left: "20%",
	      	height: "60px",
	      	zIndex: "999"
	      });
	      $("#logo-container").css("margin-top", "231px");
	      $("#bottomtext").css("padding-bottom", "200px");
	    }
	    if ($window.scrollTop() < $window.height())
	    {
			$("#nav").removeAttr("style");
			$("#logo-container").removeAttr("style");
			$("#bottomtext").removeAttr("style");

	    }
	});
})