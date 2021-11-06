# Gives a report for a set of evals.
module Report::Eval
  # Ignored for the main report.
  IGNORED = ["Succeeded", "Queued"]

  # Given a list of paths, reduces to one "thing".
  # This is dirty and should probably sanitize more.
  # This assumes all paths are related (multiple outputs)
  def self.reduce_paths(paths)
    paths = paths
      .map { |p| p.split("-", 2).last }
      .sort
      .first
    [
      "<tt>",
      paths,
      "</tt>",
    ].join("")
  end

  def self.failure_propagation(evals)
    acc = []
    acc << "## Problematic dependencies"
    acc << ""
    acc << "<table>"
    acc << "<tr>"
    acc << "<th>name</th><th>count</th>"
    acc << "</tr>"

    all_builds = evals.values.flatten
    dependency_failures = all_builds.select { |b| b[:status] == "Dependency failed" }
    failed_steps = dependency_failures.map do |b|
      platform = b[:platform]

      b[:build_details][:failed_steps]
        .map do |step|
          build_id = 
            if step[:status][:type] == "Aborted" then
              "Aborted"
            else
              links = step[:status][:links]
              if links and links.length > 0 then
                links
                  .first[:url]
                  .split("/build/", 2).last
                  .split("/", 2).first
              else
              end
            end

          {
            build_id: build_id,
            platform: platform,
            step: step,
            propagates_to: b
          }
        end
    end
      .flatten

    acc.concat(
      failed_steps.group_by do |step|
        self.reduce_paths(step[:step][:what])
      end.map do |id, failures|
        md = []
        step = failures.first[:step]
        platform = failures.first[:platform]
        propagates_to = failures.first[:propagates_to]
        path = reduce_paths(step[:what])
        md << "<tr>"
        md << "<td>"
        md << if failures.first[:build_id] != "Aborted" then
          "<details><summary>#{platform} [#{path}](https://hydra.nixos.org/build/#{failures.first[:build_id]})</summary>"
        else
          "<details><summary>#{platform} #{path}</summary>"
        end
        md << "<ul>"
        md.concat (failures.map do |failure|
          propagates_to = failure[:propagates_to]
            "<li>[#{propagates_to[:name]}](#{propagates_to[:build_url]})</li>"
          end
          .uniq)
        md << "</ul>"
        md << "</details>"
        md << "</td>"
        md << "<td>#{failures.count}</td>"
        md << "</tr>"

        [failures.count, md]
      end
      .sort do |a, b|
        b.first <=> a.first
      end
      .map { |item| item.last }
      .flatten
    )

    acc << "</table>"

    return acc.join("\n")
  end

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
        # job
        acc << "<td>"
        if job[:status] == "Dependency failed" and job[:build_details] then
          acc << "<details><summary>"
        end
        acc << "<tt><a href='#{job[:build_url]}'>#{job[:name]}</a></tt>"
        if job[:status] == "Dependency failed" and job[:build_details] then
          acc << "</summary>"
        end
        if job[:status] == "Dependency failed" and job[:build_details] then
          acc << "<ul>"
          job[:build_details][:failed_steps].each do |details|
            acc << "<li>"
            acc << [
              "<b>=> #{details[:status][:type]}</b>",
              reduce_paths(details[:what]),
              "<br />",
              details[:status][:links].map do |link|
                "<a href='#{link[:url]}'>#{link[:text]}</a>"
              end.join(", "),
            ].join(" ")
            acc << "</li>"
          end
          acc << "<ul>"
          acc << "</details>"
        end
        acc << "</td>"

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

  # Returns a formatted markdown report for the given eval.
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
