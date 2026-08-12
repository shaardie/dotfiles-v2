# wwukube-/cloud-services-Repos: Aufbau und generate.sh

## Repo-Layout

| Pfad | Rolle |
| --- | --- |
| `Chart.yaml` | Helm-Chart-Metadaten des Repos |
| `templates/<component>/*.yaml` | Helm-Templates; jede Komponente hat eine ebenfalls getemplatete `kustomization.yaml`, die Upstream-Charts über `helmCharts:` einbindet |
| `common.yaml`, `<env>.yaml`, `<cluster>.yaml`, `<env>-<cluster>.yaml` | Values, in dieser Reihenfolge zunehmend spezifisch |
| `.generate` | Konfiguration für `generate.sh` (`GENERATE_*`-Variablen) |
| `.sops.yaml`, `.kubeconform`, Assets wie `error-page.html` | Hilfsdateien; Assets werden per `.Files.Get` + `tpl` eingebunden |
| `kustomize/<env>-<cluster>/<chart>/templates/…` | **generiert**: Ergebnis von `helm template --output-dir` |
| `resources/<env>-<cluster>/<component>/resources.yaml` | **generiert**: Ergebnis von `kustomize build`; das ist, was ArgoCD vom Branch `<env>` zieht |

Bei `GENERATE_ENCRYPTION="true"` liegen statt der generierten Klartextdateien `*.enc.yaml` plus
`*.sha256sum` im Repo. Diese niemals entschlüsseln.

## Ablauf von generate.sh

1. **Matrix**: ohne Argumente wird für jedes Verzeichnis in `resources/` generiert; mit Argumenten
   (`generate.sh dev-ms1 prod-ms2`) nur für diese. Zerlegung über den Bindestrich:
   `environment=${arg%-*}`, `cluster=${arg#*-}`.
2. **Setup**: liest `.generate` (Defaults: `GENERATE_ENCRYPTION=true`, Extra-Vars-Revision
   `origin/main`) und aktualisiert die Cache-Repos unter `~/.cache/wwuit-generate` — Extra-Values
   aus `GENERATE_HELM_EXTRA_VARS_REPOSITORY`, CRD-Schemas aus
   `GENERATE_KUBECONFORM_SCHEMA_REPOSITORY`.
3. **Render**: `helm template . --output-dir kustomize/<env>-<cluster>` mit Values in dieser
   Reihenfolge (später gewinnt): aus dem Config-Repo `common`, `<env>`, `<cluster>`,
   `<env>-<cluster>` — je zusätzlich mit `globals.clusters.<cluster>` nach `.Values.globals`
   hochgezogen; danach dieselben vier Dateien aus dem Repo selbst. Lokale Werte überschreiben also
   die globalen. Fehlende Dateien werden still übersprungen.
4. **Build**: pro `kustomization.yaml` (ohne `charts/`) `kustomize build --enable-helm` nach
   `resources/<env>-<cluster>/<component>/resources.yaml`.
5. **Validierung** je Komponente: `kubeconform` (Schemas aus dem CRD-Repo, Branch `origin/<env>`,
   `-skip` aus `GENERATE_KUBECONFORM_SKIP`) bricht bei Fehlern ab; `kubent` und `gator test`
   (gegen `expansion.yaml`, falls vorhanden) erzeugen nur Warnungen.
6. **Verschlüsselung** (falls aktiv): sops-Encrypt der Ergebnisse, Klartext wird zum Schluss
   gelöscht.

Am Ende steht eine Summary je Environment-Cluster; bei Fehlern `Generation FAILED - do NOT commit!`.

## Konsequenzen für meine Arbeit

- Änderungen gehen ausschließlich in `templates/` und die Values-Dateien.
- Eine Änderung an einem Template schlägt auf **alle** Environment-Cluster-Kombinationen durch;
  Environment-Spezifisches gehört in `<env>.yaml` / `<env>-<cluster>.yaml`.
- Ein neues Environment-Cluster-Paar braucht ein Verzeichnis in `resources/`, sonst taucht es in
  der Matrix nicht auf.
- Ich führe `generate.sh` nicht aus und editiere `kustomize/` und `resources/` nicht.
