<%@ Page Title="Contact" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="WebApplication1.Contact" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
          <script src="https://d3js.org/d3.v6.min.js"></script>
        <div id="div">
            
        </div>
        <script>
            let chartDiv = document.getElementById("div");
            var bodySelection = d3.select(chartDiv);

            var svgSelection = bodySelection.append("svg")
                  .attr("width", 50)
                  .attr("height", 50);

            var circleSelection = svgSelection.append("circle")
                  .attr("cx", 25)
                  .attr("cy", 25)
                  .attr("r", 25)
                  .style("fill", "purple");


            var theData = [1, 2, 3];

            var p = d3.select(chartDiv).selectAll("p")
              .data(theData)
              .enter()
              .append("p").text('susanta');

        </script>

</asp:Content>
