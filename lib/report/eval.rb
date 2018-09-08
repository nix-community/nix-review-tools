# Gives a report for a set of evals.
module Report::Eval
  # Ignored for the main report.
  IGNORED = ["Succeeded", "Queued"]

  #
  # Given data, make a section
  #
  def self.table(data, name:, additional_columns: [])
    puts "### #{name}\n"
    puts ""
    puts " * #{data.count} issues"
    puts "<details><summary>Failure table</summary>"
    puts "<table>"
    puts "<thead><tr>"
    puts "<th>job</th>"
    puts "<th>status</th>"
    additional_columns.each do |col|
      puts "<th>#{col}</th>"
    end
    puts "</tr></thead>"
    data
      .sort do |a,b|
      unless a[:status] == b[:status]
        a[:status] <=> b[:status]
      else
        a[:name] <=> b[:name]
      end
    end
      .each do |job|
        puts "<tr>"
        puts "<td><tt><a href='#{job[:job]}'>#{job[:name]}</a></tt></td>"
        puts "<td>#{job[:status]}</td>"
        additional_columns.each do |col|
          puts "<th>#{job[col]}</th>"
        end
        puts "</tr>"
      end
    puts "</table>"
    puts "</details>"
    puts "\n"
  end

  def self.report(in_evals)
    ids = in_evals.keys

    # Combine evals
    evals = in_evals.values.inject(:+)

    not_a_success = evals.reject { |job| IGNORED.include?(job[:status]) }
    queued = evals.select { |job| ["Queued"].include?(job[:status]) }

    indexed = not_a_success.reduce({}) do |hash, j|
      hash[j[:platform]] ||= []
      hash[j[:platform]] << j
      hash
    end

    #
    # Here, we have the actual markdown...
    #

    puts "# Evals report"
    puts ""
    puts "*Report built at #{Time.now.utc}*"
    puts ""
    puts "Built for evals:"
    puts ""
    ids.each { |id| puts "  * [#{id}](https://hydra.nixos.org/eval/#{id})" }
    puts ""
    puts " * * * "
    puts ""

    Hydra::KNOWN_PLATFORMS.each do |platform|
      jobs = indexed[platform]
      table(jobs, name: platform) if jobs
    end

    table(queued, name: "Still queued", additional_columns: [:platform]) if queued.length > 0
  end
end
