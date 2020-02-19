# Fetches raw resources data.
# This **does not** parse the data.
# This means you get HTML for the data.

require "shellwords"

module Hydra::Fetch
  # Gets a resource, given a cache_key it will fetch from cache.
  def self._get(url, cache_key = nil)

    cmd = [
      "curl",
      "--silent",
      "--show-error",
      "--fail",
      url
    ]

    # No cache? no frills.
    return `#{cmd.shelljoin}` if !cache_key

    # FIXME : cache eviction
    # FIXME : better cache location (XDG cache folder)
    filename = cache_key

    unless File.exists?(filename)
      STDERR.puts "Downloading #{url}..."
      cmd << "-o"
      cmd << filename
      `#{cmd.shelljoin}`
      raise "Error downloading #{url} (#{$?.exitstatus})" unless $?.success?
    end

    File.read(filename)
  end

  # Gets the full eval data from hydra.
  def self.eval(id)
    _get(
      "https://hydra.nixos.org/eval/#{id}?full=1",
      "eval_#{id}"
    )
  end

  # Gets the full build data from hydra.
  def self.build(id)
    _get(
      "https://hydra.nixos.org/build/#{id}",
      "build_#{id}"
    )
  end

  # Gets the jobset summary from hydra.
  def self.jobset_summary(project, name)
    # This is never cached.
    _get(
      "https://hydra.nixos.org/jobset/#{project}/#{name}"
    )
  end
end
