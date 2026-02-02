# K3s + Rancher Automated Deployment on Harvester HCI

[![Built with Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-6366f1)](https://claude.ai/code)
[![Harvester HCI](https://img.shields.io/badge/Platform-Harvester%20v1.6.1-green)](https://harvesterhci.io/)
[![K3s](https://img.shields.io/badge/K3s-v1.34.3-blue)](https://k3s.io/)
[![Rancher](https://img.shields.io/badge/Rancher-v2.13.2-orange)](https://rancher.com/)

Fully automated, production-ready Rancher management server deployment on Harvester HCI using K3s, MetalLB, and cloud-init.

## 🎯 Overview

This repository provides a complete Infrastructure-as-Code solution for deploying a Rancher management server on Harvester HCI v1.6.1. The deployment is fully automated via cloud-init and includes:

- **K3s Kubernetes** cluster (single-node, with servicelb disabled)
- **MetalLB** load balancer providing a dedicated VIP
- **Traefik** ingress controller (K3s default)
- **cert-manager** for automated TLS certificate management
- **Rancher v2.13.2** management server
- **Live migration support** (ReadWriteMany PVCs)
- **Proper firewall configuration** for pod networking

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  DNS: rancher-mgmt.aegisgroup.ch                            │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│  MetalLB VIP: 172.16.3.100                                  │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│  Traefik Ingress Controller                                 │
│  (LoadBalancer Service)                                     │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│  Rancher Service (ClusterIP)                                │
│  - API: Port 444                                            │
│  - HTTP: Port 80 (redirects to HTTPS)                      │
└─────────────────────────────────────────────────────────────┘
```

## ✨ Features

- **Fully Automated**: Complete deployment via cloud-init (~10-15 minutes)
- **Production Ready**: Proper firewall rules, security hardening, live migration support
- **MetalLB Integration**: Dedicated VIP for stable external access
- **No Manual Configuration**: All components configured automatically
- **Repeatable**: Destroy and recreate anytime with consistent results
- **Live Migratable**: VM can migrate between Harvester nodes without downtime

## 📋 Prerequisites

- Harvester HCI v1.6.1 cluster
- Rocky Linux 9 GenericCloud image in `harvester-public` namespace
- VM network configured (VLAN with DHCP)
- Available IP for MetalLB VIP
- DNS record for Rancher hostname (or use IP directly)
- **SSH public key** for VM access
- **Strong password** for Rancher bootstrap

⚠️ **Security Warning**: See [SECURITY.md](SECURITY.md) for credential management and security best practices before deploying!

## 🚀 Quick Start

### 1. Prepare Image and Network

```bash
# Create Rocky Linux 9 image
kubectl apply -f rocky9-image.yaml

# Wait for image to download
kubectl wait --for=condition=Ready vmimage rocky9-genericcloud -n harvester-public --timeout=600s

# Create VM network (adjust VLAN as needed)
kubectl apply -f vm-network.yaml
```

### 2. Customize Configuration

**⚠️ Important**: The repository contains `rancher-single-node.yaml.example` with placeholders.

```bash
# Copy example file
cp rancher-single-node.yaml.example rancher-single-node.yaml

# Edit and replace all YOUR_*_HERE placeholders
vim rancher-single-node.yaml
```

**Required changes** in `rancher-single-node.yaml`:

- **SSH Key**: Line ~19 - Replace `YOUR_SSH_PUBLIC_KEY_HERE` with your public key
- **MetalLB VIP**: Lines ~37, ~60 - Replace `YOUR_METALLB_VIP_HERE` with your IP (e.g., 192.168.1.100)
- **Hostname**: Lines ~36, ~119 - Replace `YOUR_RANCHER_HOSTNAME_HERE` with your domain
- **Bootstrap Password**: Line ~121 - Replace `YOUR_SECURE_PASSWORD_HERE` with a strong password
- **Resources**: Lines 184-196 - Adjust CPU/RAM as needed (optional)
- **Storage**: Line 164 - Adjust disk size (default: 80Gi, optional)

**Verify all placeholders are replaced:**
```bash
grep "YOUR_.*_HERE" rancher-single-node.yaml
# Should return nothing
```

See [SECURITY.md](SECURITY.md) for detailed security guidelines.

### 3. Deploy Rancher

```bash
# Create namespace
kubectl create namespace rancher-mgmt

# Deploy
kubectl apply -f rancher-single-node.yaml

# Monitor deployment
kubectl get vm,vmi -n rancher-mgmt -w
```

### 4. Monitor Progress

```bash
# Get VM IP
VM_IP=$(kubectl get vmi rancher-mgmt -n rancher-mgmt -o jsonpath='{.status.interfaces[0].ipAddress}')

# Check cloud-init status
ssh rocky@$VM_IP 'sudo cloud-init status'

# Watch cloud-init logs
ssh rocky@$VM_IP 'sudo tail -f /var/log/cloud-init-output.log'
```

### 5. Access Rancher

After 10-15 minutes, Rancher will be accessible:

```bash
# Get MetalLB VIP
kubectl get svc traefik -n kube-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Access Rancher
# URL: https://rancher-mgmt.aegisgroup.ch (or your configured hostname)
# Bootstrap Password: RancherAdmin2026! (or your configured password)
```

## 📝 What Gets Deployed

The cloud-init script automatically installs and configures:

1. **System Packages**: curl, wget, qemu-guest-agent, firewalld
2. **Firewall Rules**:
   - Ports 80, 443, 6443 (external access)
   - Pod network 10.42.0.0/16 (pod-to-pod communication)
   - Masquerade enabled
3. **K3s** v1.34.3 with servicelb disabled
4. **Helm** v3 (latest)
5. **MetalLB** v0.14.3 with IP pool and L2 advertisement
6. **cert-manager** (latest) with CRDs
7. **Rancher** v2.13.2 with Traefik ingress
8. **Traefik annotation** for MetalLB VIP assignment

## 🔧 Configuration Details

### Network Configuration

- **DHCP**: VM uses DHCP for simplicity (no static IP conflicts)
- **MetalLB VIP**: Provides stable external access point
- **VLAN**: Default VLAN 12 (172.16.3.0/24) - customize in `vm-network.yaml`

### Firewall Configuration

Critical for pod networking:
```bash
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-masquerade
firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16
```

### Storage Configuration

- **Boot Disk**: 80Gi (customizable)
- **Access Mode**: ReadWriteMany (enables live migration)
- **Storage Class**: longhorn-rocky9-genericcloud
- **VM State**: 10Mi persistence volume for migration

## 🐛 Troubleshooting

### VM Not Getting IP
```bash
kubectl describe vmi rancher-mgmt -n rancher-mgmt
# Check network attachment and DHCP configuration
```

### Cloud-init Failed
```bash
ssh rocky@<VM_IP> 'sudo cloud-init status --long'
ssh rocky@<VM_IP> 'sudo cat /var/log/cloud-init-output.log'
```

### Pod Networking Issues
```bash
# Verify firewall rules on VM
ssh rocky@<VM_IP> 'sudo firewall-cmd --list-all'
ssh rocky@<VM_IP> 'sudo firewall-cmd --list-all --zone=trusted'
```

### MetalLB VIP Not Assigned
```bash
# Check MetalLB status
kubectl get pods -n metallb-system
kubectl logs -n metallb-system -l component=controller

# Check IPAddressPool
kubectl get ipaddresspool -n metallb-system
```

### Rancher Not Accessible
```bash
# Check all components
kubectl get pods -A
kubectl get svc traefik -n kube-system
kubectl get ingress -n cattle-system

# Test connectivity
curl -k https://<MetalLB-VIP> -H "Host: <your-hostname>"
```

## 🔄 Redeployment

To redeploy (useful for testing or recovery):

```bash
# Delete everything
kubectl delete namespace rancher-mgmt

# Wait for cleanup
kubectl wait --for=delete namespace/rancher-mgmt --timeout=120s

# Redeploy
kubectl create namespace rancher-mgmt
kubectl apply -f rancher-single-node.yaml
```

## 📊 Deployment Time

Expected deployment time: **10-15 minutes**

- VM boot: ~1 minute
- K3s installation: ~2 minutes
- MetalLB deployment: ~1 minute
- cert-manager deployment: ~2 minutes
- Rancher deployment: ~5-8 minutes

## 🎯 Use Cases

- **Rancher Management Server**: Central management for multiple Kubernetes clusters
- **Development Environment**: Quick Rancher setup for testing
- **Edge Deployments**: Lightweight, automated Rancher deployment
- **Training/Demos**: Repeatable, consistent environment

## 📚 Additional Resources

- [Harvester Documentation](https://docs.harvesterhci.io/)
- [K3s Documentation](https://docs.k3s.io/)
- [Rancher Documentation](https://ranchermanager.docs.rancher.com/)
- [MetalLB Documentation](https://metallb.universe.tf/)

## 🤝 Credits

This deployment was developed collaboratively with **Claude Code** (Anthropic's AI coding assistant) using iterative prompt engineering and systematic troubleshooting.

### Acknowledgments

- **Platform**: Harvester HCI by SUSE
- **Kubernetes**: K3s by Rancher Labs (now SUSE)
- **Management**: Rancher by SUSE
- **Load Balancer**: MetalLB project
- **AI Assistance**: Built with [Claude Code](https://claude.ai/code) by [Anthropic](https://www.anthropic.com)

## 📄 License

This is configuration code - use freely. Individual components retain their respective licenses:
- Harvester: Apache License 2.0
- K3s: Apache License 2.0
- Rancher: Apache License 2.0
- MetalLB: Apache License 2.0

## 🏷️ Tags

`#harvester` `#k3s` `#rancher` `#metallb` `#kubernetes` `#infrastructure-as-code` `#cloud-init` `#automation` `#claude-code` `#anthropic`

---

**Note**: This configuration is provided as-is. Always test in a non-production environment first and adjust security settings (passwords, SSH keys, etc.) for your specific requirements.

**Built with ❤️ and Claude Code**
