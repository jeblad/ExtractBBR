# ExtractBBR

Script to extract info from Danish BBR.

## Usage

Check out the git repo to `/share/extract-bbr`, and do a

```bash
chmod 755 extract-br*
chown root:root extract-br*
```

Make a link to `extract-bbr` from one of `/etc/cron.daily`, `/etc/cron.weekly`, or `/etc/cron.monthly`.

## Development

Create a working directory like `~/spaces/ExtractBBR1` and add a `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
end
```

Go to the instance `vagrant ssh` and check out the git repository.
