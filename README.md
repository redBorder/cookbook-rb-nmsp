# cookbook-rb-nmsp
[![Build Status][build-shield]][build-url]
[![Linters][linters-shield]][linters-url]
[![License][license-shield]][license-url]

<!-- Badges -->
[build-shield]: https://github.com/redBorder/cookbook-rb-nmsp/actions/workflows/rpm.yml/badge.svg?branch=master
[build-url]: https://github.com/redBorder/cookbook-rb-nmsp/actions/workflows/rpm.yml?query=branch%3Amaster
[linters-shield]: https://github.com/redBorder/cookbook-rb-nmsp/actions/workflows/lint.yml/badge.svg?event=push
[linters-url]: https://github.com/redBorder/cookbook-rb-nmsp/actions/workflows/lint.yml
[license-shield]: https://img.shields.io/badge/license-AGPLv3-blue.svg
[license-url]: https://github.com/cookbook-rb-nmsp/blob/HEAD/LICENSE

Chef cookbook to install and configure redborder rb-nmsp (Cisco NMSP/LOCP Telemetry and AP Monitoring Daemon).

### Overview

This cookbook manages the `redborder-nmsp` service:
- Installs or upgrades the `redborder-nmsp` package via DNF.
- Configures `/etc/redborder-nmsp/config.yaml` (with compatibility symlink `/etc/redborder-nmsp/config.yml`) supporting the Go daemon schema (Kafka brokers, PostgreSQL credentials, and sensor lists).
- Configures `/etc/sysconfig/redborder-nmsp` for environment and memory settings.
- Deploys the cluster-wide `/etc/redborder-nmsp/aes.keystore` file from Chef cookbook files when `passwords/nmspd-key-hashes` is present.
- Registers/deregisters the service in Consul (`redborder-nmsp` on port `16113`).
- Enables and starts the `redborder-nmsp` systemd service.

### Platforms

- Rocky Linux 9

### Chef

- Chef 15.7.0 or later

### Usage & Key Generation

Keys and hashes are created on the manager/proxy using:
```bash
/usr/lib/redborder/bin/rb_create_nmsp_keys.sh -fu
```
This invokes `rb-nmsp config-gen`, generating `/var/chef/cookbooks/rb-nmsp/files/default/aes.keystore` and uploading `nmspd-key-hashes.json` to the Chef databag. The same keystore is then deployed by Chef to all nodes running `redborder-nmsp`.

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License

GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007
