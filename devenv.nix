{
  lib,
  pkgs,
  ...
}: let
  rustToolchain = lib.fromTOML (lib.readFile ./rust-toolchain.toml);
  toolchain = rustToolchain.toolchain or {};

  getOrWarn = name: default:
    if toolchain.${name} or null == null
    then
      lib.warn "rust toolchain ${name} is not specified, using ${default}"
      default
    else toolchain.${name};
in {
  languages.rust = {
    enable = true;

    channel = getOrWarn "channel" "nixpkgs";
    version = getOrWarn "version" "latest";

    clangLinker.enable = false;
    mold.enable = true;
  };

  packages = with pkgs; [
    slint-lsp
    libxkbcommon
    wayland
    libGL
    fontconfig
    freetype
  ];

  env = {
    PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" [
      pkgs.fontconfig.dev
      pkgs.wayland.dev
      pkgs.libxkbcommon.dev
    ];

    LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.wayland
      pkgs.libxkbcommon
      pkgs.libGL
    ];
  };
}
