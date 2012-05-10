$(document).ready(function(){
	$("#selectTimeFirstButton").click(function(){
		$("#1").show();
		$("#2").hide();
		$("#3").hide();
		$("#selectTimeSecondButton").addClass("noselectedroundCornerTimerRec");
		$("#selectTimeThirdButton").addClass("noselectedroundCornerTimerRec");
		$(this).removeClass("noselectedroundCornerTimerRec");
		$(this).addClass("selectedroundCornerTimerRec");
		$('[name="timeframe[time_setting_type]"]').val("1");
		
	})
	$("#selectTimeSecondButton").click(function(){
		$("#1").hide();
		$("#2").show();
		$("#3").hide();
		$("#selectTimeFirstButton").addClass("noselectedroundCornerTimerRec");
		$("#selectTimeThirdButton").addClass("noselectedroundCornerTimerRec");
		$(this).removeClass("noselectedroundCornerTimerRec");
		$(this).addClass("selectedroundCornerTimerRec");
		$('[name="timeframe[time_setting_type]"]').val("2");
	})
	$("#selectTimeThirdButton").click(function(){
		$("#1").hide();
		$("#2").hide();
		$("#3").show();
		$("#selectTimeFirstButton").addClass("noselectedroundCornerTimerRec");
		$("#selectTimeSecondButton").addClass("noselectedroundCornerTimerRec");
		$(this).removeClass("noselectedroundCornerTimerRec");
		$(this).addClass("selectedroundCornerTimerRec");
		$('[name="timeframe[time_setting_type]"]').val("3");
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


function newTimeInterval(){

    $('#new_form_count').val(parseInt($('#new_form_count').val())+1);
	newnode = $('.custom_tf_select').first().clone();
	$("#tfname_hour_",newnode).val("1");
	$("#tfname_minute_",newnode).val("0");
	$("#tfname_meridian_",newnode).val("pm");
	newnode.appendTo('#custom_tf_wrapper');
	
}

function removeInterval(nodetoremove){
	if ($('#new_form_count').val() > 1)
	{
		$('#new_form_count').val(parseInt($('#new_form_count').val()) - 1); 
    	nodetoremove.remove();
	}
    
}

