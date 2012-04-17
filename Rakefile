require 'v8'
require 'cgi'

ROOT_DIR = File.dirname __FILE__
JS_CONTAINER_FILE = File.join ROOT_DIR, 'all.js'

class LinePrinter
  def self.format line_coverage
    line_coverage.collect { |cov| "#{cov[0]} : #{cov[1]}"}.join("\n")
  end
end

class HTMLCovPrinter

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
    File.open(File.join(ROOT_DIR, HeaderTemplatePath), "r"){ |f| output += f.read }
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

def convert_v8(value)
  if value.is_a?(V8::Array)
    result = []
    value.each do |val|
      result << convert_v8(val)
    end
  elsif value.is_a?(V8::Object)
    result = {}
    value.each do |key|
      result[key] = convert_v8(value[key])
    end
  else
    result = value
  end
  result
end

def source_for_file context, file
  convert_v8 context.eval("_$jscoverage['#{file}'].source")
end

def collect_line_coverage calls
  calls = calls.compact
  total_code = calls.size
  covered_code = calls.inject(0){ |sum, c| sum + (c == 0 ? 0 : 1) }
  { total:total_code, covered:covered_code, percent:  covered_code.to_f / total_code.to_f * 100.0}
end

def collect_line_output source, calls
  calls.shift
  source.each_with_index.collect { |src, index| {count: calls[index], source: CGI.unescapeHTML(src)} }
end

def output context
  coverage = context["_$jscoverage"]

  coverage_resolution = {}
  coverage_extended = {}
  filenames = []

  coverage.each do |filename, calls|
    source = source_for_file context, filename.to_s
    calls = convert_v8(calls)
    filenames << filename.to_s

    coverage_resolution[filename] = collect_line_coverage calls
    coverage_extended[filename] = collect_line_output source, calls
  end

  puts "Javascript coverage with tests. Coverage for executable lines (no comments/blank lines/etc.)"
  len = filenames.max_by(&:length)
  coverage_resolution.each do |filename, coverage|
    puts printf "   %s  %3.1f%% (%i of %i)", filename, coverage[:percent], coverage[:covered], coverage[:total]
  end
  puts
  puts

  report_dir = File.join ROOT_DIR, "coverage_reports"
  Dir.mkdir report_dir unless Dir.exists? report_dir
  puts "Detailed reports stored in \"#{report_dir}\" directory"

  HTMLCovPrinter.create_single_file File.join(report_dir, "coverage.html"), coverage_resolution, coverage_extended
end

desc "Intruments javascript"
task :instrument_js do
	source_dir = File.join ROOT_DIR, "js"
	instructed_source_dir = File.join ROOT_DIR, "js-instrumented"
    system("jscoverage #{source_dir} #{instructed_source_dir} --no-highlight --no-browser --encoding=UTF8")

    file_list = FileList[File.join instructed_source_dir, '/**/*.js'].exclude('**/jscoverage.js')

    File.open(JS_CONTAINER_FILE, "w+") { |dest|  
    	file_list.each{ |f| dest.puts File.open(f).read }
    }
    
    system("rm -rf #{instructed_source_dir}")
end

desc "Load instrumented JS to context and tries to get statistics"
task :default => [:instrument_js] do
	cxt = V8::Context.new
  cxt.load(JS_CONTAINER_FILE)
  cxt.eval('createDefinitions(2)')
  cxt.eval('createDefinitions(2)')
  cxt.eval('createDefinitions(null)')

  output cxt
  # puts convert_v8(cxt.eval("_$jscoverage['createDefinitions.js'].source")).join("\n")
  # puts CGI.unescapeHTML(convert_v8(cxt.eval("_$jscoverage['createDefinitions.js']")).join("\n")) #['_$jscoverage'].source).inspect
end
