function error(){
    notice_box = $('#post_notice');
    notice_box.removeClass('error');
    notice_box.addClass('success');
    notice_box.show();
    notice_box.html('Please enter your tweet.');
    $('#loader').hide();
    setTimeout("$('#post_notice').fadeOut()",3000)
    class_name = ($('#buffer_name_container').last().attr('class')=='even')? 'odd' : 'even';
    $('#new_buffer_name_container').addClass(class_name);
}