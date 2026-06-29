---
id: CURABIS-MCP-SHEBANG-001
title: Shebang-integritet ved deploy af script-filer
category: mcp
severity: error
applies-to: [claude-code, windows, mcp-setup]
---

# Shebang-integritet ved deploy af script-filer

## Regel

Når en script-fil med shebang-linje (`.js`, `.sh`, `.ps1`) skrives via Claude Codes
`Write`-værktøj på Windows, skal linje 1 i den deployede fil verificeres umiddelbart
efter skrivning.

Den verificerede linje skal matche den forventede shebang præcist, f.eks.:

```
#!/usr/bin/env node
```

## Baggrund

På Windows håndteres strenge internt via PowerShell-laget. PowerShell behandler `#`
som kommentar-tegn. Hvis filindhold sendes gennem en ikke-quoted streng eller heredoc,
kan `#!` i shebangens første linje reduceres til `!/...` — et gyldigt men syntaktisk
ugyldigt JavaScript-udtryk.

Node.js parser da `!/usr/bin/env node` som logisk NOT på et regex-udtryk med ugyldige
flags og kaster en `SyntaxError` ved opstart. Fejlen er stille: broen starter ikke,
MCP-tools afvises uden dialog, og brugeren opdager det typisk kun ved at undres over
manglende godkendelsesdialog.

## Konsekvens af brud

MCP-serveren starter ikke. Alle `mcp__businesscentral__*`-kald afvises automatisk.
Brugeren ser ingen fejlbesked i Claude Code — kaldet afvises blot.

## Verifikation (påkrævet efter enhver write af script-fil)

```python
with open(deployed_path, "r", encoding="utf-8") as f:
    line1 = f.readline().rstrip()
assert line1 == expected_shebang, f"Shebang fejl: forventet {expected_shebang!r}, fik {line1!r}"
```

Alternativt med Read-værktøjet: læs linje 1 og sammenlign med forventet shebang.
Stop setup-processen og genskriv filen hvis de ikke matcher.

## Eksempel (fejlscenarie observeret 2026-06-29)

`bc-mcp-bridge.js` fik `!/usr/bin/env node` (mangler `#`) efter en
CURABIS Standard-opdatering. BC MCP var ude af drift i ukendt periode.
Opdaget ved at brugeren efterspurgte MCP-data og ingen godkendelsesdialog dukkede op.

## Gælder for

- `~/.claude/bc-mcp-bridge.js` (og fremtidige bridge-varianter)
- Enhver `.js`- eller `.sh`-fil med shebang deployeret via CURABIS Standard-setup
