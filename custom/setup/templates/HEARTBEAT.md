# HEARTBEAT.md — {PROJECT_NAME}

Florence læser denne fil ved hver runde. Hun følger checklistet præcist
og flagger hvis det er forældet.

Sidst opdateret: {SETUP_DATE}

---

## Checklistet

### 1. BCQuality PRs
Tjek åbne PRs på `Curabis/BCQuality`:
`https://api.github.com/repos/Curabis/BCQuality/pulls?state=open`

| Klassifikation | Kriterium |
|---|---|
| Routine | Ingen åbne PRs |
| Notable | 1 åben PR, oprettet inden for 24 timer |
| Concerning | 1+ åben PR, ældre end 3 dage uden aktivitet |
| Urgent | PR afventer merge og blokerer andet arbejde |

---

### 2. CI/CD — AL-Go builds
Tjek seneste build-status på `main` og åbne branches.

| Klassifikation | Kriterium |
|---|---|
| Routine | Alle builds grønne |
| Notable | Et enkelt build fejlede men er siden rettet |
| Concerning | Seneste build på main fejler |
| Urgent | Main fejler og der er en igangværende release |

---

### 3. BC-opgaver — klar til start
Tjek opgaver med status `Accepted` i projektet.

| Klassifikation | Kriterium |
|---|---|
| Routine | Ingen nye Accepted-opgaver siden sidste runde |
| Notable | 1-2 opgaver er blevet Accepted |
| Concerning | 3+ opgaver er Accepted og ingen er taget op |

---

### 4. Forsinkede opgaver
Tjek opgaver hvor `expectedDelivery` er passeret og BC-status ikke er afsluttet.

| Klassifikation | Kriterium |
|---|---|
| Routine | Ingen forsinkede opgaver |
| Notable | 1 opgave forsinket med under 3 dage |
| Concerning | 1+ opgave forsinket med mere end 3 dage |
| Urgent | Forsinkelse påvirker kundeleverance |

---

### 5. Gamle branches
Tjek branches ældre end 14 dage uden åben PR.

| Klassifikation | Kriterium |
|---|---|
| Routine | Ingen branches ældre end 14 dage |
| Notable | 1-2 gamle branches uden PR |
| Concerning | 3+ gamle branches, eller en branch ældre end 30 dage |

---

### 6. Agent-synlighed i CLAUDE.md
Sammenlign filer i `.github/.agents/` med referencer i `CLAUDE.md`.

| Klassifikation | Kriterium |
|---|---|
| Routine | Alle agenter er nævnt i CLAUDE.md |
| Concerning | 1+ agent i mappen er ikke nævnt i CLAUDE.md |

---

### 7. Workspace & multi-app konfiguration
Se `florence.agent.md` for den fulde checkprotokol.

| Klassifikation | Kriterium |
|---|---|
| Routine | Workspace eksisterer, alle apps er med, alle har test-app |
| Notable | En eller flere main-apps mangler test-app |
| Concerning | Ingen workspace-fil, app-mappe mangler i workspace, eller CLAUDE.md dækker ikke alle apps |

---

## Hvad Florence aldrig gør

- Vækker Michael for et Notable
- Springer en runde over fordi "der sikkert ikke er sket noget"
- Redigerer dette dokument uden at blive bedt om det
- Lukker BC-opgaver — det kan kun en BC-bruger
