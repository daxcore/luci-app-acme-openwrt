# luci-app-acme-openwrt

Fork von `luci-app-acme` mit Unterstützung für den persistenten
DNS-Validierungsmodus von acme.sh
([draft-ietf-acme-dns-persist-01](https://github.com/acmesh-official/acme.sh/wiki/DNS-persist-mode)).

Das Repository baut ein eigenes apk-Paket und stellt es über GitHub Pages als
OpenWrt-Feed bereit.

## Repository-Aufbau

```text
applications/luci-app-acme/          LuCI-App (Quellcode aus dem LuCI-Feed)
applications/luci-app-acme/root/      Hilfsskript und ACL für DNS-persist
.github/workflows/build.yml          Build- und Feed-Workflow
```

## Versionierung

LuCI-Pakete definieren in der Regel **kein** `PKG_VERSION` in ihrer Makefile.
Stattdessen berechnet `luci.mk` die Version über `findrev` aus der Git-Historie
des Paketverzeichnisses. Das Format ist ungefähr:

```text
JJ.TTT.SSSSS~commit
```

Beispiel: `26.311.28144~20e8277`

Der Workflow liest die tatsächlich gebaute Version aus dem Dateinamen des
apk-Pakets. Dadurch passen Artefaktname, Feed-Index und installierte Version
immer zusammen. Wichtig:

- Der Checkout erfolgt mit `fetch-depth: 0`, damit `findrev` die komplette
  Git-Historie sieht und nicht auf `0` zurückfällt.
- Eine neue Paketversion entsteht durch einen Commit, der das Verzeichnis
  `applications/luci-app-acme/` ändert. Reine Workflow-Änderungen erzeugen
  keine neue Paketversion.

## Feed installieren

Voraussetzungen im GitHub-Repository:

- Das Secret **`SIGNKEY`** mit dem privaten Feed-Signaturschlüssel anlegen.
  Ohne dieses Secret wird der Feed nicht signiert und OpenWrt akzeptiert ihn
  nicht.
- Den Workflow einmal ausführen (Push auf `main` oder manuell über
  **Actions → build → Run workflow**). Dabei wird der Branch `gh-pages`
  erzeugt.
- Danach unter **Settings → Pages** als Quelle **Deploy from a branch** und den
  Branch **`gh-pages`** (Ordner `/`) auswählen.

Der Workflow veröffentlicht nach jedem Build auf dem Branch `gh-pages`:

```text
https://<user>.github.io/luci-app-acme-openwrt/releases/<release>/<arch>/
```

Beispiel für OpenWrt 25.12.6 auf `mediatek-filogic`:

```sh
uclient-fetch -O /etc/apk/keys/openwrt-daxcore.pem \
  https://<user>.github.io/luci-app-acme-openwrt/openwrt-daxcore.pem

echo 'https://<user>.github.io/luci-app-acme-openwrt/releases/25.12.6/mediatek-filogic' \
  >> /etc/apk/repositories

apk update
apk add luci-app-acme
```

Die genaue Feed-URL steht zusätzlich auf der generierten
`index.html`-Seite des Feeds.

`apk` wählt bei mehreren Feeds die höchste Paketversion. Die LuCI-Version des
Forks muss deshalb höher sein als die Version im offiziellen Feed (bei OpenWrt
25.12.6 ist das `26.304.26398~e969939`). Das ist bei einem Commit nach dem
Release normalerweise der Fall.

## Persistent DNS in LuCI

Im Zertifikatsdialog gibt es die neue Validierungsmethode
**„DNS-01 Persistent DNS Challenge Validation“** und den Tab
**„Persistent DNS Challenge Validation“**.

Dort können eingestellt werden:

- **Wildcard and subdomain policy** – erzeugt `policy=wildcard` im TXT-Record.
  Bei Wildcard-Domains wird dies automatisch aktiviert.
- **CA identity domain** – optionaler Issuer-Name, z. B. `letsencrypt.org`.
- **TXT record validity** – optional `persistUntil` in Tagen.
- **Generate TXT record** – ruft acme.sh mit
  `--make-dns-persist-value` auf und zeigt Name und Wert des TXT-Records an.

Den angezeigten TXT-Record beim DNS-Anbieter anlegen und erst danach das
Zertifikat ausstellen. Für jede Basisdomain wird ein eigener Record benötigt.
Mit `policy=wildcard` deckt ein Record auch alle Subdomains ab; ein
Wildcard-Eintrag `*.example.com` verwendet daher den Record der Basisdomain
`example.com`.

Beispielhafte UCI-Konfiguration:

```text
config cert 'example'
	option enabled '1'
	list domains 'example.com'
	list domains '*.example.com'
	option validation_method 'dns-persist'
	option dns_persist_wildcard '1'
	option dns_persist_days '365'
```
