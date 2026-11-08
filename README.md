# keepup

```yaml
# obtain valid api-key and choose team-datacenter slug
keepup::key: 'secret'
keepup::server: 'keepup.example.com'
keepup::systemd_timer: false
keepup::info:
  data_center: 'dc-01'
  team: 'platform'
  # 'prod' (default) or 'non-prod'
  environment: 'non-prod'
  # be sure of uniqueness of data_center+host_ip combination
  # host_ip: "%{facts.networking.fqdn}"
  # host_ip: "%{hiera('my_loc_ip')}"
  # default is
  # host_ip: => $facts['networking']['hostname']
```

## Testing

Unit tests (rspec-puppet) run in the [VoxBox](https://github.com/voxpupuli/container-voxbox) container, so no Ruby, Puppet or gems are needed on the host. Run from the module root:

```bash
podman run --rm -v "$PWD":/repo:Z ghcr.io/voxpupuli/voxbox:latest spec      # unit tests
podman run --rm -v "$PWD":/repo:Z ghcr.io/voxpupuli/voxbox:latest validate  # syntax + lint + metadata
```

`docker` works the same way. Fixtures from `.fixtures.yml` are downloaded into `spec/fixtures/modules/` on the first run.
