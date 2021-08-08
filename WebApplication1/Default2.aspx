﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default2.aspx.cs" Inherits="WebApplication1.Default2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
      <style>
    text{
      font-size: 16px;
      font-family: Open Sans, sans-serif;
    }
    text.title{
      font-size: 24px;
      font-weight: 500;
    }
      text.subTitle{
        font-weight: 500;
        fill: #777777;
      }
      text.caption{
        font-weight: 400;
        font-size: 14px;
        fill: #777777;
      }
      text.label{
        font-weight: 600;
      }
    
      text.valueLabel{
       font-weight: 300;
      }
    
      text.yearText{
        font-size: 64px;
        font-weight: 700;
        opacity: 0.25;
      }
      .tick text {
        fill: #777777;
      }
      .xAxis .tick:nth-child(2) text {
        text-anchor: start;
      }
      .tick line {
        shape-rendering: CrispEdges;
        stroke: #dddddd;
      }
      .tick line.origin{
        stroke: #aaaaaa;
      }
      path.domain{
        display: none;
      }
  </style>
    <form id="form1" runat="server">
        <script src="http://d3js.org/d3.v5.min.js"></script>
       <script src="https://d3js.org/d3-array.v2.min.js"></script>
    <div>
        <script>
            



            var svg = d3.select("body").append("svg")
        .attr("width", 960)
        .attr("height", 600);
    
    
    
            var tickDuration = 500;
    
            var top_n = 12;
            var height = 600;
            var width = 960;
    
            const margin = {
                top: 80,
                right: 0,
                bottom: 5,
                left: 0
            };
  
            let barPadding = (height-(margin.bottom+margin.top))/(top_n*5);
      
            let title = svg.append('text')
             .attr('class', 'title')
             .attr('y', 24)
             .html('18 years of Interbrand’s Top Global Brands');
  
            let subTitle = svg.append("text")
             .attr("class", "subTitle")
             .attr("y", 55)
             .html("Brand value, $m");
   
            let caption = svg.append('text')
             .attr('class', 'caption')
             .attr('x', width)
             .attr('y', height-5)
             .style('text-anchor', 'end')
             .html('Source: Interbrand');

            let year = 2000;





            margin = ({top: 16, right: 6, bottom: 6, left: 0});
            barSize = 48;
            n=12;
            duration = 250;
            const keyframes = [];


            d3.csv('category-brands.csv').then(function (data) {
                debugger;
                //data=d3.group(data, d => d.name)
                names = new Set(data.map(d => d.name));


                var v=d3.rollup(data, ([d]) => d.value, d=>d.date, d => d.name);

                datevalues = Array.from(d3.rollup(data, ([d]) => d.value, d => d.date, d => d.name))
                    .map(([date, data]) => [formatDate(date), data]).sort(([a], [b]) => d3.ascending(a, b))

                //rank(name => datevalues[0][1].get(name))

                
                let ka, a, kb, b,k=10;
                for ([[ka, a], [kb, b]] of d3.pairs(datevalues)) {
                  for (let i = 0; i < k; ++i) {
                      const t = i / k;

                      var gh= (ka * (1 - t) + kb * t);

                    keyframes.push([
                      formatDate(kb),
                      rank(name => (a.get(name) || 0) * (1 - t) + (b.get(name) || 0) * t)
                    ]);
                  }
                 }
                 keyframes.push([formatDate(kb), rank(name => b.get(name) || 0)]);

            nameframes = d3.groups(keyframes.flatMap(([, data]) => data), d => d.name);

            prev = new Map(nameframes.flatMap(([, data]) => d3.pairs(data, (a, b) => [b, a])))

            next = new Map(nameframes.flatMap(([, data]) => d3.pairs(data)));

            height = 598
            width=1100;

            const svg = d3.create("svg")
          .attr("viewBox", [0, 0, width, height]);

            const updateBars = bars(svg);
            const updateAxis = axis(svg);
            const updateLabels = labels(svg);
            const updateTicker = ticker(svg);

            //yield svg.node();

            for (const keyframe of keyframes) {
              const transition = svg.transition()
                  .duration(duration)
                  .ease(d3.easeLinear);

                // Extract the top bar’s value.
              x.domain([0, keyframe[1][0].value]);

              updateAxis(keyframe, transition);
              updateBars(keyframe, transition);
              updateLabels(keyframe, transition);
              updateTicker(keyframe, transition);

             // invalidation.then(() => svg.interrupt());
              transition.end();
            }

             function bars(svg) {
                let bar = svg.append("g")
                    .attr("fill-opacity", 0.6)
                  .selectAll("rect");

                return ([date, data], transition) => bar = bar
                  .data(data.slice(0, n), d => d.name)
                  .join(
                    enter => enter.append("rect")
                      .attr("fill", 'red')
                      .attr("height", y.bandwidth())
                      .attr("x", x(0))
                      .attr("y", d => y((prev.get(d) || d).rank))
                      .attr("width", d => x((prev.get(d) || d).value) - x(0)),
                    update => update,
                    exit => exit.transition(transition).remove()
                      .attr("y", d => y((next.get(d) || d).rank))
                      .attr("width", d => x((next.get(d) || d).value) - x(0))
                  )
                  .call(bar => bar.transition(transition)
                    .attr("y", d => y(d.rank))
                    .attr("width", d => x(d.value) - x(0)));
            }

            function labels(svg) {
                let label = svg.append("g")
                    .style("font", "bold 12px var(--sans-serif)")
                    .style("font-variant-numeric", "tabular-nums")
                    .attr("text-anchor", "end")
                  .selectAll("text");

                return ([date, data], transition) => label = label
                  .data(data.slice(0, n), d => d.name)
                  .join(
                    enter => enter.append("text")
                      .attr("transform", d => `translate(${x((prev.get(d) || d).value)},${y((prev.get(d) || d).rank)})`)
            .attr("y", y.bandwidth() / 2)
            .attr("x", -6)
            .attr("dy", "-0.25em")
            .text(d => d.name)
            .call(text => text.append("tspan")
              .attr("fill-opacity", 0.7)
              .attr("font-weight", "normal")
              .attr("x", -6)
              .attr("dy", "1.15em")),
          update => update,
          exit => exit.transition(transition).remove()
            .attr("transform", d => `translate(${x((next.get(d) || d).value)},${y((next.get(d) || d).rank)})`)
            .call(g => g.select("tspan").tween("text", d => textTween(d.value, (next.get(d) || d).value)))
    )
            .call(bar => bar.transition(transition)
              .attr("transform", d => `translate(${x(d.value)},${y(d.rank)})`)
              .call(g => g.select("tspan").tween("text", d => textTween((prev.get(d) || d).value, d.value))))
            }




            function axis(svg) {
                const g = svg.append("g")
                    .attr("transform", `translate(0,${margin.top})`);

            x = d3.scaleLinear([0, 1], [margin.left, width - margin.right]);
                   
            y = d3.scaleBand()
    .domain(d3.range(n + 1))
    .rangeRound([margin.top, margin.top + barSize * (n + 1 + 0.1)])
    .padding(0.1)

            const axis = d3.axisTop(x)
                .ticks(width / 160)
                .tickSizeOuter(0)
                .tickSizeInner(-barSize * (n + y.padding()));

            return (_, transition) => {
                g.transition(transition).call(axis);
            g.select(".tick:first-of-type text").remove();
            g.selectAll(".tick:not(:first-of-type) line").attr("stroke", "white");
            g.select(".domain").remove();
            };
            }

            function ticker(svg) {
                const now = svg.append("text")
                    .style("font", `bold ${barSize}px var(--sans-serif)`)
                    .style("font-variant-numeric", "tabular-nums")
                    .attr("text-anchor", "end")
                    .attr("x", width - 6)
      .attr("y", margin.top + barSize * (n - 0.45))
      .attr("dy", "0.32em")
      .text(formatDate(keyframes[0][0]));

            return ([date], transition) => {
                transition.end().then(() => now.text(formatDate(date)));
            };
            }



            });

           


           

            formatNumber = d3.format(",d")

            

            function textTween(a, b) {
                const i = d3.interpolateNumber(a, b);
                return function(t) {
                    this.textContent = formatNumber(i(t));
                };
            }

            

            function rank(value) {
                
                const data = Array.from(names, name => ({name, value: value(name)}));
                data.sort((a, b) => d3.descending(a.value, b.value));
                for (let i = 0; i < data.length; ++i) data[i].rank = Math.min(n, i);
                return data;
            }
            function formatDate(date) {
                var d = new Date(date),
                    month = '' + (d.getMonth() + 1),
                    day = '' + d.getDate(),
                    year = d.getFullYear();

                if (month.length < 2) 
                    month = '0' + month;
                if (day.length < 2) 
                    day = '0' + day;

                return [year, month, day].join('-');
            }
        </script>
    </div>
    </form>
</body>
</html>
