$(document).ready(function(){
	$("#selectTimeFirstButton").click(function(){
		$("#1").show();
		$("#2").hide();
		$("#3").hide();
		$("#selectTimeSecondButton").addClass("noselectedroundCornerTimerRec");
		$("#selectTimeThirdButton").addClass("noselectedroundCornerTimerRec");
		$(this).removeClass("noselectedroundCornerTimerRec");
		$(this).addClass("selectedroundCornerTimerRec");
		
	})
	$("#selectTimeSecondButton").click(function(){
		$("#1").hide();
		$("#2").show();
		$("#3").hide();
		$("#selectTimeFirstButton").addClass("noselectedroundCornerTimerRec");
		$("#selectTimeThirdButton").addClass("noselectedroundCornerTimerRec");
		$(this).removeClass("noselectedroundCornerTimerRec");
		$(this).addClass("selectedroundCornerTimerRec");
	})
	$("#selectTimeThirdButton").click(function(){
		$("#1").hide();
		$("#2").hide();
		$("#3").show();
		$("#selectTimeFirstButton").addClass("noselectedroundCornerTimerRec");
		$("#selectTimeSecondButton").addClass("noselectedroundCornerTimerRec");
		$(this).removeClass("noselectedroundCornerTimerRec");
		$(this).addClass("selectedroundCornerTimerRec");
	})
	
	$(".confNormalRec").click(function(){
		//$(".selectedroundCornerRec").removeClass("selectedroundCornerRec");
		//$(".selectedroundCornerRec").addClass("noSelectedroundCornerRec");
		if($(this).hasClass("selectedroundCornerRec")){
			$(this).removeClass("selectedroundCornerRec");
			$(this).addClass("noSelectedroundCornerRec");
		}
		else{
			$(this).removeClass("noSelectedroundCornerRec");
			$(this).addClass("selectedroundCornerRec");
		}
		
	})
	
	
})

function checkedBox(val){
    check = jQuery('#check'+val).attr('checked');
    if(check){
      jQuery('#check'+val).removeAttr('checked');
      jQuery('#link'+val).removeClass('active_checkbox_time_setting');
    }else {
      jQuery('#check'+val).attr('checked','checked');
      jQuery('#link'+val).addClass('active_checkbox_time_setting');
    }
}

var new_form_count = 1
function new_interval_custom(){
    form_sub = new_form_count += 1
    $('#new_form_count').val(form_sub);
	$('#custom_tf_select').clone().appendTo('#custom_tf_wrapper')
}
