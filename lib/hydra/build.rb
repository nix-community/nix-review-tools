module Hydra::Build
  FAILED_BUILD_STEPS_COLUMNS = {
    number:   0,
    what:     1,
    duration: 2,
    machine:  3,
    status:   4,
  }

  # Given a build ID, returns a MVP dataset for failed dependencies.
  # FIXME : a more thorough parse.
  def self.get(id)
    document = Nokogiri::HTML(Hydra::Fetch::build(id))
    failed_steps = document
      .css("#generic-tabs")
      .xpath("//*[contains(text(),'Failed build steps')]").first
      .next_element
      .css("tbody > tr")
      .map do |step|
        columns = step.css("td")
        what = columns[FAILED_BUILD_STEPS_COLUMNS[:what]].css("tt").first.text.split(",")
        status_data = columns[FAILED_BUILD_STEPS_COLUMNS[:status]]
        status = {
          type: status_data.css(".error").text,
          links: status_data.css("a").map do |link|
            {url: link.attr("href"), text: link.text,}
          end
        }

        {
          what: what,
          status: status,
        }
      end

      {
        failed_steps: failed_steps,
      }
  end
end

