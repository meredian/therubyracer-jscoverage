require 'v8'
require 'js_common_funcs'
require 'js_coverage_html_printer'

module JSCoverage

  @coverage_full = {}

  def self.merge_full coverage_full
    coverage_full.each do |file, coverage|
      if @coverage_full[file]

        @coverage_full[file][:calls] = @coverage_full[file][:calls].each_with_index.collect { |count, index|
          count + coverage[:calls][index] unless count.nil?
        }

      else
        @coverage_full[file] = coverage
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

  def self.clean_lines lines
    lines.collect{ |line| CGI.unescapeHTML(line) }
  end

  def self.collect_line_output source, calls
    source.each_with_index.collect { |line, index| {count: calls[index], source: line} }
  end

  def self.create_resolution
    @coverage_resolution = {}
    @coverage_full.each do |file, coverage|
      @coverage_resolution[file] = collect_line_coverage coverage[:calls]
    end
  end

  def self.create_extended
    @coverage_extended = {}
    @coverage_full.each do |file, coverage|
      @coverage_extended[file] = collect_line_output coverage[:source], coverage[:calls]
    end
  end

  def self.extract context
    coverage = context["_$jscoverage"]
    coverage_full = {}

    coverage.each do |filename, calls|
      source = source_for_file context, filename.to_s
      calls = convert_v8(calls)
      calls.shift

      coverage_full[filename] = { calls: calls, source: clean_lines(source)}
    end

    merge_full coverage_full
  end

  def self.print_console
    filename_len = @coverage_resolution.collect{ |filename, cov| filename }.max_by(&:length).length

    puts "JSCoverage Tool executed..."
    puts "Javascript coverage for executable lines (no comments/blank lines/etc.)"
    @coverage_resolution.each do |filename, coverage|
      puts printf "   %-#{filename_len}s  %3.1f%% (%i of %i)", filename, coverage[:percent], coverage[:covered], coverage[:total]
    end
  end

  def self.html_print
    path = File.join( File.dirname(__FILE__), "coverage.html")
    puts "Detailed reports stored in \"#{path}\" file"
    HTMLPrinter.create_single_file path, @coverage_resolution, @coverage_extended
  end

  def self.report
    if ::ENV["JSCOV"] || true
      create_resolution
      create_extended

      print_console
      html_print
    end
  end
end