require 'v8'
require 'cgi'

ROOT_DIR = File.dirname __FILE__
JS_CONTAINER_FILE = File.join ROOT_DIR, 'all.js'

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
  source.each_with_index.collect { |src, index| "#{calls[index].to_i}: #{CGI.unescapeHTML(src)}" }
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

    coverage_extended[filename] = collect_line_output source, calls
    coverage_resolution[filename] = collect_line_coverage calls
  end

  puts "Javascript coverage with tests. Coverage for executable line (no comments/blank lines/etc.)"
  len = filenames.max_by(&:length)
  coverage_resolution.each do |filename, coverage|
    puts printf "   %s  %3.1f%% (%i of %i)", filename, coverage[:percent], coverage[:covered], coverage[:total]
  end
  puts
  puts

  coverage_extended.each do |filename, coverage|
    puts "Detalized report for \"#{filename}"
    puts coverage.join "\n"
    puts
  end 

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
  #cxt.eval('createDefinitions(null)')

  output cxt
  # puts convert_v8(cxt.eval("_$jscoverage['createDefinitions.js'].source")).join("\n")
  # puts CGI.unescapeHTML(convert_v8(cxt.eval("_$jscoverage['createDefinitions.js']")).join("\n")) #['_$jscoverage'].source).inspect
end
