ROOT_DIR = File.dirname __FILE__
JS_CONTAINER_FILE = File.join ROOT_DIR, 'all.js'

$:.unshift ROOT_DIR

require 'v8'
require 'cgi'
require 'js_coverage'

desc "Intruments javascript"
task :instrument_js do

  ENV["JSCOV"] ||= "YES"

  source_dir = File.join ROOT_DIR, "js"

  jscoverage = "jscoverage"
  ver = `#{jscoverage} -V 2>&1`
  params = '--no-highlight'
  extra_code = "var _$source_path = \"#{source_dir}\";\n"

  if ver =~ /0\.5/
    params += ' --no-browser'
  elsif ver =~ /0\.4/
    extra_code += "top = {};\n"
  else
    puts "Can't detect JSCoverage version, may be it's not installed. Please install it with:"
    puts "  'brew install jscoverage' with Homebrew or"
    puts "  'sudo port install jscoverage' with Macports on Mac"
    puts "  'sudo apt-get install jscoverage' on Ubuntu"
    puts "or any other way and ensure that 'jscoverage -V' includes 0.4 or 0.5 version"
    puts "I would recomend using 0.5, cause 0.4 cause therubyracer segmentation fault sometimes"
    puts
    puts "Aborting"
    break
  end

  if `iconv -l | grep UTF` =~ /(\s|^)(UTF-?8)(\s|$)/
    params += " --encoding=#{$2}"
  else
    puts "For some reason iconv does not support UFT8 encoding"
    puts "Please update it. List of available encodings you can see using 'iconv -l'"
    puts "Until this moment you may have problems with non-english chars"
  end

  instructed_source_dir = File.join ROOT_DIR, "js-instructed"
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

  cxt.load(JS_CONTAINER_FILE) # Load instrumented code

  cxt.eval('createDefinitions(2)')
  cxt.eval('createDefinitions(2)')
  cxt.eval('createDefinitions(null)')

  JSCoverage.extract cxt # Extract coverage data from current context
  JSCoverage.report_and_clear
end
