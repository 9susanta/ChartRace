﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default3.aspx.cs" Inherits="WebApplication1.Default3" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <title>
    FabDev | Bar chart race generator
  </title>
  <meta property="og:title" content="Opensource bar chart race generator">
  <meta property="og:description" content="Generate your own bar chart race from a csv file thanks to this open source tool made by FabDev">
  <meta property="og:image" content="https://fabdevgit.github.io/barchartrace/css/demo.png">
  <meta property="og:url" content="https://fabdevgit.github.io/barchartrace/">
  <meta name="twitter:card" content="summary_large_image">
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="Generate your own bar chart race from a csv file thanks to this open source tool made by FabDev">
  <meta name="keywords" content="Opensource bar chart race generator">
  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
  <link rel="stylesheet" href="style.css">
  <link rel="icon" href="css/favicon.png">
  <script>
      (function (i, s, o, g, r, a, m) {
          i['GoogleAnalyticsObject'] = r;
          i[r] = i[r] || function () {
              (i[r].q = i[r].q || []).push(arguments)
          }, i[r].l = 1 * new Date();
          a = s.createElement(o),
              m = s.getElementsByTagName(o)[0];
          a.async = 1;
          a.src = g;
          m.parentNode.insertBefore(a, m)
      })(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');

      ga('create', 'UA-26787637-13', 'auto');
      ga('send', 'pageview');
  </script>
</head>
<body>
<main class="main-content" id="app">
  <a href="https://github.com/FabDevGit/barchartrace" class="github-corner" aria-label="View source on GitHub">
    <svg width="80" height="80" viewBox="0 0 250 250" style="fill:#70B7FD; color:#fff; position: absolute; top: 0; border: 0; right: 0;z-index: 100;" aria-hidden="true">
      <path d="M0,0 L115,115 L130,115 L142,142 L250,250 L250,0 Z"></path>
      <path d="M128.3,109.0 C113.8,99.7 119.0,89.6 119.0,89.6 C122.0,82.7 120.5,78.6 120.5,78.6 C119.2,72.0 123.4,76.3 123.4,76.3 C127.3,80.9 125.5,87.3 125.5,87.3 C122.9,97.6 130.6,101.9 134.4,103.2" fill="currentColor" style="transform-origin: 130px 106px;" class="octo-arm"></path>
      <path d="M115.0,115.0 C114.9,115.1 118.7,116.5 119.8,115.4 L133.7,101.6 C136.9,99.2 139.9,98.4 142.2,98.6 C133.8,88.0 127.5,74.4 143.8,58.0 C148.5,53.4 154.0,51.2 159.7,51.0 C160.3,49.4 163.2,43.6 171.4,40.1 C171.4,40.1 176.1,42.5 178.8,56.2 C183.1,58.6 187.2,61.8 190.9,65.4 C194.5,69.0 197.7,73.2 200.1,77.6 C213.8,80.2 216.3,84.9 216.3,84.9 C212.7,93.1 206.9,96.0 205.4,96.6 C205.1,102.4 203.0,107.8 198.3,112.5 C181.9,128.9 168.3,122.5 157.7,114.1 C157.9,116.9 156.7,120.9 152.7,124.9 L141.0,136.5 C139.8,137.7 141.6,141.9 141.8,141.8 Z" fill="currentColor" class="octo-body"></path>
    </svg>
  </a>
  <section class="section">
    <div class="container">
      <h1 id="main-title" class=" text-center">Bar chart race generator</h1>
      <div class="card border">
        <div class="card-body">
          <div class="row">
            <div class="col-lg-6">
              <form @submit="checkForm">
                <div v-if="errors.length">
                  <b>Please correct the following error(s):</b>
                  <ul>
                    <li v-for="error in errors">(( error ))</li>
                  </ul>
                </div>
                <div class="form-group">
                  <label for="customFile">CSV file</label>
                  <div class="custom-file">
                    <input type="file" class="custom-file-input" id="customFile" @change="loadFile"
                           accept=".csv, text/plain, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel"
                           aria-describedby="passwordHelpBlock">
                    <small id="passwordHelpBlock" class="form-text text-muted">
                      <a href="#myModal" data-toggle="modal">show accepted csv formats</a>
                    </small>

                    <label class="custom-file-label" for="customFile" ref="filelabel">((fileplaceholder))</label>
                  </div>
                </div>
                <div class="form-group">
                  <label for="duration">Animation duration (in s)</label>
                  <input id="duration" v-model="duration" class="form-control" type="number" name="duration" min="0">
                </div>
                <div class="form-group">
                  <label for="top_n">Number of bars to display</label>
                  <input id="top_n" v-model="top_n" class="form-control" type="number" name="top_n" min="0">
                </div>
                <div class="form-group">
                  <label for="title">Title</label>
                  <input id="title" v-model="title" class="form-control" type="text" name="title">
                </div>
                <div class="form-group text-center">
                  <button type="button" v-if="!csv_data" class="btn btn-outline-primary disabled">Generate Bar Chart Race</button>
                  <button type="submit" v-if="csv_data" class="btn btn-primary">Generate Bar Chart Race</button>
                </div>
              </form>
            </div>
            <div class="col-lg-6 border-left d-lg-block">
              <label for="">Example files</label>
              <table class="table table-bordered">
                <tbody>
                <tr>
                  <td>StackOverflow questions per language</td>
                  <td><a href="#" @click.prevent="loadExample('stackoverflow')">load data</a></td>
                  <td><a href="datasets/stackoverflow.csv">Download</a></td>
                </tr>
                <tr>
                  <td>Total cases of COVID-19 per country</td>
                  <td><a href="" @click.prevent="loadExample('covid19')">load data</a></td>
                  <td><a href="datasets/covid19-data.csv">Download</a></td>
                </tr>
                <tr>
                  <td>ATP Tennis ranking</td>
                  <td><a href="" @click.prevent="loadExample('tennis')">load data</a></td>
                  <td><a href="datasets/tennis.csv">Download</a></td>
                <tr>
                  <td>CO2 Emissions per country</td>
                  <td><a href="" @click.prevent="loadExample('co2')">load data</a></td>
                  <td><a href="datasets/co2.csv">Download</a></td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
      <hr>
      <div id="chart-card" class="card">
        <div class="card-body position-relative">
          <div class="text-right mb-4">
            <button type="button" class="btn btn-xs btn-outline-primary" v-on:click="stopRace">Stop</button>
            <button type="button" class="btn btn-xs btn-outline-primary" v-on:click="checkForm">Restart</button>
          </div>
          <h5 class="card-title" id="graph-title">((title))</h5>
          <div id="chartDiv" style="width:100%; height: 650px"></div>
          <p style="position:absolute;top:50%;left:50%;font-size:1.125rem;transform: translate(-50%,-50%)" v-if="interval == null">Please upload data first</p>
        </div>
      </div>
    </div>
  </section>
  <!-- Modal -->
  <div class="modal fade" id="myModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <h2 class="modal-title" id="exampleModalLabel">Accepted csv formats</h2>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <p>Input should be a csv file. <br>
            Dates should be <span class="font-weight-bold">YYYY-MM-DD</span>.</p>
          <p><span class="font-weight-bold">Option 1 :</span> one row per date (ordered) and one column per contender</p>
          <table class="table">
            <thead class="thead-light">
            <tr>
              <th>Date</th>
              <th>Name1</th>
              <th>Name2</th>
            </tr>
            </thead>
            <tbody>
            <tr>
              <td>2018-01-01</td>
              <td>1</td>
              <td>1</td>
            </tr>
            <tr>
              <td>2018-02-01</td>
              <td>2</td>
              <td>3</td>
            </tr>
            <tr>
              <td>2018-03-01</td>
              <td>4</td>
              <td>7</td>
            </tr>
            </tbody>
          </table>
          <p><span class="font-weight-bold">Option 2 :</span> one row per contender and per date</p>
          <table class="table">
            <thead class="thead-light">
            <tr>
              <th>Date</th>
              <th>Name</th>
              <th>Value</th>
            </tr>
            </thead>
            <tbody>
            <tr>
              <td>2018-01-01</td>
              <td>Name1</td>
              <td>1</td>
            </tr>
            <tr>
              <td>2018-01-01</td>
              <td>Name2</td>
              <td>3</td>
            </tr>
            <tr>
              <td>2018-02-01</td>
              <td>Name1</td>
              <td>2</td>
            </tr>
            <tr>
              <td>2018-02-01</td>
              <td>Name2</td>
              <td>3</td>
            </tr>
            <tr>
              <td>2018-03-01</td>
              <td>Name1</td>
              <td>4</td>
            </tr>
            <tr>
              <td>2018-03-01</td>
              <td>Name2</td>
              <td>7</td>
            </tr>
            </tbody>
          </table>

        </div>
      </div>
    </div>
  </div>
</main>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/PapaParse/4.1.2/papaparse.min.js"></script>
<script src="https://d3js.org/d3.v5.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.15/lodash.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI" crossorigin="anonymous"></script>
<script src="index.js"></script>
<script>
    const app = new Vue({
        el: '#app',
        data: {
            errors: [],
            file: null,
            csv_data: null,
            interval: null,
            duration: 20,
            tickDuration: 500,
            top_n: 10,
            title: "My bar chart",
            fileplaceholder: "Choose file"
        },
        methods: {
            loadExample: function (setting_name) {
                var self = this;
                self.duration = settings[setting_name].duration;
                self.top_n = settings[setting_name]['top_n'];
                self.title = settings[setting_name].title;
                Papa.parse(settings[setting_name].url, {
                    download: true,
                    header: true,
                    skipEmptyLines: true,
                    complete: function (results) {
                        if (Object.keys(results.data[0]).length === 3) {
                            results.data = reshapeData(results.data)
                        }
                        self.csv_data = results.data;
                    }
                }
                )
            },
            loadFile: function (e) {
                var self = this;
                this.file = e.target.files[0];
                this.fileplaceholder = this.file.name;
                Papa.parse(self.file, {
                    header: true,
                    skipEmptyLines: true,
                    complete: function (results) {
                        if (Object.keys(results.data[0]).length === 3) {
                            results.data = reshapeData(results.data)
                        }
                        self.csv_data = results.data;
                        self.top_n = Math.min(20, Object.keys(self.csv_data[0]).length - 1)
                    }
                });


            },
            stopRace: function () {
                if (!this.interval) {
                    return
                } else {
                    this.interval.stop()
                }
            },
            checkForm: function (e) {
                var self = this;
                if (self.interval !== null) {
                    self.interval.stop()
                }
                if (!this.csv_data) {
                    return
                }
                if (self.tickDuration && self.top_n) {
                    e.preventDefault();
                    this.top_n = parseInt(self.top_n);
                    this.duration = parseInt(self.duration);
                    this.tickDuration = self.duration / self.csv_data.length * 1000
                    let chartDiv = document.getElementById("chartDiv");
                    var data = JSON.parse(JSON.stringify(self.csv_data))
                    self.interval = createBarChartRace(data, self.top_n, self.tickDuration);
                }

                self.errors = [];

                if (!self.csv_data) {
                    self.errors.push('csv file is required');
                }
                if (!self.tickDuration) {
                    self.errors.push('Time between frames required.');
                }
                if (!self.top_n) {
                    self.errors.push('Number of bars to display required.');
                }
                e.preventDefault();
                window.scrollTo({top: $("#chart-card").offset().top - 10, behavior: 'smooth'});
            }
        },
        delimiters: ["((", "))"]

    });

    d3.csv('category-brands.csv').then(function (data) {
        debugger;
        //var v=reshapeData(data);
        //var top_n = 10;
        //var duration = 200;
        //var tickDuration = duration / v.length * 1000
        //let chartDiv = document.getElementById("chartDiv");
        //var data = JSON.parse(JSON.stringify(v))
        //self.interval = createBarChartRace(data, top_n, tickDuration);



        var self = this;
        self.csv_data=reshapeData(data)
        
        if (!this.csv_data) {
            return
        }
            
            this.top_n = 20;
            this.duration = 20;
            this.tickDuration = self.duration / self.csv_data.length * 1000
            let chartDiv = document.getElementById("chartDiv");
            var data = JSON.parse(JSON.stringify(self.csv_data))
            self.interval = createBarChartRace(data, self.top_n, self.tickDuration);

    })

    /*
    reshapes the data from the second accepted csv format to the other :
    (one row per contender and per date) => (one row per date (ordered) and one column per contender.)
    */
    function reshapeData(data) {
        debugger;
        // groupby dates (first column)
        column_names = new Set(data.map(x => x[Object.keys(x)[1]]));
        const grouped_by_date = _.groupBy(data, (e) => e[Object.keys(e)[0]]);
        return Object.keys(grouped_by_date).sort().map((k) => {
            item = {'date': k};
        column_names.forEach((n) => item[n] = 0);
        grouped_by_date[k].forEach((e) => item[e[Object.keys(e)[1]]] = e[Object.keys(e)[2]]);
        return item
    })

    }

    // settings for the example data
    const settings = {
        "covid19": {
            "duration": 30,
            "top_n": 10,
            "title": "Total cases of COVID-19 per country",
            "url": "https://raw.githubusercontent.com/FabDevGit/barchartrace/master/datasets/covid19-data.csv"
        },
        "stackoverflow": {
            "duration": 30,
            "top_n": 10,
            "title": "StackOverflow questions per language",
            "url": "https://raw.githubusercontent.com/FabDevGit/barchartrace/master/datasets/stackoverflow.csv"
        },
        "tennis": {
            "duration": 150,
            "top_n": 10,
            "title": "ATP tennis ranking",
            "url": "https://raw.githubusercontent.com/FabDevGit/barchartrace/master/datasets/tennis.csv"
        },
        "co2": {
            "duration": 30,
            "top_n": 10,
            "title": "CO2 Emissions from Fossil Fuels per capita, between 1950 and 2014 (in metric tons)",
            "url": "https://raw.githubusercontent.com/FabDevGit/barchartrace/master/datasets/co2.csv"
        }
    }


</script>
</body>
</html>






