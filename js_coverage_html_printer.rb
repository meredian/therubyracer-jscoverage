#
# Used for creating pretty HTML files with JSCoverage statistics
#

require 'cgi'

module JSCoverage
  class HTMLPrinter

    HeaderTemplatePath = "template_header.html"

    def self.coverage_rate percent
      return 'high' if percent >= 75
      return 'medium' if percent >= 50
      return 'low' if percent >= 25
      return 'terrible'
    end

    def self.create_single_file path, coverage_resolution, coverage_extended
      File.open(path, "w") do |f|
        f.puts format_document coverage_resolution, coverage_extended
      end
    end

    def self.format_document coverage_resolution, coverage_extended
      output = '<!DOCTYPE html><html>'
      output += HeaderTemplate
      output += format_body coverage_resolution, coverage_extended
      output += '</html>'
    end

    def self.format_body coverage_resolution, coverage_extended
      output = '<body><div id="coverage"><h1 id="overview">Coverage</h1>'
      output += format_menu coverage_resolution
      output += format_stats coverage_resolution
      output += '<div id="files">'
      coverage_resolution.each do |filename, coverage|
        output += format_file filename, coverage, coverage_extended[filename]
      end
      output += '</div></div><h4 align="center">Thanks <a href="https://github.com/visionmedia/mocha/">Mocha</a> for cool design</h4></body>'
    end

    def self.format_menu coverage_resolution
      output = '<div id="menu"><li><a href="#overview">overview</a></li>'
      coverage_resolution.each do |filename, coverage|
        output += %(<li><span class="cov #{coverage_rate coverage[:percent].to_i}">#{coverage[:percent].to_i}</span>)
        output += %(<a href="##{filename}"><span class="basename">#{filename}</span></a></li>')
      end
      output += '</div>'
    end

    def self.format_stats coverage_resolution
      overview = { total: 0, covered: 0, percent: 0}
      coverage_resolution.each do |filename, coverage|
        overview[:total] += coverage[:total]
        overview[:covered] += coverage[:covered]
      end
      overview[:percent] = (overview[:covered].to_f / overview[:total].to_f * 100).to_i
      output = %(<div id="stats" class="#{coverage_rate overview[:percent]}">)
      output += %(<div class="percentage">#{overview[:percent]}%</div>)
      output += %(<div class="sloc">#{overview[:total]}</div>)
      output += %(<div class="hits">#{overview[:covered]}</div>)
      output += %(<div class="misses">#{overview[:total] - overview[:covered]}</div></div>)
    end

    def self.format_file filename, coverage_short, coverage_full
      output = %(<div class="file"><h2 id="#{filename}">#{filename}</h2><div id="stats" class="#{coverage_rate coverage_short[:percent].to_i}">)
      output += %(<div class="percentage">#{coverage_short[:percent].to_i}%</div><div class="sloc">#{coverage_short[:total]}</div>)
      output += %(<div class="hits">#{coverage_short[:covered]}</div><div class="misses">#{coverage_short[:total] - coverage_short[:covered]}</div></div>)
      output += %(<table id="source"><thead><tr><th>Line</th><th>Hits</th><th>Source</th></tr></thead><tbody>)

      coverage_full.each_with_index do |line, index|
        output += format_line index + 1, line[:count], line[:source]
      end
      output += %(</tbody></table></div>)
    end

    def self.format_line index, count, source
      output = %(<tr #{'class="hit"' unless count.nil?}><td class="line">#{index}</td><td class="hits">#{count}</td><td class="source">#{source}</td></tr>)
    end

  end

  HeaderTemplate = <<HEADER_TEMPLATE
  <head><title>Javascript test coverage</title><script>

headings = [];

onload = function(){
  headings = document.querySelectorAll('h2');
};

onscroll = function(e){
  var heading = find(window.scrollY);
  if (!heading) return;
  var links = document.querySelectorAll('#menu a')
    , link;

  for (var i = 0, len = links.length; i < len; ++i) {
    link = links[i];
    link.className = link.getAttribute('href') == '#' + heading.id
      ? 'active'
      : '';
  }
};

function find(y) {
  var i = headings.length
    , heading;

  while (i--) {
    heading = headings[i];
    if (y > heading.offsetTop) {
      return heading;
    }
  }
}
</script><style>

body {
  font: 14px/1.6 "Helvetica Neue", Helvetica, Arial, sans-serif;
  margin: 0;
  color: #2C2C2C;
  border-top: 2px solid #ddd;
}

#coverage {
  padding: 60px;
}

h1 a {
  color: inherit;
  font-weight: inherit;
}

h1 a:hover {
  text-decoration: none;
}

.onload h1 {
  opacity: 1;
}

h2 {
  width: 80%;
  margin-top: 80px;
  margin-bottom: 0;
  font-weight: 100;
  letter-spacing: 1px;
  border-bottom: 1px solid #eee;
}

a {
  color: #8A6343;
  font-weight: bold;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

ul {
  margin-top: 20px;
  padding: 0 15px;
  width: 100%;
}

ul li {
  float: left;
  width: 40%;
  margin-top: 5px;
  margin-right: 60px;
  list-style: none;
  border-bottom: 1px solid #eee;
  padding: 5px 0;
  font-size: 12px;
}

ul::after {
  content: '.';
  height: 0;
  display: block;
  visibility: hidden;
  clear: both;
}

code {
  font: 12px monaco, monospace;
}

pre {
  margin: 30px;
  padding: 30px;
  border: 1px solid #eee;
  border-bottom-color: #ddd;
  -webkit-border-radius: 2px;
  -moz-border-radius: 2px;
  -webkit-box-shadow: inset 0 0 10px #eee;
  -moz-box-shadow: inset 0 0 10px #eee;
  overflow-x: auto;
}

img {
  margin: 30px;
  padding: 1px;
  -webkit-border-radius: 3px;
  -moz-border-radius: 3px;
  -webkit-box-shadow: 0 3px 10px #dedede, 0 1px 5px #888;
  -moz-box-shadow: 0 3px 10px #dedede, 0 1px 5px #888;
  max-width: 100%;
}

footer {
  background: #eee;
  width: 100%;
  padding: 50px 0;
  text-align: right;
  border-top: 1px solid #ddd;
}

footer span {
  display: block;
  margin-right: 30px;
  color: #888;
  font-size: 12px;
}

#menu {
  position: fixed;
  font-size: 12px;
  overflow-y: auto;
  top: 0;
  right: 0;
  margin: 0;
  height: 100%;
  padding: 15px 0;
  text-align: right;
  border-left: 1px solid #eee;
  -moz-box-shadow: 0 0 2px #888
     , inset 5px 0 20px rgba(0,0,0,.5)
     , inset 5px 0 3px rgba(0,0,0,.3);
  -webkit-box-shadow: 0 0 2px #888
     , inset 5px 0 20px rgba(0,0,0,.5)
     , inset 5px 0 3px rgba(0,0,0,.3);
  -webkit-font-smoothing: antialiased;
  background: url("data:image/png;base64,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");
}

#logo {
  position: fixed;
  bottom: 10px;
  right: 10px;
  background: rgba(255,255,255,.1);
  font-size: 11px;
  display: block;
  width: 20px;
  height: 20px;
  line-height: 20px;
  text-align: center;
  -webkit-border-radius: 20px;
  -moz-border-radius: 20px;
  -webkit-box-shadow: 0 0 3px rgba(0,0,0,.2);
  -moz-box-shadow: 0 0 3px rgba(0,0,0,.2);
  color: inherit;
}

#menu li a {
  display: block;
  color: white;
  padding: 0 35px 0 25px;
  -webkit-transition: background 300ms;
  -moz-transition: background 300ms;
}

#menu li {
  position: relative;
  list-style: none;
}

#menu a:hover,
#menu a.active {
  text-decoration: none;
  background: rgba(255,255,255,.1);
}

#menu li:hover .cov {
  opacity: 1;
}

#menu li .dirname {
  opacity: .60;
  padding-right: 2px;
}

#menu li .basename {
  opacity: 1;
}

#menu .cov {
  background: rgba(0,0,0,.4);
  position: absolute;
  top: 0;
  right: 8px;
  font-size: 9px;
  opacity: .6;
  text-align: left;
  width: 17px;
  -webkit-border-radius: 10px;
  -moz-border-radius: 10px;
  padding: 2px 3px;
  text-align: center;
}

#stats:nth-child(2n) {
  display: inline-block;
  margin-top: 15px;
  border: 1px solid #eee;
  padding: 10px;
  -webkit-box-shadow: inset 0 0 2px #eee;
  -moz-box-shadow: inset 0 0 2px #eee;
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
}

#stats div {
  float: left;
  padding: 0 5px;
}

#stats::after {
  display: block;
  content: '';
  clear: both;
}

#stats .sloc::after {
  content: ' SLOC';
  color: #b6b6b6;
}

#stats .percentage::after {
  content: ' coverage';
  color: #b6b6b6;
}

#stats .misses::after {
  content: ' misses';
  color: #b6b6b6;
}

#stats .hits::after {
  content: ' hits';
  color: #b6b6b6;
}

.high {
  color: #00d4b4;
}
.medium {
  color: #e87d0d;
}
.low {
  color: #d4081a;
}
.terrible {
  color: #d4081a;
  font-weight: bold;
}

table {
  width: 80%;
  margin-top: 10px;
  border-collapse: collapse;
  border: 1px solid #cbcbcb;
  color: #363636;
  -webkit-border-radius: 3px;
  -moz-border-radius: 3px;
}

table thead {
  display: none;
}

table td.line,
table td.hits {
  width: 20px;
  background: #eaeaea;
  text-align: center;
  font-size: 11px;
  padding: 0 10px;
  color: #949494;
}

table td.hits {
  width: 10px;
  padding: 2px 5px;
  color: rgba(0,0,0,.2);
  background: #f0f0f0;
}

tr.miss td.line,
tr.miss td.hits {
  background: #e6c3c7;
}

tr.miss td {
  background: #f8d5d8;
}

td.source {
  padding-left: 15px;
  line-height: 15px;
  white-space: pre;
  font: 12px monaco, monospace;
}

code .comment { color: #ddd }
code .init { color: #2F6FAD }
code .string { color: #5890AD }
code .keyword { color: #8A6343 }
code .number { color: #2F6FAD }
</style>
</head>
HEADER_TEMPLATE
end