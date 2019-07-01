module Hydra
  # List of known platforms, in a specific desired order.
  KNOWN_PLATFORMS = [
    "i686-linux",
    "x86_64-linux",
    "x86_64-darwin",
    "aarch64-linux",
  ]
end

require "nokogiri"
require "active_support"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"
require File.join(__dir__(), "hydra/build")
require File.join(__dir__(), "hydra/eval")
require File.join(__dir__(), "hydra/fetch")
