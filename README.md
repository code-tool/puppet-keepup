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

### Hiera merge of `keepup::info`

The module sets `lookup_options` for `keepup::info` with the `deep` merge strategy,
so the hash is merged across all levels of your Hiera hierarchy instead of
the first match winning. Common values can live at a lower level, and nodes override
only what differs:

```yaml
# common.yaml
keepup::info:
  data_center: 'dc-01'
  team: 'platform'

# nodes/db-01.example.com.yaml
keepup::info:
  environment: 'non-prod'
  host_ip: '10.0.0.15'

# resulting keepup::info for db-01:
#   data_center: 'dc-01'
#   team: 'platform'
#   environment: 'non-prod'
#   host_ip: '10.0.0.15'
```

Keys from lower levels can no longer be dropped just by omitting them at a higher level.
To remove one, override its value, or override the merge behavior in your
environment's Hiera data:

```yaml
lookup_options:
  keepup::info:
    merge: first
```

## Testing

Unit tests (rspec-puppet) run in the [VoxBox](https://github.com/voxpupuli/container-voxbox) container, so no Ruby, Puppet or gems are needed on the host. Run from the module root:

```bash
podman run --rm -v "$PWD":/repo:Z ghcr.io/voxpupuli/voxbox:latest spec      # unit tests
podman run --rm -v "$PWD":/repo:Z ghcr.io/voxpupuli/voxbox:latest validate  # syntax + lint + metadata
```

`docker` works the same way. Fixtures from `.fixtures.yml` are downloaded into `spec/fixtures/modules/` on the first run.
