// Class for watching and manipulating the hash for ajax history and page views
function LocationHash(runWatch){
  if ( runWatch ){
    this._watchHash();
  }
};
$.extend(LocationHash.prototype, {
  _locationHash : {},
  _listeners : {},
  _build: function(){
    var builtHash = [];
    $.each(this._locationHash, function(k,v){
      if ( v == "" ) {
        builtHash.push(k);
      } else {
        builtHash.push(k + "=" + v);
      }
    });
    return builtHash.join("&");
  },
  _watchFunction: function(){
    var that = this;
    that._parse();
    $.each(that._listeners, function(name, obj){
      // Invoke the listener
      obj.func.apply(that, [that, obj.options]);
    });
  },
  _watchHash: function(){
    var that = this;
    if(arguments.length > 0 && arguments[0] == false){
      $(window).unbind("hashchange", function(event){that._watchFunction()});
    } else {
      $(window).hashchange(function(event){that._watchFunction()});
    }
  },
  _parse: function(){
    var that = this;
    that.clearHash();
    $.each(location.hash.substr(1).split("&"),function(i,e){
      var splitLocation = e.indexOf("=");
      if ( splitLocation > 0 ) {
        var variable = e.substring(0, splitLocation);
        var value = e.substr(splitLocation + 1);
        that._locationHash[variable] = value;
      } else {
        that._locationHash[e] = "";
      }
    });
  },
  addListener: function(name, func){
    this._listeners[name] = func;
    return this;
  },
  clearHash: function(){
    this._locationHash = {};
    return this;
  },
  deleteKey: function(key){
    if ( this.hasKey(key) ) {
      var value = this.getKey(key);
      delete(this._locationHash[key]);
      return value;
    }
    return null;
  },
  deleteListener: function(name){
    if ( this._listeners.hasOwnProperty(name) ) {
      delete(this._listeners[name]);
    }
    return this;
  },
  getHash : function(){
    return this._locationHash;
  },
  getKey: function(key){
    if ( this.hasKey(key) ) {
      return this._locationHash[key];
    } else {
      return null;
    }
  },
  hasKey: function(key){
    return this._locationHash.hasOwnProperty(key);
  },
  // Set the location hash with the stored hash
  // Can take a hash as an argument
  setHash: function(){
    if ( arguments.length > 0) {
      this._locationHash = arguments[0];
    }
    location.hash = this._build();
  },
  setKey: function(key, value){
    this._locationHash[key] = value;
  },
  startWatching: function(){
    this._watchHash();
  },
  stopWatching: function(){
    this._watchHash(false);
  },
})

$.locationHash = new LocationHash(true);

// Class specifically for tab management
function Tabs() {
  this.init();
};

$.extend(Tabs.prototype, {
  registeredMenus: [],
  init : function(){
    var that = this;

    $(document).ready(function(){
      // Set up any tabs on the page
      $("div.tabs-container").tabs({
        select: function(event, ui) {
          var key   = $(ui.tab).closest("div").attr("id");
          var value = $(ui.tab).attr("href").substr(1);
          if ( $.locationHash.getKey(key) != value) {
            $.locationHash.setKey(key, value); // Set the hash key
            $.locationHash.setHash();          // Store the hash
          }
        },
        load: function(event, ui) {
          $('a', ui.panel).click(function() {
              $(ui.panel).load(this.href);
              return false;
          });
        }
      });

      // Hashchange handler
      var listener = {
        options : {tabs: that},
        func : function(scope, options) {
          var tabs = options.tabs;
          $.each(tabs.registeredMenus, function(index, menuName){
            if ( scope.hasKey(menuName) )
              $(".tabs-container#" + menuName).tabs('select', scope.getKey(menuName));
          });
        }
      };

      $.locationHash.addListener("tabs", listener);
    });
  }
});


$.tabHandler = new Tabs();



$(document).ready(function(){

  $("#dialog").dialog({
    autoOpen: false
  });

  $("a.dialog").live("click", function(event){
    event.preventDefault();
    var t = $(this);
    var url = this.href;

    d = $("#dialog").dialog("option",{
      title : t.attr("title") || t.text()
    });

    d.dialog("close");
    var l = d.children(".loading");
    var c = d.children(".content");
    d.dialog("open");
    c.hide();
    l.show();
    $.get(url, {}, function(data){
      l.hide();
      c.html(data).show();
    })
  });


  // Link div toggle routine
  $("a.reveal").live("click",function(e){
    $($(this).attr("href")).toggle("blind");
  });

  $.tabHandler.registeredMenus.push("buffer");
  $.tabHandler.registeredMenus.push("twitter");
  $.tabHandler.registeredMenus.push("weekly");
  $.tabHandler.registeredMenus.push("daily");

  // Create inline timepickers
  $("div.time-select.inline").each(function(i,el){
    $(el).timepicker({
       altField: $(el).data("altfield") || null
    });
  });

  // Get the buffer time editor script if necessary
  if($("#buffer-basis").length){ $.getScript("/javascripts/buffer_editor.js") }


  // Trigger a hash change.
  // This should be the last thing to happen on page load...
  $(window).hashchange();

});