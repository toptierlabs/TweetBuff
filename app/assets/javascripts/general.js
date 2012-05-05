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

  $.buildToken = function(){
    return $('meta[name=csrf-token]').attr('content');
  };

  $("#dialog").dialog({
    autoOpen: false
  });

  $("a.dialog").live("click", function(event){
    event.preventDefault();
    var t = $(this);
    var url = this.href;

    d = $("#dialog").dialog("option",{
      title : t.attr("title") || t.text(),
      width : t.data("width") || 400,
      height: t.data("height") || 200
    });

    d.dialog("close");
    var l = d.children(".loading");
    var c = d.children(".content");
    d.dialog("open");
    c.hide();
    l.show();
    $.get(url, {no_layout: "true"}, function(data){
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
  $.tabHandler.registeredMenus.push("daily");

  // Create inline timepickers
  $("div.time-select.inline").each(function(i,el){
    $(el).timepicker({
       altField: $(el).data("altfield") || null
    });
  });

  // Get the buffer time editor script if necessary
  if($("#buffer-basis").length){ $.getScript("/javascripts/buffer_editor.js") }



  var TweetEditor = function(){
    this._buffers = [];
    this._bufferData = {};
    this.tUser = null;


    this._init();
  }

  $.extend(TweetEditor.prototype, {
    _addBuffer: function(bufferPermalink){
      var that = this;
      that._buffers.push(bufferPermalink);
      var url = ["/twitter", that.tUser, bufferPermalink].join("/");
      $.get(url, {}, function(json){
        that._bufferData[bufferPermalink] = json;
      }, "json");
      that._sortableInit(bufferPermalink);
    },
    _removeBuffer: function(bufferPermalink){
      this._buffers.splice(this._buffers.indexOf(bufferPermalink),1);
      delete(this._bufferData[bufferPermalink]);
    },
    _guessTwitterUser: function(){
      if(window.location.href.indexOf("twitter") > -1){
        var href    = window.location.href;
        var start   = href.indexOf("twitter/") + "twitter/".length;
        var end     = href.indexOf("/", start);
        this.tUser  = href.substring(start, end);
      } else {
        console.log("No method left to guess twitter username");
      }
    },
    _init: function(){
      var that = this;

      // Guess the twitter username
      that._guessTwitterUser();

      // We are managing multiple tabs (ie: many buffers on a single page)
      // Get info on all buffers
      $(".tabs-container.buffer-tabs#buffer > div").each(function(idx,buffer){
        var bufferPermalink = $(buffer).attr("id");
        if(bufferPermalink !== "new_buffer")
          that._addBuffer(bufferPermalink);
      });
    },
    _sortableInit: function(bufferPermalink){
      var that = this;
      $("#" + bufferPermalink + " table.tweets > tbody").sortable({
        update: function(event, ui){
          url = ["/twitter",that.tUser,bufferPermalink,"tweets","sort"].join("/")
          data = $(this).sortable("serialize")
          data += "&authenticity_token=" + $.buildToken();
          $.post(url, data, function(data){
            if(data.status == "ok"){
              console.log("sorting went fine");
            } else {
              console.log("Something went wrong with sorting");
            }
          })
        }
      });
    },
    addTweet: function(json){
      var bufferPermalink  = json.bp_permalink
      this.removeEmptyTweetMessage(bufferPermalink);
      var tweet   = json.tweet
      var table = $("#" + bufferPermalink + " table.tweets > tbody");
      var row = $("<tr id='tweet_" + tweet.id + "'><td class='due'><span class='title'></span><span class='time'></span><span class='date'></span></td><td class='content'>" + tweet.body + "</td></tr>")
      table.append(row);
      // tweet.title
    },
    removeEmptyTweetMessage: function(bufferPermalink){
      // NOTE this is where the text is changed in the tweet table footer
      var row = $("#" + bufferPermalink + " table.tweets > tfoot > tr.empty");
      row.removeClass("empty").children("td").text("");
    },
    removeTweet: function(target){
      if(typeof(target) !== "object"){ target = $("tr#tweet_" + target); }
      if(target.length == 0){ return null; }
      var bufferPermalink = target.closest(".buffer-panel").attr("id");
      var tweetId = target.attr("id").replace("tweet_","");
      var token = $.buildToken();
      var url = ["/twitter", this.tUser, bufferPermalink, "tweets", tweetId].join("/");
      $.post(url, {authenticity_token: token, _method:"DELETE"}, function(json){
        if(json.status == "ok"){
          taret.fadeOut(400, function(){
            target.remove();
          });
          return this;
        } else {
          return false;
        }
      });
    },
    updateTweetTimes: function(bufferPermalink){
      // TODO implement this...
    }
  });


  $.tweeteditor = new TweetEditor();


  // Trigger a hash change.
  // This should be the last thing to happen on page load...
  $(window).hashchange();

  $("#buffer-selector ul li").button();
});