# luci-app-acme-openwrt

Fork of `luci-app-acme` with support for acme.sh's persistent DNS validation
mode
([draft-ietf-acme-dns-persist-01](https://github.com/acmesh-official/acme.sh/wiki/DNS-persist-mode)).

## Versioning

LuCI packages usually do **not** define `PKG_VERSION` in their Makefile.
Instead, `luci.mk` derives the version from the Git history of the package
directory using `findrev`. The format is roughly:

```text
YY.WWW.NNNNN~commit
```

Example: `26.311.28144~20e8277`

The workflow reads the actual built version from the apk filename, so artifact
names, feed index, and installed version always match. Note:

- The checkout uses `fetch-depth: 0` so `findrev` sees the full Git history and
  does not fall back to `0`.
- A new package version is created by a commit that changes the
  `applications/luci-app-acme/` directory. Workflow-only changes do not produce
  a new package version.
- `apk` selects the highest package version when multiple feeds are configured.
  The fork's LuCI version must therefore be higher than the version in the
  official feed (for OpenWrt 25.12.6 that is `26.304.26398~e969939`). A commit
  after the release normally satisfies this.

## Persistent DNS in LuCI

The certificate dialog provides the new validation method
**"DNS-01 Persistent DNS Challenge Validation"** and the tab
**"Persistent DNS Challenge Validation"**.

The following options are available:

- **Wildcard and subdomain policy** – generates `policy=wildcard` in the TXT
  record. It is enabled automatically for wildcard domains.
- **CA identity domain** – optional issuer name, for example
  `letsencrypt.org`.
- **TXT record validity** – optional `persistUntil` in days.
- **Generate TXT record** – calls acme.sh with `--make-dns-persist-value` and
  displays the name and value of the TXT record.

Create the displayed TXT record with your DNS provider before issuing the
certificate. Each base domain needs its own record. With `policy=wildcard`, one
record also covers all subdomains; a wildcard entry `*.example.com` therefore
uses the record of the base domain `example.com`.

Example UCI configuration:

```text
config cert 'example'
	option enabled '1'
	list domains 'example.com'
	list domains '*.example.com'
	option validation_method 'dns-persist'
	option dns_persist_wildcard '1'
	option dns_persist_days '365'
```
