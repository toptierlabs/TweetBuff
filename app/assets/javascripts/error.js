function error(text){
	if (text == null)
	{
		text = 'Please enter your tweet.';
	}
	
	//$(".container").html('');
	
	notice_box = $("<div></div>").attr('class','notification_error');
	$(".container").append(notice_box);
	
    notice_box.removeClass('success');
    notice_box.addClass('error');
    notice_box.show();
    notice_box.html(text);
    $('#loader').hide();
    setTimeout(function(){
    	notice_box.fadeOut(2000);
    },3000);
    
    class_name = ($('#buffer_name_container').last().attr('class')=='even')? 'odd' : 'even';
    $('#new_buffer_name_container').addClass(class_name);
}


function maxtweets_error(account_name){
	error('Maximum number of tweets reached in account '+account_name);
}

function emptytweet_error(){
	error('Please enter your tweet.');
}

function timesettings_error(account_name){
	error('The time settings are blank. Please go to settings section of account '+account_name+ ".");
}