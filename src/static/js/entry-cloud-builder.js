var d3 = require( './vendor/d3.custom.min' );
var d3Cloud = require( './vendor/d3.layout.cloud.min' );


/**
 * Attach d3.layout.cloud()
 * @return bool
 *   Determines if entryCloudBuilder completed it's operation.
 *   True means we don't need to re-call this function.
 */
function entryCloudBuilder(selector, wordsList) {

  var entryCloudElement = document.getElementById(selector);

  if (!entryCloudElement) {
    // Element doesn't exist yet.
    return false;
  }

  var w = entryCloudElement.offsetWidth,
      h = entryCloudElement.offsetHeight,
      minVotes = 1,
      maxVotes = 1;

  if (wordsList.length) {
    minVotes = wordsList[wordsList.length - 1].votesCount;
    maxVotes = wordsList[0].votesCount;
  }

  var max, fontSize;

  var layout =  d3Cloud()
                  .size([w, h])
                  .rotate(0)
                  .fontSize(function(d) {
                    return fontSize(+d.votesCount);
                  })
                  .font('impact')
                  .spiral('archimedean')
                  .text(function(d) {
                    return d.name;
                  })
                  .on("end", draw);

  //Construct the word cloud's SVG element
  var svg = d3.select(entryCloudElement)
              .html(null)
              .append("svg")
              .attr("width", w)
              .attr("height", h)
              .append("g")
              .attr("transform", "translate(" + [w >> 1, h >> 1] + ")");

  update();

  window.onresize = function(event) {
    update();
  };

  //Draw the word cloud
  function draw(words, bounds) {
    scale = bounds ? Math.min(
            w / Math.abs(bounds[1].x - w / 2),
            w / Math.abs(bounds[0].x - w / 2),
            h / Math.abs(bounds[1].y - h / 2),
            h / Math.abs(bounds[0].y - h / 2)) / 2 : 1;

    var text = svg.selectAll("text").data(words, function(d) { return d.text; });

    text.transition()
        .duration(1000)
        .attr("transform", function(d) {
          return "translate(" + [d.x, d.y] + ")";
        })
        .style("font-size", function(d) {
          return d.size + "px";
        });

    //Entering words
    text.enter()
        .append("text")
        .attr("id", function(d) {
          return d.id;
        })
        .attr("text-anchor", "middle")
        .attr("transform", function(d) {
          return "translate(" + [d.x, d.y] + ")";
        })
        .style("font-size", function(d) {
          return d.size + "px";
        })
        .style("font-family", function(d) {
          return d.font;
        })
        .style("fill", function(d) {
          return fillColor(d, minVotes, maxVotes);
        })
        .style("opacity", 0)
        .transition()
        .duration(600)
        .style("opacity", 1)
        .text(function(d) {
          return d.text;
        })

    svg.transition()
       .attr("transform", "translate(" + [w >> 1, h >> 1] + ")scale(" + scale + ")");
  }

  function update() {
    fontSize = d3.scaleSqrt().range([10, 30]).domain([minVotes, maxVotes]);
    layout.stop().words(wordsList).start();
  }

  return true;
}

function fillColor(d, minVotes, maxVotes) {
  var positiveColors = ["#A5D6A7", "#388E3C"],
      negativeColors = ["#EF9A9A", "#D32F2F"],
      neutralColors  = ["#FFE082", "#FFA000"],
      noneColors = neutralColors,
      firstColor = eval(d.emotion + "Colors[0]"),
      lastColor = eval(d.emotion + "Colors[" + d.emotion + "Colors.length - 1" + "]");

  var wordColor = d3.scaleSqrt()
                    .domain([minVotes, maxVotes])
                    .range([firstColor, lastColor]);

  return wordColor(d.votesCount);
}

module.exports = entryCloudBuilder;
