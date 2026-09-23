{
  stdenvNoCC,
  dpkg,
  lib,
}:

stdenvNoCC.mkDerivation {
  pname = "vpx";
  version = "26.9.31";

  # Prebuilt, statically linked x86_64-linux binaries; no shared-library deps.
  src = ./vpx-26.9.31-x86_64.deb;

  nativeBuildInputs = [ dpkg ];

  installPhase = ''
    runHook preInstall

    dpkg-deb -x "$src" "$out"

    mkdir -p "$out/bin" "$out/lib/vpx" "$out/libexec/vpx" "$out/share/systemd"
    mv "$out/usr/bin/vpx"   "$out/bin/vpx"
    mv "$out/usr/bin/vpxd"  "$out/bin/vpxd"
    mv "$out/usr/lib/vpx/vpx-recovery-gate" "$out/lib/vpx/vpx-recovery-gate"
    mv "$out/usr/lib/systemd/system/vpxd.service" "$out/share/systemd/vpxd.service"

    mv "$out/var/lib/vpx/bin/zray-core"   "$out/libexec/vpx/zray-core"
    mv "$out/var/lib/vpx/bin/zray-server" "$out/libexec/vpx/zray-server"
    mv "$out/var/lib/vpx/bin/geoip.dat"   "$out/libexec/vpx/geoip.dat"
    mv "$out/var/lib/vpx/bin/geosite.dat" "$out/libexec/vpx/geosite.dat"

    rm -rf "$out/etc" "$out/usr" "$out/var"

    runHook postInstall
  '';

  meta = {
    description = "A VPN client for Linux powered by the zray-core engine";
    homepage = "https://github.com/user/vpx";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sources.binaryNativeCode ];
    mainProgram = "vpx";
  };
}
