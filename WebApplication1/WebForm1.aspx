<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="WebApplication1.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="https://d3js.org/d3.v4.min.js"></script>
     <style>
      body {
        margin: 0px;
      }
      .domain {
        display: none;
      }
      .tick line {
        stroke: #C0C0BB;
      }
      .tick text {
        fill: #8E8883;
        font-size: 14pt;
        font-family: sans-serif;
      }
      .axis-label {
        fill: #635F5D;
        font-size: 32pt;
        font-family: sans-serif;
      }
    </style>
     
   
</head>
<body>
    <form id="form1" runat="server">
       <svg width="960" height="500"></svg>
        <script>

            const xValue = d => d.netUsers;
            const xLabel = 'Internet Users';
            const yValue = d => d.country;
            const yLabel = 'Country';
            const margin = { left: 150, right: 30, top: 5, bottom: 75 };

            const svg = d3.select('svg');
            const width = svg.attr('width');
            const height = svg.attr('height');
            const innerWidth = width - margin.left - margin.right;
            const innerHeight = height - margin.top - margin.bottom;

            const g = svg.append('g')
                .attr('transform', `translate(${margin.left},${margin.top})`);
            const xAxisG = g.append('g')
                .attr('transform', `translate(0, ${innerHeight})`);
            const yAxisG = g.append('g');

            xAxisG.append('text')
                .attr('class', 'axis-label')
                .attr('x', innerWidth / 2)
                .attr('y', 55)
                .text(xLabel);

            const xScale = d3.scaleLinear();
            const yScale = d3.scaleBand()
                .paddingInner(0.3)
                .paddingOuter(0);

            const xTicks = 10;
            const xAxis = d3.axisBottom()
                .scale(xScale)
                .ticks(xTicks)
                .tickPadding(5)
                .tickFormat(d3.format('.0s'))
                .tickSize(-innerHeight);

            const yAxis = d3.axisLeft()
                .scale(yScale)
                .tickPadding(5)
                .tickSize(-innerWidth);

            const row = d => {
                const netUsersWithCommas = d['Internet Users 31 Mar 2017'];
                return {
                    country: d['Country or Region'],
                    netUsers: +netUsersWithCommas.replace(/,/g, '')
                };
            };

            d3.csv('data.csv', row, data => {
                yScale.domain(data.map(yValue).reverse())
                    .range([innerHeight, 0]);

                xScale.domain([0, d3.max(data, xValue)])
                    .range([0, innerWidth])
                    .nice(xTicks);

                g.selectAll('rect').data(data)
                    .enter().append('rect')
                    .attr('x', 0)
                    .attr('y', d => yScale(yValue(d)))
                    .attr('width', d => xScale(xValue(d)))
                    .attr('height', d => yScale.bandwidth())
                    .attr('fill', 'steelblue');

                xAxisG.call(xAxis);

                yAxisG.call(yAxis);

                yAxisG.selectAll('.tick line').remove();
            });
        </script>
    </form>
</body>
</html>
