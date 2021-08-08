﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default1.aspx.cs" Inherits="WebApplication1.Default1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
   
</head>

<body>
   <style>
    body {
        font-family: sans-serif;
        font-size: 16px;
      }

    .legend{
        color: #ffffff;
        font-size: 10px;
    }


    text.title{
      font: 15px;
      font-family: Open Sans, sans-serif;
      font-weight: 550;
    }
    text.lineLable{
        font: 15px;
        font-family: Open Sans, sans-serif;
        font-weight: 550;
      }
    
      text.label{
        font: 20px;
        font-family: Open Sans, sans-serif;
        font-style:initial;
        font-weight: 500;
      }

    text.yearText{
        font: 25px;
        font-family: Open Sans, sans-serif;
        font-style:initial;
        font-weight: 700;
    }  
    .tick text {
        font: 17px;
        fill: #020202;
      }
    .tick line {
         shape-rendering: CrispEdges; 
        stroke: #d8d8d8;
      }

    .axis { font: 12px sans-serif; }  
     .x.axis path{
      stroke: rgb(150, 150, 150);
    }

    .y.axis path{
      stroke: rgb(150, 150, 150);
    }
    
    /* path.domain{
        display: none;
      } */
    a{
      font-size:14px;
      margin-right:30px;
        }

    svg {
        border: 1px solid #e5e5e5;      
      } 
    .shadow {
      -webkit-filter: drop-shadow( 0px 2px 2px rgba(90, 90, 90, 0.2) );
      filter: drop-shadow( 0px 2px 2px rgba(90,90,90,.1) );
}

  </style>
    <form id="form1" runat="server">
    <div>
       <script src="http://d3js.org/d3.v5.min.js"></script>
       <div id="graph"></div>
       <script>
          // width and height
          var margin = { top: 20, right: 60, bottom: 20, left: 40 },
              width = 1200 - margin.left - margin.right,
              height = 650 - margin.top - margin.bottom;

          duration = 1000

          // main content holder
          var svg = d3.select("#graph")
              .append("svg")
              .style("background", "#fff")
              .style("color", "#fff")
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom + 100)
              .attr("class", "graph-svg-component")
              .attr("fill", "currentColor")
              .attr("class", "shadow")
              .attr("font-family", "sans-serif")
              .attr("font-size", 10)
              .append("g")
              .attr("transform", "translate(" + (margin.left + 50) + "," + (margin.top + 40) + ")");


          // background grey    
          svg
              .append("rect")
              .attr("x", 0)
              .attr("y", 35)
              .attr("height", height - 30)
              .attr("width", width - 100)
              .style("fill", "#e5e5e5")
              //.style("fill", "url(#linear-gradient)")
              //.style("stroke", "black")
              .style("opacity", 0.01)

          // // add channel logo
          var myimage = svg.append('image')
              .attr('xlink:href', 'logo/your_logo_here.png')
              .attr('width', 150)
              .attr('height', 150)
              .attr('opacity', 0.5)
          myimage.attr('x', width - 230)
          myimage.attr('y', height - 30)

          // clip paths
          svg.append("defs")
              .append("clipPath")
              .attr("id", "clip")
              .append("rect")
              .attr("x", 10)
              .attr("y", 35)
              .attr("width", width)
              .attr("height", height - 30);

          svg.append("defs")
              .append("clipPath")
              .attr("id", "yaxisclip")
              .append("rect")
              .attr("x", -90)
              .attr("y", 30)
              .attr("width", width)
              .attr("height", height);

          svg.append("defs")
              .append("clipPath")
              .attr("id", "xaxisclip")
              .append("rect")
              .attr("x", 0)
              .attr("y", -(height - 30))
              .attr("width", width - 90)
              .attr("height", height + 100);

          // title of the chart    
          svg.append("text")
              .attr("class", "title")
              .attr("x", (margin.left + width - margin.right) / 2)
              .attr("y", margin.top - 40)
              .attr("dy", 10)
              .attr("text-anchor", "middle")
              .style("fill", "black")
              .call(text => text.append("tspan").attr("font-size", "17px").attr("fill-opacity", 0.8).text("← \xa0"))
              .call(text => text.append("tspan").attr("font-size", "21px").attr("font-weight", "bold").text("\xa0USA Covid-19\xa0"))
              .call(text => text.append("tspan").attr("font-size", "21px").attr("fill", "#021B79").attr("font-weight", "bold").text("\xa0Testings\xa0"))
              .call(text => text.append("tspan").attr("font-size", "21px").attr("font-weight", "bold").text("\xa0 vs \xa0"))
              .call(text => text.append("tspan").attr("font-size", "21px").attr("fill", "#c21500").attr("font-weight", "bold").text("\xa0Positive cases\xa0"))
              .call(text => text.append("tspan").attr("font-size", "17px").attr("fill-opacity", 0.8).text("\xa0 →"));


          // time format    
          var format = d3.timeFormat("%d-%b-%Y");
          var parseTime = d3.timeParse("%d-%b-%Y");
          var monthFormat = d3.timeFormat("%B %Y")

          var color = d3.scaleOrdinal(d3.schemeTableau10)

          // import json data
          d3.json("covid-19-us-daily.json").then(function (data) {

              // create array of dict for colors and and icons 
              var case_types = [{ 'id': 'positiveIncrease', "title": "Positive Cases", "color": ["#fff3cc", "#ffc500", "#c21500"], "flag": "coronavirus.png" },
              { 'id': 'totalTestResultsIncrease', "title": "Testings ", "color": ["#A7BFE8", "#0575E6", "#021B79"], "flag": "testing.png" }]

              //create chunk
              Object.defineProperty(Array.prototype, 'chunk', {
                  value: function (chunkSize) {
                      var R = [];
                      for (var i = 0; i < this.length; i += 1)
                          R.push(this.slice(i, i + chunkSize));
                      return R;
                  }
              });


              color.domain(d3.keys(data[0]).filter(function (key) {
                  return key !== "date";
              }));

              // extract coloumn names
              var names = d3.keys(data[0]).filter(function (key) {
                  return key !== "date";
              });
              
              // create chunked data
              final = data.chunk(14);


              // format dataset to be input in the line creation function
              final = final.map(function (d) {

                  countries = names.map(function (name) {
                      return {
                          name: name,
                          value: d.map(function (t) {
                              return {
                                  date: new Date(t.date),
                                  cases: !isNaN(t[name]) ? +t[name] : 0

                              };
                          })
                      }
                  });

                  return countries;
              })
              console.log("after formating data for input : ", final);


              // create color gradients
              for (i in names) {
                  //add gradient
                  console.log(names[i]);
                  console.log("color index:", case_types.find(e => e.id === names[i]).title);
                  var linearGradient = svg.append("defs")
                      .append("linearGradient")
                      .attr("gradientUnits", "userSpaceOnUse")
                      .attr("id", "linear-gradient-" + case_types.find(e => e.id === names[i]).id);

                  //.attr("gradientTransform", "rotate(45)");
                  linearGradient.append("stop")
                      .attr("offset", "5%")
                      .attr("stop-color", case_types.find(e => e.id === names[i]).color[0]);

                  linearGradient.append("stop")
                      .attr("offset", "15%")
                      .attr("stop-color", case_types.find(e => e.id === names[i]).color[1]);

                  linearGradient.append("stop")
                      .attr("offset", "35%")
                      .attr("stop-color", case_types.find(e => e.id === names[i]).color[2]);

              }


              // initialize the line :
              line = d3.line()
                  .curve(d3.curveBasis)
                  .x(function (d) {
                      //console.log("line x:",x(new Date(d.date))); 
                      return x(d.date);
                  })
                  .y(function (d) {
                      //console.log("line y:",y(d.cases));
                      if (d.cases > 0) {
                          return y(d.cases);
                      } else {
                          return y(-2)
                      }

                  });

              // Initialise a X axis:
              x = d3.scaleTime()
                  .range([0, width - 100])
              var xAxis = d3.axisBottom()
                  .scale(x)
                  .ticks(d3.timeWeek.every(1))
                  //.tickFormat(d3.timeFormat("%d %b"))
                  //.tickFormat(d3.time.week)
                  .tickFormat(function (d, i) {
                      return "Week" + "-" + d3.timeFormat("%W")(d) + " | " + d3.timeFormat("%d %B")(d)
                  })
                  .tickSizeInner(-height)
                  .tickPadding(10)

              svg.append("g")
                  .attr("transform", `translate(10,${height})`)
                  .attr("class", "x axis")
                  .attr("clip-path", "url(#xaxisclip)")
                  .call(xAxis);

              // Initialize an Y axis
              y = d3.scaleLinear().domain([0, 1])
                  .range([height, 2 * margin.top]);
              var yAxis = d3.axisLeft()
                  .scale(y)
                  .ticks(8)
              //.tickSizeInner(-(width-100));
              svg.append("g")
                  .attr("transform", `translate(10,0)`)
                  .attr("class", "y axis")
                  .attr("clip-path", "url(#yaxisclip)")


              var t = final[0][0].value
              var month = monthFormat(t[t.length - 1].date)
              var weekOfMonth = (0 | t[t.length - 1].date.getDate() / 7) + 1;


              let monthTxt = svg.append("text")
                  .attr("x", (width) / 2 - 50)
                  .attr("y", height + 50)
                  .attr("dy", 10)
                  .attr("text-anchor", "middle")
                  .style("fill", "black")
                  .attr("font-weight", "bold")
                  .attr("fill-opacity", 0.0)
                  .attr("font-size", "16px")
                  .text("← \xa0 " + month + " \xa0 →");


              var intervalId = null;

              console.log(final[final.length - 1][0].value.length);
              if (final[final.length - 1][0].value.length < 14) {
                  final = final.slice(0, final.length - 13)
              }

              console.log("final after remove last data:", final);

              var index = 0;
              //update[index];


              // update axis through out the loop in interval
              function updateAxis() {
                  //update x axis
                  svg.selectAll(".x.axis")
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .call(xAxis);


                  // update y axis
                  svg.selectAll(".y.axis")
                      .transition()
                      .ease(d3.easeCubic)
                      .duration(1000)
                      .call(yAxis);
              }

              // update line through out the loop in interval
              function makeLine(data) {

                  // generate line paths
                  var lines = svg.selectAll(".line").data(data).attr("class", "line");

                  // transition from previous paths to new paths
                  lines
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .attr("stroke-width", 5.0)
                      //.attr("stroke-opacity", 1)
                      .attr("stroke-opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .attr("d", d => line(d.value))
                      // .style("stroke", (d,i) =>
                      //     color(d.name)
                      // );
                      .attr("stroke", (d, i) => "url(#linear-gradient-" + d.name + ")");
                  //.attr("stroke", (d,i) =>  color(d.name) );

                  // enter any new data
                  lines
                      .enter()
                      .append("path")
                      .attr("class", "line")
                      .attr("fill", "none")
                      .attr("stroke-linejoin", "round")
                      .attr("stroke-linecap", "round")
                      .attr("clip-path", "url(#clip)")
                      .attr("stroke-width", 5.0)
                      //.attr("stroke-opacity", 1)
                      .attr("stroke-opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .attr("d", d => line(d.value))
                      // .style("stroke", (d,i) =>
                      //     color(d.name)
                      // )
                      .attr("stroke", (d, i) => "url(#linear-gradient-" + d.name + ")");
                  //.attr("stroke", (d,i) =>  color(d.name));

                  // exit
                  lines
                      .exit()
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .remove();
              }

              // update tip circle through out the loop in interval
              function makeTipCircle(data) {
                  // add circle. generetare new circles
                  circles = svg.selectAll(".circle").data(data)

                  //transition from previous circles to new
                  circles
                      .enter()
                      .append("circle")
                      .attr("class", "circle")
                      .attr("fill", "white")
                      .attr("clip-path", "url(#clip)")
                      .attr("stroke", "black")
                      .attr("stroke-width", 7.0)
                      .attr("opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .attr("stroke-opacity", function (d, i) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .attr("cx", d => x(d.value[d.value.length - 1].date))
                      .attr("cy", function (d) {

                          if (d.value[d.value.length - 1].cases > 0) {
                              return y(d.value[d.value.length - 1].cases);
                          } else {
                              return y(-2)
                          }
                      })
                      .attr("r", 17)
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)



                  //enter new circles
                  circles
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .attr("cx", d => x(d.value[d.value.length - 1].date))
                      .attr("cy", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return y(d.value[d.value.length - 1].cases);
                          } else {
                              return y(-2)
                          }
                      })
                      .attr("r", 17)
                      .attr("fill", "white")
                      .attr("stroke", "black")
                      .attr("stroke-width", 7.0)
                      .attr("opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .attr("stroke-opacity", function (d, i) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })


                  //remove and exit
                  circles
                      .exit()
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .attr("cx", d => x(d.value[d.value.length - 1].date))
                      .attr("cy", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return y(d.value[d.value.length - 1].cases);
                          } else {
                              return y(-2)
                          }
                      })
                      .attr("r", 17)
                      .remove()
              }

              // update lables through out the loop in interval
              function makeLabels(data) {
                  //generate name labels
                  names = svg.selectAll(".lineLable").data(data);

                  //transition from previous name labels to new name labels
                  names
                      .enter()
                      .append("text")
                      .attr("class", "lineLable")
                      .attr("font-size", "21px")
                      .attr("clip-path", "url(#clip)")
                      .style("fill", (d, i) => case_types.find(e => e.id === d.name).color[2])
                      .attr("opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .transition()
                      .ease(d3.easeLinear)
                      .attr("x", function (d) {
                          return x(d.value[d.value.length - 1].date) + 30;
                      })
                      .style('text-anchor', 'start')
                      .text(d => case_types.find(e => e.id === d.name).title)
                      .attr("y", function (d) {

                          if (d.value[d.value.length - 1].cases > 0) {
                              return y(d.value[d.value.length - 1].cases) - 5;
                          } else {
                              return y(-2)
                          }
                      })


                  // add new name labels
                  names
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .attr("x", function (d) {
                          return x(d.value[d.value.length - 1].date) + 30;
                      })
                      .attr("y", function (d) {

                          if (d.value[d.value.length - 1].cases > 0) {
                              return y(d.value[d.value.length - 1].cases) - 5;
                          } else {
                              return y(-2)
                          }

                      })
                      .attr("opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .attr("font-size", "21px")
                      .style("fill", (d, i) => case_types.find(e => e.id === d.name).color[2])
                      .style('text-anchor', 'start')
                      .text(d => case_types.find(e => e.id === d.name).title)


                  // exit name labels
                  names.exit()
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .style('text-anchor', 'start')
                      .remove();



                  //generate labels
                  labels = svg.selectAll(".label").data(data);

                  //transition from previous labels to new labels
                  labels
                      .enter()
                      .append("text")
                      .attr("class", "label")
                      .attr("font-size", "18px")
                      .attr("clip-path", "url(#clip)")
                      .style("fill", (d, i) => case_types.find(e => e.id === d.name).color[2])
                      .attr("opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .transition()
                      .ease(d3.easeLinear)
                      .attr("x", function (d) {
                          return x(d.value[d.value.length - 1].date) + 30;
                      })
                      .style('text-anchor', 'start')
                      .text(d => d3.format(',.0f')(d.value[d.value.length - 1].cases))
                      .attr("y", function (d) {

                          if (d.value[d.value.length - 1].cases > 0) {
                              return y(d.value[d.value.length - 1].cases) + 15;
                          } else {
                              return y(-2)
                          }
                      })


                  // add new labels
                  labels
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .attr("x", function (d) {
                          return x(d.value[d.value.length - 1].date) + 30;
                      })
                      .attr("y", function (d) {

                          if (d.value[d.value.length - 1].cases > 0) {
                              return y(d.value[d.value.length - 1].cases) + 15;
                          } else {
                              return y(-2)
                          }

                      })
                      .attr("opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .attr("font-size", "18px")
                      .style("fill", (d, i) => case_types.find(e => e.id === d.name).color[2])
                      .style('text-anchor', 'start')
                      //.text(d => d3.format(',.0f')(d.value[d.value.length-1].cases))
                      .tween("text", function (d) {
                          if (d.value[d.value.length - 1].cases !== 0) {
                              let i = d3.interpolateRound(d.value[d.value.length - 2].cases, d.value[d.value.length - 1].cases);
                              return function (t) {
                                  this.textContent = d3.format(',')(i(t));
                              };
                          }

                      });


                  // exit labels
                  labels.exit()
                      .transition()
                      .ease(d3.easeCubic)
                      .duration(duration)
                      .style('text-anchor', 'start')
                      .remove();

              }

              // update icons through out the loop in interval
              function makeImages(data) {
                  //select all images
                  images = svg.selectAll(".image").data(data)

                  images
                      .enter()
                      .append("image")
                      .attr("class", "image")
                      .attr("clip-path", "url(#clip)")
                      .attr('xlink:href', d => "continents/" + case_types.find(e => e.id === d.name).flag)
                      .attr("width", 40)
                      .attr("height", 40)
                      .attr("opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .attr("y", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return y(d.value[d.value.length - 1].cases) - 20;
                          } else {
                              return y(-2) - 15;
                          }

                      })
                      .attr("x", function (d) { return x(d.value[d.value.length - 1].date) - 20; })
                      .attr("preserveAspectRatio", "none")
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration);

                  //enter new circles
                  images
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)
                      .attr('xlink:href', d => "continents/" + case_types.find(e => e.id === d.name).flag)
                      .attr("width", 40)
                      .attr("height", 40)
                      .attr("opacity", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return 1;
                          } else {
                              return 0;
                          }
                      })
                      .attr("x", d => x(d.value[d.value.length - 1].date) - 20)
                      .attr("y", function (d) {
                          if (d.value[d.value.length - 1].cases > 0) {
                              return y(d.value[d.value.length - 1].cases) - 20;
                          } else {
                              return y(-2) - 15;
                          }
                      })
                      .attr("preserveAspectRatio", "none");

                  //remove and exit
                  images.exit()
                      .transition()
                      .ease(d3.easeLinear)
                      .duration(duration)

                      .remove()
              }

              var yaxismaxlimit = 0;

              // function to update the line in each frame
              function update() {

                  if (index < final.length) {

                      data = final[index];
                      //console.log("index: ",index)
                      //console.log("data_now: ",data);

                      var length = data[0].value.length;
                      //console.log("length:",length);

                      // Create the X axis:
                      var param = data[0].value
                      date_start = new Date(param[0].date)
                      date_end = new Date(param[param.length - 1].date)
                      date_end = new Date(new Date(date_end).setDate(new Date(date_end).getDate() + 6))

                      //console.log("dates: ",date_start,date_end);
                      x.domain([date_start, date_end]);

                      // Create the Y axis:
                      max_cases_value_of_each_country = data.map(o => Math.max(...o.value.map(v => v.cases)))
                      var maxOfValue = Math.max(...max_cases_value_of_each_country.map(o => o))
                      var minOfValue = Math.min(...max_cases_value_of_each_country.map(o => o));
                      if (maxOfValue < 10) {
                          maxOfValue = 10
                      }

                      if (maxOfValue > yaxismaxlimit) {
                          yaxismaxlimit = maxOfValue;
                      }

                      y.domain([0, maxOfValue]).nice();

                      updateAxis(x, y);

                      makeLine(data)

                      makeTipCircle(data)

                      makeImages(data)

                      makeLabels(data)

                      var weekOfMonth = (0 | data[0].value[data[0].value.length - 1].date.getDate() / 7) + 1;
                      var month = monthFormat(data[0].value[data[0].value.length - 1].date)
                      monthTxt
                          .transition()
                          .ease(d3.easeCubic)
                          .duration(2500)
                          .attr("fill-opacity", 0.7)
                          .text("← \xa0 " + month + " \xa0 →");

                      index = index + 1;

                  } else {
                      // clear inetrval at the end
                      clearInterval(intervalId);
                  }



              }
              // start the interval method 
              intervalId = setInterval(update, duration);

          });

 // merge and flatten the array
    //final = final.map((x,i) => [... final.slice(0,i+1)]).map(y=>y.flat())

    //console.log("after merge and flatten :", final)
      </script>
    </div>
    </form>
</body>
</html>
