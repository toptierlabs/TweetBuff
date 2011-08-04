var BufferEditor = function(){
  this.selectedMode = null,
  this.currentMode  = null,
  this.currentDay   = 0,
  this.buffer       = null,
  this.tUser        = null,
  this.init();
};
$.extend(BufferEditor.prototype, {
  _basisContainer: $("#buffer-selector ul#buffer-basis-select"),
  _expertiseContainer: $("#buffer-selector ul#buffer-expertise-select"),
  _warningContainer: $("#buffer-change-warning"),
  _modeContainer: $(".mode-container"),
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
  setMode: function(mode){
    this.selectedMode = mode;
    if(mode != null){
      $(this).trigger("modeChange", [mode]);
    }
  },
  _parseBasis: function(mode){
    return mode.split("_")[0];
  },
  _parseExpertise: function(mode){
    return mode.split("_")[1];
  },
  _getContainer: function(cname){
    return this["_" + cname + "Container"];
  },
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
  },
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
      return obj
  }
  init: function(){
    var that = this;
    // Grab info regarding the current setup
    $.get(window.location.href.replace("/edit",""), {}, function(data){
      that.buffer       = data.buffer_preference;
      that.tUser        = data.twitter_user;
      that.currentMode  = that.buffer.tweet_mode;
    }, "json");

    // Set up some listeners
    $("a.buffer-cancel").live("click", function(e){that.bufferChangeCancel()});
    $("a.buffer-accept").live("click", function(e){that.bufferChangeAccept()});
    $(that).bind("modeChange", function(e, mode){that._changeMode(mode)})

    // Set selectable buttons
    that._selectable();
  },
  bufferChangeCancel: function(){
    console.log(this.currentMode)
    this.setMode(this.currentMode);
  },
  bufferChangeAccept: function(){
    var that = this;
    // This shouldn't ever happen, but just in case...
    if(that.selectedMode == null) {
      return;
    }
    var token = $('meta[name=csrf-token]').attr('content');
    $.post(window.location.href.replace("/edit",""),
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
  addTime: function(json){
    $("#" + this.currentMode)
      .find("div.day_" + json.day_of_week + " ul.time-list")
      .append($("<li class='time'>" + this._zeroBuffer(json.start_hour) + ":" + this._zeroBuffer(json.start_minute) + "<span class='delete'>x</span></li>"));
  }

});


$.buffereditor = new BufferEditor();