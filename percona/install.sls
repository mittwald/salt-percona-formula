{% from "percona/map.jinja" import percona_settings with context %}
{% set os_family = salt['grains.get']('os_family') %}
{% set initsystem = salt['grains.get']('init') %}
{% set repolist = [] %}
{% if 'repos' in percona_settings and percona_settings.repos is list %}
{%   for repo in percona_settings.repos if repo is mapping and 'name' in repo %}
{% do repolist.append("perconarepo_" + loop.index|string) %}
{%   endfor %}
{% endif %}

include:
  - .repo
  - .client
  - .config-files
  - .motd

{% if percona_settings.get('root_password', False) %}
{% if os_family == 'Debian' %}
percona_debconf_utils:
  pkg.installed:
    - name: {{ percona_settings.debconf_utils }}

mysql_debconf:
  debconf.set:
    - name: {{ percona_settings.server_pkg }}-{{ percona_settings.versionstring }}
    - data:
        '{{ percona_settings.server_pkg }}-{{ percona_settings.versionstring }}/root-pass': {'type': 'password', 'value': '{{ percona_settings.debconf_password_entry }}'}
        '{{ percona_settings.server_pkg }}-{{ percona_settings.versionstring }}/re-root-pass': {'type': 'password', 'value': '{{ percona_settings.debconf_password_entry }}'}
        '{{ percona_settings.server_pkg }}-{{ percona_settings.versionstring }}/start_on_boot': {'type': 'boolean', 'value': 'true'}
        '{{ percona_settings.server_pkg }}/root_password': {'type': 'password', 'value': '{{ percona_settings.debconf_password_entry }}'}
        '{{ percona_settings.server_pkg }}/root_password_again': {'type': 'password', 'value': '{{ percona_settings.debconf_password_entry }}'}
    - require_in:
      - pkg: percona_server
    - require:
      - pkg: percona_debconf_utils
{% endif %}
{% endif %}

percona_server:
  pkg.installed:
    - name: {{ percona_settings.server_pkg }}-{{ percona_settings.versionstring }}
    - require:
{% for r in repolist %}
      - pkgrepo: {{ r }}
{% endfor %}

percona_server_enabled:
  service.enabled:
    - name: {{ percona_settings.server_svc }}
    - require:
      - pkg: percona_server

{% if initsystem == 'systemd' %}
percona_remove_limits:
  file.managed:
    - name: /etc/systemd/system/mysql.service.d/override.conf
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - contents: |
        [Service]
        LimitNOFILE=infinity
        LimitMEMLOCK=infinity
    - require_in:
      - pkg: percona_server
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/mysql.service.d/override.conf
{% endif %}
