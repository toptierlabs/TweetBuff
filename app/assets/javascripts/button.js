var divWidth;

function setPosition(divWidth){
  var left = (window.innerWidth - divWidth) / 2;
  $("#general_dialog").css("top","10%")
  $("#general_dialog").css("left",left);

}

function showDialog(title,link_to){
  var popupObj = jQuery("#general_dialog");
  popupObj.bPopup({
    onOpen: function(){
      popupObj.html("<br /><p style='text-align: center;'><img src='/assets/ajaxLoader.gif' /></p>");
      jQuery.get(link_to,function(data){
        popupObj.html("<div id='dialog_header'>"+title+"<img src='/assets/black-close-button.gif' style='float: right; cursor: pointer; margin-top: -5px;' class='bClose' /></div><br />"+data);
        divWidth = popupObj.outerWidth();
        var totalHeight = popupObj.outerHeight();
        setPosition(divWidth);
        if(totalHeight >= 520){
          popupObj.css("position","absolute");
          window.location="#";
        }else{
          popupObj.css("position","fixed");
        }
      });
    },
    onClose:function(){
      popupObj.html('');
    },
    position: ['auto','auto'],
    follow : [false,false],
    opacity : 0.2
  });
}
$(window).resize(function(){
  if(divWidth){
    setPosition(divWidth);
  }
});