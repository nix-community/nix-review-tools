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

It **will cache HTML files to `$PWD`**. This means:

 * Fills your $PWD with stuff.
 * Does not hit hydra in development.
 * Be mindful of stale data.
