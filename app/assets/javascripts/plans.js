$(document).ready(function(){
    $(".planPrice").show();
  
    $("#plansTab1").click(function(){
      if($(this).hasClass("plansTab_image_blue")){
        $(".plansTab_image_green").addClass("plansTab_image_blue");
        $(".plansTab_image_green").removeClass("plansTab_image_green");
        $(this).removeClass("plansTab_image_blue");
        $(this).addClass("plansTab_image_green");
        $(".planPrice").show();
        $(".planPriceAnual").hide();
      }
    
    })
    
    $("#plansTab2").click(function(){
      if($(this).hasClass("plansTab_image_blue")){
        $(".plansTab_image_green").addClass("plansTab_image_blue");
        $(".plansTab_image_green").removeClass("plansTab_image_green");
        $(this).removeClass("plansTab_image_blue");
        $(this).addClass("plansTab_image_green");
        $(".planPriceAnual").show();
        $(".planPrice").hide();
      }
    })
    
    $("#menuArrow").removeClass();
    $("#menuArrow").addClass("menuArrowPlans");  
  })
