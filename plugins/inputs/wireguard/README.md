# Wireguard Input Plugin

This plugin collects statistics on a local [Wireguard][wireguard] server
using the [`wgctrl` library][wgctrl]. The plugin reports gauge metrics for
Wireguard interface device(s) and its peers.

⭐ Telegraf v1.14.0
🏷️ network
💻 all

[wireguard]: https://www.wireguard.com/
[wgctrl]: https://github.com/WireGuard/wgctrl-go

## Global configuration options <!-- @/docs/includes/plugin_config.md -->

In addition to the plugin-specific configuration settings, plugins support
additional global and plugin configuration settings. These settings are used to
modify metrics, tags, and field or create aliases and configure ordering, etc.
See the [CONFIGURATION.md][CONFIGURATION.md] for more details.

[CONFIGURATION.md]: ../../../docs/CONFIGURATION.md#plugins

## Configuration

```toml @sample.conf
# Collect Wireguard server interface and peer statistics
[[inputs.wireguard]]
  ## Optional list of Wireguard device/interface names to query.
  ## If omitted, all Wireguard interfaces are queried.
  # devices = ["wg0"]
```

## Troubleshooting

### Error: `operation not permitted`

When the kernelspace implementation of Wireguard is in use (as opposed to its
userspace implementations), Telegraf communicates with the module over netlink.
This requires Telegraf to either run as root, or for the Telegraf binary to
have the `CAP_NET_ADMIN` capability.

To add this capability to the Telegraf binary (to allow this communication under
the default user `telegraf`):

```bash
sudo setcap CAP_NET_ADMIN+epi $(which telegraf)
```

N.B.: This capability is a filesystem attribute on the binary itself. The
attribute needs to be re-applied if the Telegraf binary is rotated (e.g.
on installation of new a Telegraf version from the system package manager).

### Error: `error enumerating Wireguard devices`

This usually happens when the device names specified in config are invalid.
Ensure that `sudo wg show` succeeds, and that the device names in config match
those printed by this command.

## Metrics

- `wireguard_device`
  - tags:
    - `name` (interface device name, e.g. `wg0`)
    - `type` (Wireguard tunnel type, e.g. `linux_kernel` or `userspace`)
  - fields:
    - `listen_port` (int, UDP port on which the interface is listening)
    - `firewall_mark` (int, device's current firewall mark)
    - `peers` (int, number of peers associated with the device)

- `wireguard_peer`
  - tags:
    - `device` (associated interface device name, e.g. `wg0`)
    - `public_key` (peer public key, e.g. `NZTRIrv/ClTcQoNAnChEot+WL7OH7uEGQmx8oAN9rWE=`)
  - fields:
    - `persistent_keepalive_interval_ns` (int, keepalive interval in
    nanoseconds; 0 if unset)
    - `protocol_version` (int, Wireguard protocol version number)
    - `allowed_ips` (int, number of allowed IPs for this peer)
    - `last_handshake_time_ns` (int, Unix timestamp of the last handshake for
       this peer in nanoseconds)
    - `rx_bytes` (int, number of bytes received from this peer)
    - `tx_bytes` (int, number of bytes transmitted to this peer)
    - `allowed_peer_cidr` (string, comma separated list of allowed peer CIDRs)

## Example Output

```text
wireguard_device,host=WGVPN,name=wg0,type=linux_kernel firewall_mark=51820i,listen_port=58216i 1582513589000000000
wireguard_device,host=WGVPN,name=wg0,type=linux_kernel peers=1i 1582513589000000000
wireguard_peer,device=wg0,host=WGVPN,public_key=NZTRIrv/ClTcQoNAnChEot+WL7OH7uEGQmx8oAN9rWE= allowed_ips=2i,persistent_keepalive_interval_ns=60000000000i,protocol_version=1i,allowed_peer_cidr=192.168.1.0/24,10.0.0.0/8 1582513589000000000
wireguard_peer,device=wg0,host=WGVPN,public_key=NZTRIrv/ClTcQoNAnChEot+WL7OH7uEGQmx8oAN9rWE= last_handshake_time_ns=1582513584530013376i,rx_bytes=6484i,tx_bytes=13540i 1582513589000000000
```
