# Contributing

Thank you for your interest in contributing to this project!

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists
2. Create a new issue with:
   - Clear description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Environment details (Harvester version, K3s version, etc.)

### Security Issues

**Do not** create public issues for security vulnerabilities. See [SECURITY.md](SECURITY.md) for responsible disclosure.

### Pull Requests

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. **Ensure no credentials are included**
5. Test your changes
6. Submit a pull request with:
   - Clear description of changes
   - Reference to related issues
   - Testing performed

### Code Guidelines

- Use clear, descriptive comments
- Follow existing YAML formatting
- Test on Harvester v1.6.1 when possible
- Update documentation for significant changes

### Documentation

- Keep README.md up to date
- Update CHANGELOG.md for changes
- Document breaking changes clearly

## Development Setup

1. Clone the repository
2. Copy example files and customize
3. Test on a non-production Harvester cluster
4. Verify deployment completes successfully

## Testing Checklist

- [ ] VM deploys successfully
- [ ] Cloud-init completes without errors
- [ ] K3s cluster is healthy
- [ ] MetalLB assigns VIP correctly
- [ ] Traefik ingress works
- [ ] Rancher is accessible
- [ ] All pods are running
- [ ] No credentials in committed files

## Credits

This project was developed collaboratively with Claude Code (Anthropic's AI assistant).

Contributions from the community are welcomed and appreciated!

## License

By contributing, you agree that your contributions will be used under the same terms as the project.
