ROOT_DIR = File.dirname __FILE__
JS_CONTAINER_FILE = File.join ROOT_DIR, 'all.js'

$:.unshift ROOT_DIR

require 'v8'
require 'cgi'
require 'js_coverage'

desc "Intruments javascript"
task :instrument_js do

  ENV["JSCOV"] = "YES"

  ver = `jscoverage -V 2>&1`
  params = '--no-highlight --encoding=UTF8'
  extra_code = ''

  if ver =~ /0\.5/
    params += ' --no-browser'
  elsif ver =~ /0\.4/
    extra_code += 'top = {}'
  else
    puts "Can't detect JSCoverage version, may be it's not installed. Please install it with:"
    puts "  'brew install jscoverage' with Homebrew or"
    puts "  'sudo port install jscoverage' with Macports on Mac"
    puts "  'sudo apt-get install jscoverage' on Ubuntu"
    puts "or any other way and ensure thar 'jscoverage -V' includes 0.4 or 0.5 version"
    puts
    puts "Aborting"
    break
  end

  source_dir = File.join ROOT_DIR, "js"
  instructed_source_dir = File.join ROOT_DIR, "js-instrumented"


  puts "jscoverage #{source_dir} #{instructed_source_dir} #{params}"
  system "jscoverage #{source_dir} #{instructed_source_dir} #{params}"

  dest_file = File.join ROOT_DIR, 'all.js'
  file_list = FileList[File.join instructed_source_dir, '/**/*.js'].exclude('**/jscoverage.js')

  File.open(dest_file, "w+") do |dest|
    dest.puts extra_code
    file_list.each do |js|
      dest.puts File.open(js).read
    end
  end

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
