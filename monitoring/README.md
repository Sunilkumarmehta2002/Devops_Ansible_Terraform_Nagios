# Nagios monitoring config

This folder contains example Nagios configuration snippets to add to your Nagios server.

Steps (demo):

1. On the Nagios server, place `nagios_local_cfg.cfg` into `/usr/local/nagios/etc/servers/` or include it from `nagios.cfg`.
2. Replace the placeholders `__EC2_WEB_IP__` and `__EC2_API_IP__` with actual public IPs (or create this file via a templating step in Ansible).
3. Ensure NRPE/checks are available on the monitored hosts and firewall allows port 5666.
4. Restart Nagios: `sudo systemctl restart nagios` (path may vary).

Provided checks:
- HTTP check for web server
- TCP check for API on port 3001
- NRPE CPU/load check
