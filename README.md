nix-review-tools
================

<sup>Definitely the most original name I could conceive of</sup>

> This is a WIP repo of tools I use to review stuff for nixos.
> 
> This is NOT a definitive project, and parts may split off in
> other projects, or this project could evolve and be renamed.

* * *

# `eval-report`

Given a list of eval IDs, it will spit out github-flavoured markdown in stdout,
ready to be passed to `gist` or `xclip`.

This parses the output of the pages of hydra, as they contain more data than
the API does.

> The parsing is sub-optimal in some places, as it initially was a total hack. It
> will eventually all make use of nokogiri. Not much better, but at least it has
> some understanding of the DOM.
