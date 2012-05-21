function notification(text) {
	if (text==null) {
		text = 'Your tweet has successfully queued';
	}
	
	//$(".container").html('');
	notice_box = $("<div></div>").attr('class','notification_post_notice');
	$(".container").append(notice_box);

    notice_box.removeClass('error');
    notice_box.addClass('success');
    notice_box.show();
    notice_box.html(text);
    $('#loader').hide();
    

    setTimeout(function(){
    	notice_box.fadeOut(2000);
    },3000);
    
    class_name = ($('#buffer_name_container').last().attr('class')=='even')? 'odd' : 'even';
    $('#new_buffer_name_container').addClass(class_name);
}

function successqueue_notification(account_name)
{
	notification('Your tweet has successfully queued to account '+account_name);
}
