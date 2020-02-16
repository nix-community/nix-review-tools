with (import <nixpkgs> {});
let
  gems = bundlerEnv {
    name = "review-tools-dependencies";
    inherit ruby;
    gemdir = ./.;
  };
in mkShell {
  buildInputs = [
    gems
    ruby
    curl
  ];
}
