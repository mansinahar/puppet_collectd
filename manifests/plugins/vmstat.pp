class collectd::plugins::vmstat (
  $modules,
  $filter_metrics = false,
  $filter_metric_rules = {} ) {
  validate_hash($modules)
  Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
  include collectd

  if $::osfamily == 'RedHat' {
    exec { 'install epel-release':
      command => 'yum install -y epel-release',
      before  => Package['sysstat']
    }
  }

  package { 'sysstat':
    ensure => present,
  }

  file { ['/usr/share/collectd/vmstat-collectd-plugin/']:
    ensure => directory,
    owner  => root,
    group  => 'root',
    mode   => '0755',
    before => File['get vmstat_collectd.py']
  }

  file { 'get vmstat_collectd.py':
    ensure  => present,
    replace => 'yes',
    path    => '/usr/share/collectd/vmstat-collectd-plugin/vmstat_collectd.py',
    owner   => root,
    group   => 'root',
    mode    => '0755',
    content => template('collectd/plugins/vmstat/vmstat_collectd.py.erb'),
    require => Package['sysstat']
  }

  collectd::plugins::plugin_common { 'vmstat':
    package_name         => 'collectd-python',
    plugin_file_name     => '10-vmstat.conf',
    plugin_template_name => 'vmstat/10-vmstat.conf.erb',
  }
}
