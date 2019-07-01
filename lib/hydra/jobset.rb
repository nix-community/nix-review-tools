module Hydra

  # A Jobset has a `#status` representing the status of the *last completed* eval.
  # An eval can be pending 
  class Jobset
    attr_reader :props
    attr_reader :errors_log
    attr_reader :raw_log
    attr_reader :return_value
    attr_reader :status

    def last_evaluation()
      props[:last_evaluation]
    end

    def evaluation_running()
      props[:evaluation_running]
    end

    def evaluation_pending()
      props[:evaluation_pending]
    end

    def evaluation_running_since()
      props[:evaluation_running_since]
    end

    def evaluation_pending_since()
      props[:evaluation_pending_since]
    end

    def evaluation_status()
      return :pending if props[:evaluation_pending]
      return :running if props[:evaluation_running]
      return :done
    end

    # Given a jobset name (project:jobset), returns an instance of Jobset.
    def self.get(id)
      parts = id.split(":")
      unless parts.length == 2 then
        abort "Expected project:name form for jobset ID."
      end
      project, name = parts

      contents = Nokogiri::HTML(Hydra::Fetch::jobset_summary(project, name))
        .css("#generic-tabs")

      jobset = Jobset.new(project, name)

      parse_summary_evals(jobset, contents)
      parse_last_evaluation_stderr(jobset, contents)

      jobset.instance_eval do
        @status = :success
        @status = :warning if props[:status] == :with_errors
        @status = :error   unless @return_value == 0
      end

      jobset
    end

    def id()
      [@project, @name].join(":")
    end

    private

    def initialize(project, name)
      @project = project
      @name = name
    end

    def self.parse_summary_evals(jobset, contents)
      evals = contents.css("#tabs-evaluations")

      jobset.instance_eval do
        props = evals.css(".info-table tr")
          .map do |row|
          value = row.css("td")

          value.css("time").each do |node|
            if node["datetime"] then
              node.replace(node["datetime"])
            end
          end

          [
            row.css("th").text.parameterize.underscore.to_sym,
            value.text.strip,
          ]
        end.to_h
        props[:evaluation_running] = !!props[:evaluation_running_since]
        props[:evaluation_pending] = !!props[:evaluation_pending_since]

        last_checked, status = props[:last_checked].split(",")
        props[:last_checked] = last_checked
        if status then
          props[:status] = status.parameterize.underscore.to_sym
        end

        @props = props
      end
    end

    def self.parse_last_evaluation_stderr(jobset, contents)
      stderr = contents.css("#tabs-errors")

      log = stderr.css("pre").text
      jobset.instance_eval do
        @raw_log = log
      end

      log.sub!(/\Ahydra-eval-jobs returned signal (\d+):\n/, "")
      log = nil if log.blank?
      jobset.instance_eval do
        @return_value = ($1 ? $1 : 0).to_i
        @errors_log = log
      end
    end
  end
end
