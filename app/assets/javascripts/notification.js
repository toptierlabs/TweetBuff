function notification(text) {
	if (text==null) {
		text = 'Your tweet has successfully queued';
	}
	
	$(".container").html('');
	$(".container").append($("<div></div>").attr('id','notification_post_notice'));
    notice_box = $('#notification_post_notice');
    notice_box.removeClass('error');
    notice_box.addClass('success');
    notice_box.show();
    notice_box.html(text);
    $('#loader').hide();
    

    setTimeout("$('#notification_post_notice').fadeOut(2000)", 3000);
    class_name = ($('#buffer_name_container').last().attr('class')=='even')? 'odd' : 'even';
    $('#new_buffer_name_container').addClass(class_name);
}

function successqueue_notification()
{
	notification('Your tweet has successfully queued');
}
