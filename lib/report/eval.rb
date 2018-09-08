# Gives a report for a set of evals.
module Report::Eval
  # Ignored for the main report.
  IGNORED = ["Succeeded", "Queued"]

  #
  # Given data, make a section
  #
  def self.table(data, name:, additional_columns: [])
    acc = []
    acc << "### #{name}\n"
    acc << ""
    acc << " * #{data.count} issues"
    acc << "<details><summary>Failure table</summary>"
    acc << "<table>"
    acc << "<thead><tr>"
    acc << "<th>job</th>"
    acc << "<th>status</th>"
    additional_columns.each do |col|
      acc << "<th>#{col}</th>"
    end
    acc << "</tr></thead>"
    data
      .sort do |a,b|
      unless a[:status] == b[:status]
        a[:status] <=> b[:status]
      else
        a[:name] <=> b[:name]
      end
    end
      .each do |job|
        acc << "<tr>"
        acc << "<td><tt><a href='#{job[:job]}'>#{job[:name]}</a></tt></td>"
        acc << "<td>#{job[:status]}</td>"
        additional_columns.each do |col|
          acc << "<th>#{job[col]}</th>"
        end
        acc << "</tr>"
      end
    acc << "</table>"
    acc << "</details>"
    acc << "\n"

    return acc
  end

  def self.report(in_evals)
    acc = []
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

    acc << "# Evals report"
    acc << ""
    acc << "*Report built at #{Time.now.utc}*"
    acc << ""
    acc << "Built for evals:"
    acc << ""
    ids.each { |id| acc << "  * [#{id}](https://hydra.nixos.org/eval/#{id})" }
    acc << ""
    acc << " * * * "
    acc << ""

    Hydra::KNOWN_PLATFORMS.each do |platform|
      jobs = indexed[platform]
      acc.concat table(jobs, name: platform) if jobs
    end

    acc.concat table(queued, name: "Still queued", additional_columns: [:platform]) if queued.length > 0

    acc.join("\n")
  end
end
