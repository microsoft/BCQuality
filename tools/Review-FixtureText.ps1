# Model-facing text preparation for review fixtures, shared by
# Test-ReviewFixtures.ps1 and its regression checks.
#requires -Version 7.2
Set-StrictMode -Version Latest

# A retained BDD tag is one of the five exact uppercase bracketed tags, alone at
# the start of a full-line `//` comment, followed by a space, a tab or the end
# of the line. `[Given]`, `[WHENEVER]`, `[WHEN]:`, `/// [WHEN]` and tags after
# code do not qualify. The same expression drives stripping and the label check.
$script:BddTagAfterSlashes = '[ \t]*\[(?:FEATURE|SCENARIO|GIVEN|WHEN|THEN)\](?:[ \t]|\r?$)'
$script:BddTagLinePattern = "^\s*//$script:BddTagAfterSlashes"
$script:StrippedCommentPattern = "(?m)^\s*//(?!$script:BddTagAfterSlashes).*(?:\r?\n|$)"
$script:OutcomeLabelPattern = '(?i)\b(?:good|bad)\b|\banti[- ]?pattern'

function Get-BddTagLine {
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $Text)

    $lines = $Text -split '\r?\n'
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -cmatch $script:BddTagLinePattern) {
            [pscustomobject]@{ Line = $index + 1; Text = $lines[$index].Trim() }
        }
    }
}

function Test-BddTagLineLabel {
    # Run on source text, before Good/Bad neutralization can hide a label.
    param([Parameter(Mandatory)] [string] $TagLineText)

    return $TagLineText -match $script:OutcomeLabelPattern
}

function ConvertTo-ReviewFixtureText {
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $Text,
        [switch] $KeepComments
    )

    # Companion samples are human-facing and often label objects/comments as
    # Good, Bad, or Anti-pattern. Strip full-line comments and neutralize those
    # object-name tokens so model-facing fixtures do not reveal the expected
    # outcome while preserving executable AL structure and references.
    # Standalone BDD tag lines are kept in every sample: they are the evidence
    # the testing articles read, and their text is checked for outcome labels.
    # An article whose rule is about the comments themselves is listed under
    # keepComments in review-fixtures.json and keeps them; its samples carry no
    # answer-revealing labels (Good/Bad is still neutralized below).
    $neutralText = $Text
    if (-not $KeepComments) {
        $neutralText = [regex]::Replace($neutralText, $script:StrippedCommentPattern, '')
    }
    return [regex]::Replace($neutralText, '\b(?:Good|Bad)\b', 'Eval')
}
