{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "psscriptanalyzer";
  version = "1.25.0";

  # PSScriptAnalyzer is not in nixpkgs. The PowerShell Gallery serves the
  # module as a NuGet package, which is a plain zip archive.
  src = fetchzip {
    url = "https://www.powershellgallery.com/api/v2/package/PSScriptAnalyzer/${finalAttrs.version}";
    hash = "sha256-OEyOGPyFatNo68Jlx1G8UOKQu83UScZMRQ3TlzKxjl0=";
    extension = "zip";
    stripRoot = false;
  };

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    moduleDir="$out/${finalAttrs.passthru.moduleRoot}/PSScriptAnalyzer"
    mkdir -p "$moduleDir"
    cp -r . "$moduleDir/"

    # NuGet packaging metadata, not part of the module.
    rm -rf "$moduleDir/_rels" "$moduleDir/package" "$moduleDir/[Content_Types].xml"

    runHook postInstall
  '';

  passthru.moduleRoot = "share/powershell/Modules";

  meta = {
    description = "Static code checker and formatter for PowerShell";
    homepage = "https://github.com/PowerShell/PSScriptAnalyzer";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
})
