<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm2.aspx.cs" Inherits="WebApplication1.WebForm2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="https://d3js.org/d3.v6.min.js"></script>
    <script>
        d3.select("body")
            .selectAll("p")
            .data([4, 8, 15, 16, 23, 42])
            .enter().append("p")
            .text(function (d) { return "I’m number " + d + "!"; });
    </script>
</head>
<body>
<p></p>
</body>
</html>
