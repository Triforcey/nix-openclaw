{
  openclawToolPkgs ? { },
  qmdPkgs ? { },
}:
final: prev:
let
  qmdPackage =
    if prev.stdenv.hostPlatform.isDarwin then
      openclawToolPkgs.qmd or null
    else
      qmdPkgs.qmd or qmdPkgs.default or null;
  packages = import ./packages {
    pkgs = prev;
    openclawToolPkgs = openclawToolPkgs;
    inherit qmdPackage;
  };
  toolNames =
    (import ./tools/extended.nix {
      pkgs = prev;
      openclawToolPkgs = openclawToolPkgs;
    }).toolNames;
  withTools =
    {
      toolNamesOverride ? null,
      excludeToolNames ? [ ],
    }:
    import ./packages {
      pkgs = prev;
      openclawToolPkgs = openclawToolPkgs;
      inherit qmdPackage;
      inherit toolNamesOverride excludeToolNames;
    };
in
{
  inherit (packages) openclaw openclaw-gateway openclawRuntimePlugins;
}
// (if packages ? openclaw-app then { inherit (packages) openclaw-app; } else { })
// {
  openclawPackages = packages // {
    inherit toolNames withTools;
  };
}
