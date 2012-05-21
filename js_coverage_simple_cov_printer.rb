module JSCoverage
  module SimpleCovPrinter

    def self.toolname
      "JSCov"
    end

    def self.append_to_report coverage_full
      coverage = {}

      coverage_full.each do |filename, coverage_per_file|
        coverage[filename] = coverage_per_file[:calls]
      end

      ::SimpleCov::ResultMerger.resultset.each do |command, data|
        if command == toolname && (Time.now.to_i - data["timestamp"]) < ::SimpleCov.merge_timeout
          coverage = data["coverage"].merge_resultset coverage
        end
      end

      merged_result = ::SimpleCov::Result.from_hash({toolname => { "coverage" => coverage, "timestamp" => Time.now.to_i }})
      ::SimpleCov::ResultMerger.store_result merged_result
    end

  end
end