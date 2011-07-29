// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



$(document).ready(function(){


  $("a.reveal").live("click",function(e){
    $($(this).attr("href")).toggle("blind");
  });

  $("div.tabs-container").tabs({
      load: function(event, ui) {
          $('a', ui.panel).click(function() {
              $(ui.panel).load(this.href);
              return false;
          });
      }
  });
});