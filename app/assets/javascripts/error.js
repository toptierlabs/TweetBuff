function error(text){
	if (text == null)
	{
		text = 'Please enter your tweet.';
	}
	
	$(".container").html('');
	$(".container").append($("<div></div>").attr('id','notification_post_notice'));
	
    notice_box = $("#notification_post_notice");
    notice_box.removeClass('success');
    notice_box.addClass('error');
    notice_box.show();
    notice_box.html(text);
    $('#loader').hide();
    setTimeout("$('#notification_post_notice').fadeOut(2000)",3000)
    class_name = ($('#buffer_name_container').last().attr('class')=='even')? 'odd' : 'even';
    $('#new_buffer_name_container').addClass(class_name);
}


function maxtweets_error(){
	error('Maximum number of tweets reached');
}

function emptytweet_error(){
	error('Please enter your tweet.');
}

function timesettings_error(){
	error('The time settings are blank. Please go to settings section.');
}