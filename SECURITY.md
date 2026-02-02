# Security Guidelines

## ⚠️ Important Security Notes

### Before Deploying

1. **DO NOT use example credentials in production!**
2. **Always customize these values before deployment:**
   - SSH public keys
   - Bootstrap passwords
   - Hostnames
   - IP addresses

### Required Customization

The `rancher-single-node.yaml.example` file contains placeholders that **MUST** be replaced:

#### 1. SSH Public Key (Line ~19)
```yaml
ssh_authorized_keys:
  - YOUR_SSH_PUBLIC_KEY_HERE
```
Replace with your actual SSH public key from `~/.ssh/id_*.pub`

#### 2. Rancher Bootstrap Password (Line ~121)
```yaml
--set bootstrapPassword='YOUR_SECURE_PASSWORD_HERE'
```
Use a strong password (minimum 12 characters, mix of upper/lower/numbers/symbols)

#### 3. Hostname (Multiple locations)
```yaml
--set hostname=YOUR_RANCHER_HOSTNAME_HERE
```
Replace with your actual DNS hostname or use the MetalLB VIP directly

#### 4. MetalLB VIP (Lines ~37, ~60)
```yaml
addresses:
  - YOUR_METALLB_VIP_HERE-YOUR_METALLB_VIP_HERE
```
Replace with an available IP in your network

### Setup Process

1. Copy the example file:
```bash
cp rancher-single-node.yaml.example rancher-single-node.yaml
```

2. Edit the file and replace all placeholders:
```bash
vim rancher-single-node.yaml
```

3. Verify no placeholders remain:
```bash
grep -i "YOUR_.*_HERE" rancher-single-node.yaml
# Should return nothing
```

4. The real configuration file (`rancher-single-node.yaml`) is in `.gitignore` and won't be committed

### Password Security

- **Never commit passwords to Git**
- Use a password manager
- Change the bootstrap password after first login
- Consider secrets management (HashiCorp Vault, etc.)

### SSH Key Security

- Use Ed25519 or RSA 4096-bit keys
- Protect private keys with passphrases
- Never share private keys
- Use different keys for different environments

### Network Security

- MetalLB VIP on secure network segment
- Firewall rules to restrict access
- Consider authentication proxy (OAuth, OIDC)
- Enable TLS/SSL for all external access

### Post-Deployment Security

1. Change the bootstrap password immediately
2. Enable authentication provider (AD, LDAP, OIDC, SAML)
3. Configure RBAC with least-privilege
4. Enable audit logging
5. Regular security updates
6. Backup encryption keys and certificates
7. Monitor access logs

### Production Checklist

- [ ] All placeholders replaced
- [ ] Strong passwords generated
- [ ] SSH keys configured
- [ ] Network security reviewed
- [ ] Firewall rules configured
- [ ] TLS certificates valid
- [ ] Backup strategy implemented
- [ ] Monitoring configured
- [ ] Security policies documented

### Reporting Security Issues

If you discover a security issue:
1. **Do not** create a public GitHub issue
2. Contact maintainers directly
3. Allow time for a fix before disclosure

### Additional Resources

- [Rancher Security Guide](https://ranchermanager.docs.rancher.com/reference-guides/rancher-security)
- [K3s Security Guide](https://docs.k3s.io/security)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)

---

**Remember**: Security is not a one-time setup. Regular reviews, updates, and monitoring are essential.
