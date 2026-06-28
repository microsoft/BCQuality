---
rule: CURABIS-MCP-003
title: MCP bridge JavaScript-filer skal gemmes uden UTF-8 BOM
category: mcp
severity: high
tags: [mcp, encoding, node, bridge, windows]
---

# CURABIS-MCP-003 — MCP bridge JavaScript-filer skal gemmes uden UTF-8 BOM

## Regel

JavaScript-filer der fungerer som MCP bridge-scripts (fx `bc-mcp-bridge.js`) skal gemmes med UTF-8-enkodning **uden** BOM (Byte Order Mark). En UTF-8 BOM (0xEF 0xBB 0xBF) placeret foran shebang-linjen får Node.js til at crashe med `SyntaxError: Invalid or unexpected token`, og MCP-serveren starter aldrig — uden at producere en brugbar fejlbesked til udvikleren.

## Baggrund

Node.js behandler BOM som en ugyldig token i entry-point-filer. Fejlen er ikke åbenlys: `.mcp.json` ser korrekt ud, bridge-processen forsøges startet, men crasher øjeblikkeligt og eksponerer ingen tools. Udvikleren oplever at MCP-serveren er konfigureret, men tools er aldrig tilgængelige — ingen advarsler, ingen logs, ingen indikation af årsagen.

BOM introduceres typisk på Windows via:
- `Out-File` (PowerShell 5.1 default-encoding er UTF-16 LE med BOM)
- Tekstprogrammer der gemmer UTF-8 med BOM
- `Invoke-WebRequest | Out-File`-kombination

## Hvad der SKAL ske

**Download og gem korrekt (uden BOM):**

```powershell
$content = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
[System.IO.File]::WriteAllText($destPath, $content, [System.Text.UTF8Encoding]::new($false))
```

**Verifikation efter gem:**

```powershell
$bytes = [System.IO.File]::ReadAllBytes($filePath)
if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    throw "BOM detected in $filePath — file cannot be used as Node.js entry point"
}
```

**Strip af eksisterende BOM (remediation):**

```powershell
$bytes = [System.IO.File]::ReadAllBytes($path)
if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    [System.IO.File]::WriteAllBytes($path, $bytes[3..($bytes.Length - 1)])
}
```

## Hvad der IKKE må ske

- Brug IKKE `Out-File` eller `Set-Content` (PS 5.1) til at gemme JS bridge-filer
- Distribuer IKKE bridge-scripts via kanaler der ikke verificerer encoding
- Antag IKKE at en konfigureret MCP-server virker uden at verificere at processen starter

## Setup-ansvar

Setup scripts der installerer MCP bridge-filer (fx curabis-standard.agent.md) skal inkludere BOM-verifikation eller -strip som del af installationen — ikke som et valgfrit step.

## Symptom og diagnose

Symptom: MCP-server er konfigureret i `.mcp.json`, men eksponerer ingen tools i sessionen.

Diagnose:
```powershell
# Tjek første bytes
$b = [System.IO.File]::ReadAllBytes("path\to\bridge.js")
"0x{0:X2} 0x{1:X2} 0x{2:X2}" -f $b[0], $b[1], $b[2]
# Hvis output er "0xEF 0xBB 0xBF" er BOM årsagen
```

```bash
# Kør bridge direkte og se om Node.js fejler
node path/to/bridge.js 2>&1 | head -5
```

## Evidens

Observeret i to separate projekter inden for én uge (2026-06-28). I begge tilfælde var BC MCP-tools utilgængelige i alle sessioner. Fejlen kræver manuel byte-inspektion at diagnosticere.