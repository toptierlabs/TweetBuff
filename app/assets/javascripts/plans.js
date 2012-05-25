$(document).ready(function() {
	$(".planPrice").show();

	$("#plansTab1").click(function() {
		if($(this).hasClass("plansTab_image_blue")) {
			$(".plansTab_image_green").addClass("plansTab_image_blue");
			$(".plansTab_image_green").removeClass("plansTab_image_green");
			$(this).removeClass("plansTab_image_blue");
			$(this).addClass("plansTab_image_green");
			$(".planPrice").show();
			$(".planPriceAnual").hide();
		}

	})

	$("#plansTab2").click(function() {
		if($(this).hasClass("plansTab_image_blue")) {
			$(".plansTab_image_green").addClass("plansTab_image_blue");
			$(".plansTab_image_green").removeClass("plansTab_image_green");
			$(this).removeClass("plansTab_image_blue");
			$(this).addClass("plansTab_image_green");
			$(".planPriceAnual").show();
			$(".planPrice").hide();
		}
	})


	$('div.annual-toggle span').click(function(e) {
		e.preventDefault();

		$('div.annual-toggle span').removeClass('select');
		$(this).addClass('select');

		if($(this).hasClass('button_plan_annual')) {
			$('div.top-part font.monthly').addClass('hidden');
			$('div.top-part font.annual').removeClass('hidden');
		} else {
			$('div.top-part font.monthly').removeClass('hidden');
			$('div.top-part font.annual').addClass('hidden');
		}
	});

	$('div.annual-toggle span.button_plan_monthly').click();
})