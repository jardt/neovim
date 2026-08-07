{
  lib,
  writeText,
  writeShellApplication,
  powershell,
  psscriptanalyzer,
}:
let
  # Reads PowerShell source on stdin and writes the formatted source on stdout,
  # which is the shape conform.nvim expects. The optional argument is the path
  # of the buffer, used only to find a settings file.
  formatScript = writeText "pwsh-format.ps1" ''
    $ErrorActionPreference = 'Stop'

    Import-Module PSScriptAnalyzer

    function Find-AnalyzerSettings {
        param([string] $StartPath)

        if ([string]::IsNullOrWhiteSpace($StartPath)) {
            $dir = (Get-Location).Path
        }
        else {
            $dir = Split-Path -Parent $StartPath
            if ([string]::IsNullOrWhiteSpace($dir)) {
                $dir = (Get-Location).Path
            }
        }

        while (-not [string]::IsNullOrWhiteSpace($dir)) {
            $candidate = Join-Path $dir 'PSScriptAnalyzerSettings.psd1'
            if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                return $candidate
            }

            $parent = Split-Path -Parent $dir
            if ($parent -eq $dir) {
                break
            }
            $dir = $parent
        }

        return $null
    }

    $source = [Console]::In.ReadToEnd()
    $sourceFile = if ($args.Count -ge 1) { $args[0] } else { $null }
    $settings = Find-AnalyzerSettings -StartPath $sourceFile

    if ($null -ne $settings) {
        $formatted = Invoke-Formatter -ScriptDefinition $source -Settings $settings
    }
    else {
        $formatted = Invoke-Formatter -ScriptDefinition $source
    }

    [Console]::Out.Write($formatted)
  '';
in
writeShellApplication {
  name = "pwsh-format";

  runtimeInputs = [ powershell ];

  text = ''
    export PSModulePath="${psscriptanalyzer}/${psscriptanalyzer.moduleRoot}''${PSModulePath:+:$PSModulePath}"
    exec pwsh -NoProfile -NonInteractive -NoLogo -File ${formatScript} "$@"
  '';

  meta = {
    description = "PSScriptAnalyzer formatter with a stdin/stdout interface";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "pwsh-format";
  };
}
