{ pkgs ? import ./pkgs.nix
}:

pkgs.callPackage (

{ stdenv, bundlerEnv, ruby, runtimeShell }:
let
  gems = bundlerEnv {
    name = "nix-review-tools";
    inherit ruby;
    gemdir  = ./.;
  };
in stdenv.mkDerivation {
  name = "nix-review-tools";
  src = ./.;
  buildInputs = [ gems ruby ];
  installPhase = ''
    mkdir -p $out/{bin,libexec}
    mv -t $out/libexec/ lib eval-report
    cat <<EOF > $out/bin/eval-report
    #!${runtimeShell}
    exec ${ruby}/bin/bundle exec "$out/libexec/eval-report" "\$@"
    EOF
    chmod +x $out/bin/eval-report
  '';
}

) { }
