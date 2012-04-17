ROOT_DIR = File.dirname __FILE__
JS_CONTAINER_FILE = File.join ROOT_DIR, 'all.js'

$:.unshift ROOT_DIR

require 'v8'
require 'cgi'
require 'js_coverage'

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

  JSCoverage.extract cxt
  JSCoverage.report
  # puts convert_v8(cxt.eval("_$jscoverage['createDefinitions.js'].source")).join("\n")
  # puts CGI.unescapeHTML(convert_v8(cxt.eval("_$jscoverage['createDefinitions.js']")).join("\n")) #['_$jscoverage'].source).inspect
end
