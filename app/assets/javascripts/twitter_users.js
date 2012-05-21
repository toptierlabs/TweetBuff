function resetTextCounter()
{
	$('#tweet_text').simplyCountable({
	    counter: '#counter',
	    maxCount: 140,
	  });
}

function refreshSelectedTwitterAccounts()
{
	$checkboxes = $("#accountsWrapper input:checked");	
	
	arr = $.map($checkboxes, function(element, index){
		return $(element).val();
	});
	$("#twitter_accounts_name").val(arr.join(","));
}

$(document).ready(function() {
	resetTextCounter();
});
