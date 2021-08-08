<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default5.aspx.cs" Inherits="WebApplication1.Default5" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>
  
  body {
    font: 12px sans-serif;
  }
  
  .domain{
    display: none;
  }
  
  .axis path {
    fill: #ff;
    stroke: #ff;
  }
  
  .axis .tick line {
    stroke-width: 1;
    stroke: #ff;
  }
  
  .axis line {
    stroke-width: 1px;
    fill: #ff;
    stroke: #ff;
    shape-rendering: crispEdges;
  }
  
</style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <svg width="960" height="500"></svg>
              <script src="https://d3js.org/d3.v4.min.js"></script>
                <script>
  var svg = d3.select("svg"),
    margin = {top: 40, right: 125, bottom: 50, left: 50},
    width = +svg.attr("width") - (margin.left + margin.right),
    height = +svg.attr("height") - margin.top - margin.bottom,
    g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
  
  var x = d3.scaleBand()
  		.padding(0.05)
  		.align(0.1)
  		.rangeRound([0, width]);
  
  var y = d3.scaleLinear()
  		.rangeRound([height,0]);
  
  var z = d3.scaleOrdinal(d3.schemeCategory10)
  
  var stack = d3.stack()
  		.offset(d3.stackOffsetExpand);
  
  d3.csv("Table 3A.csv", type, function(error, data) {
    if (error) throw error;
    
    data.sort(function(a,b) {return b[data.columns [1]] / b.total - a[data.columns[1]] / a.total; });
    
    x.domain(data.map(function(d) {return d.Race; }));
    z.domain(data.columns.slice(1));
    
    var series = g.selectAll(".series")
    	.data(stack.keys(data.columns.slice(1))(data))
    	.enter().append("g")
    		.attr("class", "series")
    		.attr("fill", function(d) {return z(d.key); });
    
    series.selectAll("rect")
    	.data(function(d) { return d;})
    	.enter().append("rect")
    		.attr("x", function(d) {return x(d.data.Race); })
    		.attr("y", function(d) {return y(d[1]); })
    		.attr("height", function(d) { return y(d[0]) - y(d[1]); })
    		.attr("width", x.bandwidth());
    
    g.append("g")
    		.attr("class", "axis")
    		.attr("transform", "translate(0," + height + ")")
    		.call(d3.axisBottom(x))
    	.append("text")
    		.attr("x", 0-(width / 2) )
        .attr("y",  15-(height + margin.bottom))
      	.attr("dy", "0.32em")
      	.attr("fill", "#000")
      	.attr("font-weight", "bold")
      	.attr("text-anchor", "middle")
      	.text("Race");
    
    g.append("g")
    		.attr("class", "axis")
    		.call(d3.axisLeft(y).ticks(10, "%"))
    	.append("text")
    		.attr("x", 0 - (height / 2))
    		.attr("y", 15 - margin.left)
      	.attr("dy", "0.32em")
      	.attr("fill", "#000")
      	.attr("font-weight", "bold")
      	.attr("text-anchor", "middle")
    		.attr("transform", "rotate(-90)")
      	.text("Percentage");
    
    var legend = series.append("g")
    	.attr("class", "legend")   
      .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; })
    	.attr("text-anchor", "start");
    
    legend.append("rect")
    		.attr("x", width - 15)
    		.attr("width", 19)
    		.attr("height", 19)
    		.attr("fill", function(d) {return z(d.key); });
    
    legend.append("text")
    		.attr("x", width + 6)
    		.attr("y", 9.5)
    		.attr("dy", "0.32em")
    		.text(function(d) {return d.key;});
  });

function type(d, i, columns) {
  for (i = 1, t = 0; i < columns.length; ++i) t += d[columns[i]] = +d[columns[i]];
  d.total = t;
  return d;
}  
</script>
        </div>
    </form>
</body>
</html>
