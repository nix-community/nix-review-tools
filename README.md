nix-review-tools
================

<sup>Definitely the most original name I could conceive of</sup>

> This is a WIP repo of tools I use to review stuff for nixos.
>
> This is NOT a definitive project, and parts may split off in
> other projects, or this project could evolve and be renamed.

* * *

# General usage notes

All commands should already self-handle their deps by relying on a nix-shell shebang.

The dependencies will be installed, and the scripts should start at that point.

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


# `jobset-eval-failure`

Can be run on a timer, it will automatically use `gist` to send a report with
information about the currently failing jobset eval.

That is, if the jobset eval is failing.

This script is of limited use at large.
