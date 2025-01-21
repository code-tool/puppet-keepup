# keepup

```yaml
# obtain valid api-key and choose team-datacenter slug
keepup::key: 'secret'
keepup::server: 'keepup.example.com'
keepup::info:
  data_center: 'dc-01'
  # be sure of uniqueness of data_center+host_ip combination
  # host_ip: "%{facts.networking.fqdn}"
  # host_ip: "%{hiera('my_loc_ip')}"
  # default is
  # host_ip: => $facts['networking']['hostname']
```
