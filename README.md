# Rundock [![Gem Version](https://badge.fury.io/rb/rundock.svg)](http://badge.fury.io/rb/rundock) [![Circle CI](https://circleci.com/gh/hiracy/rundock.png?style=shield&circle-token=0d8a3836c5e285b7ecb6d076f2d51c5deca52d8b)](https://circleci.com/gh/hiracy/rundock)

Simple and extensible server orchestration framework based on [specinfra](https://github.com/serverspec/specinfra).

- [CHANGELOG](https://github.com/hiracy/rundock/blob/master/CHANGELOG.md)

## Concept

- Simple interface and configurations for orchestration various systems 
- Push type task pipeline
- Extensible and pluggable design

## Installation

```
$ gem install rundock
```

## Usage

Edit your targetgroup to "targetgroup.yml" like this sample.

```
# target section
- target: 192.168.1.11
- target: host-alias-01
---
# target information section
host-alias-01:
  host: 192.168.1.12
  ssh_opts:
    port: 2222
    user: anyuser
    keys: ["~/.ssh/id_rsa_anyuser"]
```

and execute rundock.

    $ rundock ssh -g /path/to/your-dir/targetgroup.yml -c 'your-gread-command'

or

Edit your operation scenario to "[scenario.yml](https://github.com/hiracy/rundock/blob/master/scenario_sample.yml)" like this sample.

```
# scenario section
- target: 192.168.1.11
  command:
    - "sudo hostname new-host-01"
    - "sudo sed -i -e 's/HOSTNAME=old-host-01/HOSTNAME=new-host-01/g' /etc/sysconfig/network"
- target: host-alias-01
  command:
    - "sudo yum -y install ruby"
  task:
    - update_gem
    - install_bundler
---
# target information section
host-alias-01:
  host: 192.168.1.12
  ssh_opts:
    port: 2222
    user: anyuser
    keys: ["~/.ssh/id_rsa_anyuser"]
---
# task information section
update_gem:
  command:
    - "sudo gem update --system"
    - "sudo gem update"
install_bundler:
  command:
    - "sudo gem install bundler --no-ri --no-rdoc"
```

and execute rundock.

    $ rundock do /path/to/your-dir/scenario.yml

You can also specify [default_ssh_options.yml](https://github.com/hiracy/rundock/blob/master/default_ssh.yml) [(Net::SSH options)](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html) file contents that you specified "-d" option to the default ssh options.

- use adhoc ssh

```
$ rundock ssh -g /path/to/your-dir/targetgroup.yml -c 'your-gread-command' -d /path/to/your-dir/default_ssh_options.yml
```

- use scenario file

```
$ rundock do /path/to/your-dir/scenario.yml -d /path/to/your-dir/default_ssh_options.yml
```

You can see from `rundock -h` command.

```
Commands:
  rundock do [SCENARIO] [options]  # Run rundock from scenario file
  rundock help [COMMAND]           # Describe available commands or one specific command
  rundock ssh [options]            # Run rundock ssh with various options
  rundock version                  # Print version

Options:
  -l, [--log-level=LOG_LEVEL]
                                             # Default: info
      [--color], [--no-color]
                                             # Default: true
      [--header], [--no-header]
                                             # Default: true
      [--short-header], [--no-short-header]
      [--date-header], [--no-date-header]
                                             # Default: true
```

## Documentations

- [Rundock Wiki](https://github.com/hiracy/rundock/wiki)

## Run tests

Requirements: Docker environments

```
$ bundle exec rake spec
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rundock/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
