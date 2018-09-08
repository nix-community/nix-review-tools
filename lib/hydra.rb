module Hydra
  # List of known platforms, in a specific desired order.
  KNOWN_PLATFORMS = [
    "i686-linux",
    "x86_64-linux",
    "x86_64-darwin",
    "aarch64-linux",
  ]
end

require File.join(__dir__(), "hydra/eval")
