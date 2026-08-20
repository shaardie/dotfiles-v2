# Globale Regeln

Diese Regeln gelten in **jedem** Projekt, unabhängig vom Arbeitsverzeichnis.

## Nie in fremde Projekte schauen

Recherche bleibt strikt im aktuellen Projektverzeichnis. Keine `Read`, `Grep`, `Glob` oder
Shell-Kommandos in anderen Repositories — auch nicht zum Vergleich, als Referenz oder um eine
Konvention nachzuschlagen. Wenn Information aus einem anderen Projekt gebraucht wird: danach
fragen, nicht selbst nachsehen.

## Artefakte immer auf Englisch

Alles, was im Projekt landet oder nach außen geht, ist auf Englisch — ohne Nachfrage und
unabhängig davon, in welcher Sprache die Unterhaltung läuft: Code-Kommentare, Doc-Comments,
Dokumentation (README, Design-Docs), Commit-Messages, Issues, Merge-Request-Beschreibungen und
-Kommentare. Die Unterhaltung selbst bleibt auf Deutsch.

## Kein `Co-Authored-By`

Commit-Messages bekommen niemals einen `Co-Authored-By`-Trailer.

## Keine Interaktion mit Clustern

Bestehende Cluster sind absolut tabu. Kein `kubectl`, `istioctl`, `helm`, `cilium`, `argocd`
oder ein anderer Client wird ausgeführt — auch nicht lesend (`get`, `describe`, `logs`,
`proxy-status`, `--dry-run=server`, …) und auch nicht, um eine Änderung zu verifizieren.
Manifeste werden geschrieben und höchstens offline validiert; das Anwenden und Prüfen macht
der Nutzer. Verifikationsschritte werden als Checkliste dokumentiert, nicht ausgeführt.

## Nichts unter meiner Authentifizierung

Kein Zugriff auf ein fremdes System, der meine Anmeldung benutzt — weder schreibend noch lesend.
Kein `glab`, `gh`, kein `curl` mit Token oder Session, keine MCP-Connectors. Das gilt auch dann,
wenn das CLI installiert und angemeldet ist. Wie bei Clustern: Issues, Merge Requests,
Kommentare, Payloads und Requests werden als Text vorbereitet, abgeschickt wird nichts — anlegen
und verschicken mache ich.

Öffentliche Websuche und das Abrufen öffentlicher Seiten sind erlaubt, solange keine
Authentifizierung von mir im Spiel ist.

## wwukube- und cloud-services-Repos

Die meisten (nicht alle) Repos unter `wwuit-sys/wwukube/` und `wwuit-sys/cloud-services/` sind
Helm-Charts, aus denen ein globales `generate.sh` (liegt im PATH, nicht im Repo) pro
Environment-Cluster-Kombination fertige Manifeste rendert. Erkennungsmerkmal: eine
`.generate`-Datei im Repo-Root plus die Verzeichnisse `templates/`, `kustomize/` und `resources/`.
Fehlen die, gelten die folgenden Regeln nicht. Branches sind Environments (`dev`, `staging`,
`prod`).

- **Quellen, hier wird geändert**: `Chart.yaml`, `templates/`, die Values `common.yaml`,
  `<env>.yaml`, `<cluster>.yaml`, `<env>-<cluster>.yaml`, dazu `.generate`, `.kubeconform`.
- **Generiert, nie von Hand editieren**: `kustomize/` und `resources/` (bzw. deren `*.enc.yaml`).
  Das ist Ausgabe, keine Referenz — den Soll-Zustand klären `templates/` und die Values.
- `generate.sh` führt der Nutzer aus, nicht ich. Nach einer Quelländerung darauf hinweisen, dass
  neu generiert werden muss.
- `.Values.globals.*` kommt aus dem wwukube-Config-Repo, nicht aus dem Repo, in dem ich arbeite —
  Werte dort nachfragen, nicht raten.
- sops ist ein Auslaufmodell (Migration zum External Secrets Operator). Verschlüsselte Dateien
  (`*.enc.yaml`, `secrets-*.yaml`) **niemals entschlüsseln**; neue Secrets als `ExternalSecret`.

Details zum Ablauf von `generate.sh`: `~/.claude/wwukube-repos.md` (bei Bedarf lesen).
