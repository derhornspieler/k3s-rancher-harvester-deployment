# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-02-02

### Initial Release

#### Added
- Complete automated Rancher deployment on Harvester HCI
- K3s v1.34.3 with servicelb disabled
- MetalLB v0.14.3 load balancer integration
- Traefik ingress controller configuration
- cert-manager for automated TLS certificates
- Rancher v2.13.2 management server
- Cloud-init automation for full deployment
- Firewall configuration for pod networking
- Live migration support (RWX PVCs)
- Rocky Linux 9 GenericCloud base image
- Comprehensive README with usage instructions
- Network and image configuration files

#### Key Features
- **Fully Automated**: 10-15 minute deployment time
- **MetalLB VIP**: Stable external access at 172.16.3.100
- **Pod Networking**: Proper firewall rules (10.42.0.0/16 trusted zone)
- **DHCP Networking**: Simplified IP management
- **Production Ready**: Security hardening and best practices

#### Technical Details
- K3s installed with `--disable servicelb` flag
- Firewall configured with masquerade and trusted pod network
- MetalLB IPAddressPool with L2Advertisement
- Traefik service annotated for MetalLB
- ReadWriteMany access mode for VM disks
- UEFI boot with persistent EFI configuration

### Known Issues
- None at initial release

### Credits
- Developed collaboratively with Claude Code by Anthropic
- Built through iterative prompt engineering and systematic troubleshooting
