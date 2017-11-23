require( './styles/main.scss' );

var entryCloudBuilder = require( './js/entry-cloud-builder' );
var navigatorLanguage = require( './js/navigator-language' );
var waitForElement    = require( './js/wait-for-element' );
var L                 = require( './js/vendor/leaflet-1.2.0.min' );
var PruneCluster      = require("./js/vendor/prunecluster-2.1.0.min.js").PruneCluster;
var PruneClusterForLeaflet = require("./js/vendor/prunecluster-2.1.0.min.js").PruneClusterForLeaflet;
require( './js/vendor/leaflet.fullscreen-1.0.1.min' );
require( './js/vendor/dialog-polyfill-0.4.9.min' );

var Elm = require( '../elm/Main' );
var mountNode = document.getElementById( 'main' );

var localLanguage = localStorage.getItem('language');
var localJWT = localStorage.getItem('jwt');
var entryMapElement = undefined;

var app = Elm.Main.embed( mountNode, {
  localLanguage: localLanguage || navigatorLanguage(),
  localJWT: localJWT
});

app.ports.appTitle.subscribe(function(newTitle) {
    document.title = newTitle;
});

app.ports.appDescription.subscribe(function(newDescription) {
  document.head.querySelector("[name=description]").content = newDescription;
});

app.ports.setLocalLanguage.subscribe(function(lang) {
  localStorage.setItem('language', lang);
});

app.ports.setLocalJWT.subscribe(function(jwt) {
  localStorage.setItem('jwt', jwt);
});

app.ports.removeLocalJWT.subscribe(function() {
  localStorage.removeItem('jwt');
});

app.ports.entryVotesMap.subscribe(function(votesList) {
  if (!!entryMapElement) {
    entryMapElement.remove();
    entryMapElement = undefined;
  }
  waitForElement('entry-map-votes', entryMapBuilder, votesList);
});

app.ports.entryWordCloud.subscribe(function(wordsList) {
  waitForElement('entry-words-cloud', entryCloudBuilder, wordsList);
});

app.ports.updateGA.subscribe(function(page) {
    ga('set', 'page', page);
    ga('send', 'pageview');
});


/**
 * Attach or detach the Leaflet map and markers.
 * @return bool
 *   Determines if entryMapBuilder completed it's operation.
 *   True means we don't need to re-call this function.
 */
function entryMapBuilder(selector, votesList) {
  if (!document.getElementById(selector)) {
    // Element doesn't exist yet.
    return false;
  }

  var allWords = new PruneClusterForLeaflet(),
      layerGroups = {}, wordsCounter = {}, sortedWords = [],
      control = L.control.layers(null, null, {}),
      votesListSize = votesList.length,
      // ["positive", "negative", "neutral", "none"]
      colors = ['#66BB6A', '#EF5350', '#FFCA28', '#FFCA28'],
      pi2 = Math.PI * 2;

  entryMapElement = entryMapElement || addMap(selector);
  // Trick to force order of listing in L.Control.Layers.
  L.stamp(allWords);

  // Fix Webpack issue (#4968) with icons path
  L.Icon.Default.mergeOptions({
    iconUrl: '/static/img/marker-icon.png',
    iconRetinaUrl: '/static/img/marker-icon-2x.png',
    shadowUrl: '/static/img/marker-shadow.png'
  });

  delete L.Icon.Default.prototype._getIconUrl;

  // End of customization for Webpack.

  allWords.BuildLeafletClusterIcon = function(cluster) {
      var e = new L.Icon.MarkerCluster();
      e.stats = cluster.stats;            // categories on your markers
      e.population = cluster.population;  // number of markers inside the cluster
      return e;
  };

  function customColorIcon(data, category) {
    var color = category == 0 ? "green" : category == 1 ? "red" : "yellow";
    return L.icon({
      iconUrl: "/static/img/marker-icon-".concat(color, ".png"),
      iconRetinaUrl: "/static/img/marker-icon-2x-".concat(color, ".png"),
      shadowUrl: '/static/img/marker-shadow.png',
      iconSize:    [25, 41],
  		iconAnchor:  [12, 41],
  		popupAnchor: [1, -34],
  		shadowSize:  [41, 41]
    });
  }

  L.Icon.MarkerCluster = L.Icon.extend({
    options: {
      iconSize: new L.Point(44, 44),
      className: 'prunecluster leaflet-markercluster-icon'
    },

    createIcon: function () {
      // based on L.Icon.Canvas from shramov/leaflet-plugins (BSD licence)
      var e = document.createElement('canvas');
      this._setIconStyles(e, 'icon');
      var s = this.options.iconSize;
      if (L.Browser.retina) {
          e.width = s.x + s.x;
          e.height = s.y + s.y;
      } else {
          e.width = s.x;
          e.height = s.y;
      }
      this.draw(e.getContext('2d'), e.width, e.height);
      return e;
    },

    createShadow: function () {
      return null;
    },

    draw: function(canvas, width, height) {
      var xa = 2, xb = 50, ya = 18, yb = 21;
      var r = ya + (this.population - xa) * ((yb - ya) / (xb - xa));
      var radiusMarker = Math.min(r, 21),
      radiusCenter = 11,
      center = width / 2;
      if (L.Browser.retina) {
        canvas.scale(2, 2);
        center /= 2;
        canvas.lineWidth = 0.5;
      }
      canvas.strokeStyle = 'rgba(0,0,0,0.25)';
      var start = 0, stroke = true;
      for (var i = 0, l = colors.length; i < l; ++i) {
        var size = this.stats[i] / this.population;
        if (size > 0) {
          stroke = size != 1;
          canvas.beginPath();
          canvas.moveTo(center, center);
          canvas.fillStyle = colors[i];
          var from = start + 0.0,
              to = start + size * pi2;
          if (to < from || size == 1) {
              from = start;
          }
          canvas.arc(center, center, radiusMarker, from, to);
          start = start + size * pi2;
          canvas.lineTo(center, center);
          canvas.fill();
          if (stroke) {
            canvas.stroke();
          }
          canvas.closePath();
        }
      }
      if (!stroke) {
        canvas.beginPath();
        canvas.arc(center, center, radiusMarker, 0, Math.PI * 2);
        canvas.stroke();
        canvas.closePath();
      }

      canvas.beginPath();
      canvas.fillStyle = 'white';
      canvas.moveTo(center, center);
      canvas.arc(center, center, radiusCenter, 0, Math.PI * 2);
      canvas.fill();
      canvas.closePath();
      canvas.fillStyle = '#454545';
      canvas.textAlign = 'center';
      canvas.textBaseline = 'middle';
      canvas.font = 'bold '+(this.population < 100 ? '12' : (this.population < 1000 ? '11' : '9'))+'px sans-serif';
      canvas.fillText(this.population, center, center, radiusCenter*2);
    }
  });

  votesList.forEach(function(vote) {
    if (layerGroups[vote.wordName] == undefined) {
   		layerGroups[vote.wordName] = new PruneClusterForLeaflet();
    }

    if (wordsCounter[vote.wordName] == undefined) {
      wordsCounter[vote.wordName] = 1;
    } else {
      wordsCounter[vote.wordName] += 1;
    }

    marker = new PruneCluster.Marker(vote.lat, vote.lon);
    marker.data.popup = vote.wordName;

    if (vote.wordEmotion == "positive") {
      marker.category = 0;
    } else if (vote.wordEmotion == "negative") {
      marker.category = 1;
    } else if (vote.wordEmotion == "neutral") {
      marker.category = 2;
    } else {
      marker.category = 3;
    }

    marker.data.icon = customColorIcon;

    layerGroups[vote.wordName].RegisterMarker(marker);
    allWords.RegisterMarker(marker);
  });

  entryMapElement.addLayer(allWords);
  control.addBaseLayer(allWords, '<b>All Words</b>');

  // Sort words in descending order of their number
  sortedWords = Object.keys(wordsCounter).sort(function(a,b) {
    return wordsCounter[b]-wordsCounter[a]
  });

  sortedWords.forEach(function(wordName) {
    wordText = wordName + ' (' + wordsCounter[wordName] + ')';
    control.addBaseLayer(layerGroups[wordName], wordText);
  });

  control.addTo(entryMapElement);

  if (votesListSize) {
    // When there are markers available, fit the map around them.
    entryMapElement.fitBounds(votesList);
  } else {
    // Show the entire world when no markers are set.
    entryMapElement.fitWorld();
  }

  entryMapElement.on('baselayerchange', function(e) {
    entryMapElement.fitBounds(votesList);
  });

  return true;
}


/**
 * Initialize a Leaflet map.
 */
function addMap(selector) {
  var map_box_token = 'pk.eyJ1IjoibGVzdWs5MyIsImEiOiJjaXR1MmxmNjkwMDBkMnRxZjUycWsybHV2In0.W2kq8LhM35F5B0yuAQt_kQ';
  var mapBoxStreets = L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=' + map_box_token, {
		attribution: '© <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>.',
    id: 'mapbox.streets'
	});

  var thunderforestOutdoors = L.tileLayer('https://{s}.tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=bf8ec5301a664cfca62e19ebaa7643fb', {
    attribution: '&copy; <a href="http://www.thunderforest.com/">Thunderforest</a>, &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>.',
	});

  var openStreetMap = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
	});

  var mapElement = L.map(selector, {
    maxZoom: 11,
		layers: [mapBoxStreets],
    fullscreenControl: { pseudoFullscreen: false }
	});

  return mapElement;
}
