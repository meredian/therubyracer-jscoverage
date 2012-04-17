require 'v8'
require 'js_common_funcs'
require 'js_coverage_html_printer'

module JSCoverage

  @coverage_resolution = {}
  @coverage_extended = {}

  def self.merge_resolution coverage_resolution
    coverage_resolution.each do |file, coverage|
      @coverage_resolution[file] ||= {total:0, covered:0, percent:0}
      res = @coverage_resolution[file]
      res[:total] += coverage[:total]
      res[:covered] += coverage[:covered]
      res[:percent] = percent_coverage(res[:total], res[:covered])
    end
  end

  def self.merge_extended coverage_extended
    coverage_extended.each do |file, coverage|
      if @coverage_extended[file]
        ext = @coverage_extended[file]
        ext.each_with_index { |line, index|
          src[:count] += coverage[index][:count]
        }
      else
        @coverage_extended[file] = coverage
      end
    end
  end

  def self.source_for_file context, file
    convert_v8 context.eval("_$jscoverage['#{file}'].source")
  end

  def self.collect_line_coverage calls
    calls = calls.compact
    total_code = calls.size
    covered_code = calls.inject(0){ |sum, c| sum + (c == 0 ? 0 : 1) }
    { total:total_code, covered:covered_code, percent: percent_coverage(total_code, covered_code)}
  end

  def self.percent_coverage total_code, covered_code
    covered_code.to_f / total_code.to_f * 100.0
  end 

  def self.collect_line_output source, calls
    calls.shift
    source.each_with_index.collect { |src, index| {count: calls[index], source: CGI.unescapeHTML(src)} }
  end

  def self.extract context
    coverage = context["_$jscoverage"]

    coverage_resolution = {}
    coverage_extended = {}

    coverage.each do |filename, calls|
      source = source_for_file context, filename.to_s
      calls = convert_v8(calls)

      coverage_resolution[filename] = collect_line_coverage calls
      coverage_extended[filename] = collect_line_output source, calls
    end

    merge_resolution coverage_resolution
    merge_extended coverage_extended
  end

  def self.print_console
    filename_len = @coverage_resolution.collect{ |filename, cov| filename }.max_by(&:length)

    puts "JSCoverage"
    puts "Javascript coverage for executable lines (no comments/blank lines/etc.)"
    @coverage_resolution.each do |filename, coverage|
      puts printf "   %s  %3.1f%% (%i of %i)", filename, coverage[:percent], coverage[:covered], coverage[:total]
    end
  end

  def self.html_print
    path = File.join( File.dirname(__FILE__), "coverage.html")
    puts "Detailed reports stored in \"#{path}\" file"
    HTMLPrinter.create_single_file path, @coverage_resolution, @coverage_extended
  end

  def self.report
    if ::ENV["JSCOV"] || true
      print_console
      html_print
    end
  end
end