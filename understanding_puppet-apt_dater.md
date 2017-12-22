# my apt-dater understanding

```
.
├── files
│   ├── apt-dater-host-yum
│   └── empty
├── Gemfile
├── manifests
│   ├── host_fragment.pp
│   ├── host.pp
│   ├── init.pp
│   ├── manager.pp
│   └── params.pp
├── metadata.json
├── README.md
├── templates
│   ├── apt-dater.conf.erb
│   ├── apt-dater-screenrc.erb
│   └── update-apt-dater-hosts.erb
└── understanding_puppet-apt_dater.md
```
* files : static across all nodes
* templates : ruby templates here, scripts wich are modified
