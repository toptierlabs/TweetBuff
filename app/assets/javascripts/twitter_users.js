function resetTextCounter()
{
	$('#tweet_text').simplyCountable({
	    counter: '#counter',
	    maxCount: 140,
	  });
}
$(document).ready(function() {
	resetTextCounter();
});
