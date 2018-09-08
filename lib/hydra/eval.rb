module Hydra::Eval
  def self.get(id)
    #
    # Conditionally downloads, then parses the file.
    #

    # FIXME : proper cache, with cache eviction
    filename = id + ".html"

    unless File.exists?(filename)
      `curl -o "#{filename}" "https://hydra.nixos.org/eval/#{id}?full=1"`
    end

    File.read(filename)
      .split(/<\/?tbody>/)
      .select { |txt| txt.split("\n").first.match(/^\s*<tr>\s+<td>/) }
      .join("\n")
      .split("<tr>")[2..-1]
      .map do |row|
        row.split("</tr>").first
      end
        .map do |raw|
        status = raw.split('title="', 2).last.split('"', 2).first
        job_parts = raw.split('<a href="', 2).last.split('</a>', 2).first
        job = job_parts.split('"', 2).first
        name = job_parts.split('">', 2).last.split("</td>", 2).first
        platform = raw.split('td class="nowrap"><tt>', 2).last.split('</tt>', 2).first

        {
          platform: platform,
          job: job,
          name: name,
          status: status,
          raw: raw,
        }
      end
  end
end
