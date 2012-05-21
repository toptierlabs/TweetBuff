var BufferEditor = function(){
  this.selectedMode = null;
  this.currentMode  = null;
  this.currentDay   = 0;
  this.buffer       = null;
  this.tUser        = null;
  this._days        = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"];
  this._init();

};
$.extend(BufferEditor.prototype, {
  _basisContainer: $("#buffer-selector ul#buffer-basis-select"),
  _expertiseContainer: $("#buffer-selector ul#buffer-expertise-select"),
  _warningContainer: $("#buffer-change-warning"),
  _modeContainer: $(".mode-container"),
  _changeMode: function(mode){
    var that = this;
    // Make sure the correct buttons are toggled
    var bLi = that._getContainer("basis");
    var eLi = that._getContainer("expertise");
    // Turn off unwanted buttons
    $("li", bLi).not("li[data-type='" + that._parseBasis(mode) + "']").removeClass("ui-selected");
    $("li", eLi).not("li[data-type='" + that._parseExpertise(mode) + "']").removeClass("ui-selected");
    // Turn on the correct buttons
    $( $("li[data-type='" + that._parseBasis(mode) + "']"), bLi).addClass("ui-selected");
    $( $("li[data-type='" + that._parseExpertise(mode) + "']"), eLi).addClass("ui-selected");

    // Show approriate windows
    that.toggleWindow("warning", !(that.currentMode == mode));
    if(that.currentMode == mode){
      that.toggleWindow($("#"+mode), true)
    } else {
      that.toggleWindow("mode", false);
      $(".buffer-new-type").text(mode.replace("_"," "));
    }
  },
  _checkMode: function(){
    var $basis = this._basisContainer.children("li.ui-selected");
    var $expertise = this._expertiseContainer.children("li.ui-selected");
    if($basis.length){
      this.toggleWindow("expertise", true);
      mode = $basis.data("type") + "_";
    } else {
      this.toggleWindow("expertise", false);
      this.setMode(null);
      return false;
    }
    if($expertise.length){
      mode += $expertise.data("type");
      this.setMode(mode);
    } else {
      return false;
    }
    return mode;
  },
  _getContainer: function(cname){
    return this["_" + cname + "Container"];
  },
  _init: function(){
    var that = this;
    // Grab info regarding the current setup.  CANNOT BUILD URL HERE!!
    $.get(window.location.href.replace("/edit",""), {}, function(data){
      that.buffer       = data.buffer_preference;
      that.tUser        = data.twitter_user;
      that.currentMode  = that.buffer.tweet_mode;
      if(that._parseBasis(that.currentMode) == "daily"){
        that._modeIsDaily();
      }
    }, "json");

    // Set up some listeners
    $("a.buffer-cancel").live("click", function(e){that.bufferChangeCancel()});
    $("a.buffer-accept").live("click", function(e){that.bufferChangeAccept()});
    $("a.delete-time").live("click", function(e){that.deleteTime($(e.target))});
    $(that).bind("modeChange", function(e, mode){that._changeMode(mode)});

    // Set selectable buttons
    that._selectable();
  },
  _modeIsDaily: function(){
    var that = this;
    $("#daily.tabs-container").bind("tabsselect", function(event,ui){
      that.currentDay = that._days.indexOf(ui.panel.id.replace("daily_","").toLowerCase());

    });
  },
  _parseBasis: function(mode){
    return mode.split("_")[0];
  },
  _parseExpertise: function(mode){
    return mode.split("_")[1];
  },
  /
  _selectable: function(){
    var that = this;
    $("#buffer-selector ul.selectable").selectable({
      stop: function(event, ui){
        that._checkMode();
      }
    });
  },
  _zeroBuffer: function(obj){
    if(obj.length == 1)
      return "0" + obj;
    else
      return obj;
  },
  addTime: function(json){
    var that = this;
    var dayHunter = (that._parseBasis(that.currentMode) == "daily" ? " #daily_" + that._days[json.day_of_week] : "");
    var $timeList = $("#" + that.currentMode + dayHunter + " ul.time-list");
    console.log("HEY THERE");
    console.log($timeList);
    console.log(dayHunter);
    $timeList.children("li.no-times").remove(); // If it's got a no time placeholder, remove it.
    $timeList.append($("<li class='time' data-id='" + json.id + "'>" + that._zeroBuffer(json.start_hour) + ":" + that._zeroBuffer(json.start_minute) + "<a href='#' class='delete-time'>Delete</a></li>"));
  },
  buildURL: function(whereto,options){
    var regex = /[\_\-\(\)\[\]\{\}\,\.\/\?\!\@\#\$\%\^\&\*\s]+/g;
    var twitterName = this.tUser.login.replace(regex,"-"),
        bufferName  = this.buffer.name.replace(regex,"-");
    var base = "/twitter/" + twitterName + "/" + bufferName + "/"

    switch(whereto){
      case "deleteLink":
        return base + options.id;
        break;
      case "acceptTweetMode":
      case "getBufferInfo":
      default:
        return base;
    }
  },
  deleteTime: function(link){
    var that = this;
    var listItem = link.parent("li.time");
    var timeDefinitionId = listItem.data("id");
    var token = $.buildToken(); //that.getToken();
    var url = that.buildURL("deleteLink",{id: timeDefinitionId});
    $.post(url, {authenticity_token: token, _method:'DELETE'}, function(json){
      if(json.status != "ok"){
        return;
      } else {
        listItem.empty().remove();
      }
    }, "json");
  },
  bufferChangeCancel: function(){
    this.setMode(this.currentMode);
  },
  bufferChangeAccept: function(){
    var that = this;
    // This shouldn't ever happen, but just in case...
    if(that.selectedMode == null) {
      return;
    }
    var token = $.buildToken(); //that.getToken();
    var url = that.buildURL("acceptTweetMode");
    $.post(url,
      {authenticity_token:token, _method:"put", buffer_preferences:{tweet_mode:that.selectedMode}},
      function(data){
        if(data.status !== "ok"){
          return;
        } else {
          window.location.reload(true);
        }
      },
      "json"
    );
  },
  getToken: function(){
    return $('meta[name=csrf-token]').attr('content');
  },
  setMode: function(mode){
    this.selectedMode = mode;
    if(mode != null){
      $(this).trigger("modeChange", [mode]);
    }
  },
  toggleWindow: function(w, status){
    var $w = (typeof(w) == "string" ? this['_' + w + 'Container'] : w);

    if(status == "show" || status == true){
      if($w.hasClass("hidden")){
        $w.removeClass("hidden");
      } else {
        $w.show();
      }
    } else {
      $w.addClass("hidden");
    }
  }

});


$.buffereditor = new BufferEditor();