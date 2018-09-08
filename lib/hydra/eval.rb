# TODO : Return class instances with lazy loadable attributes for data.
# e.g. accessing SomeEval#build_details should lazyly load the data.
module Hydra::Eval
  # Given an eval, returns a structured array of hashes.
  # [ { :platform, :job, :name, :status, :raw } ]
  # Where the keys are self-explanatory, except raw, which is the raw data (HTML)
  # creating the row, and is an internal debug detail.
  def self.get(id, with_build_details: false)
    # FIXME!! use something like nokogiri instead!
    Hydra::Fetch::eval(id)                                # From the eval data
      .split(/<\/?tbody>/)                                # Gets all tbody...
      .select do |txt|                                    # ...by keeping...
          txt.split("\n").first.match(/^\s*<tr>\s+<td>/)  # ...those with tr+td
        end                                               #
      .join("\n")                                         # Gives a single string holding all table rows
      .split("<tr>")[2..-1]                               # Drops the first <tr> (FIXME: why?)
      .map do |row|                                       #
        row.split("</tr>").first                          #
      end                                                 #
        .map do |raw|
          # For this <tr>, split on known HTML bits.
          # (spooky!)
          status = raw.split('title="', 2).last.split('"', 2).first
          job_parts = raw.split('<a href="', 2).last.split('</a>', 2).first
          build_url = job_parts.split('"', 2).first
          name = job_parts.split('">', 2).last.split("</td>", 2).first
          platform = raw.split('td class="nowrap"><tt>', 2).last.split('</tt>', 2).first
          build_id = build_url.split("/").last

          {
            platform: platform,
            build_url: build_url,
            build_id: build_id,
            name: name,
            status: status,
            raw: raw,
          }.tap do |return_value|
            if with_build_details and status == "Dependency failed" then
              return_value[:build_details] = Hydra::Build.get(build_id)
            end
          end
        end
  end
end
