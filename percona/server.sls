{% from "percona/map.jinja" import percona_settings with context %}
{% set os_family = salt['grains.get']('os_family') %}
{% set repolist = [] %}
{% if 'repos' in percona_settings and percona_settings.repos is list %}
{%   for repo in percona_settings.repos if repo is mapping and 'name' in repo %}
{% do repolist.append("perconarepo_" + loop.index|string) %}
{%   endfor %}
{% endif %}

include:
  - .repo
  - .client
  - .config
  - .service
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
        '{{ percona_settings.server_pkg }}-{{ percona_settings.versionstring }}/root-pass': {'type': 'password', 'value': '{{ percona_settings.root_password }}'}
        '{{ percona_settings.server_pkg }}-{{ percona_settings.versionstring }}/re-root-pass': {'type': 'password', 'value': '{{ percona_settings.root_password }}'}
        '{{ percona_settings.server_pkg }}-{{ percona_settings.versionstring }}/start_on_boot': {'type': 'boolean', 'value': 'true'}
    - require_in:
      - pkg: percona_server
    - require:
      - pkg: percona_debconf_utils
{% elif os_family in ['RedHat', 'Suse'] %}
mysql_root_password:
  mysql_user.present:
    - name: root
    - host: localhost
    - password: {{ percona_settings.root_password }}
    - connection_pass: {{ percona_settings.get('old_root_password', '') }}
    - require:
      - service: percona_svc
      - pkg: mysql_python_dep
{% endif %}
{% endif %}

percona_server:
  pkg.installed:
    - name: {{ percona_settings.server_pkg }}-{{ percona_settings.versionstring }}
    - require:
{% for r in repolist %}
      - pkgrepo: {{ r }}
{% endfor %}

{% if os_family in ['RedHat', 'Suse'] and percona_settings.version >= 5.7 %}
# Initialize mysql database with --initialize-insecure option before starting service so we don't get locked out.
mysql_initialize:
  cmd.run:
    - name: mysqld --initialize-insecure --user=mysql --basedir=/usr --datadir={{ percona_settings.datadir }}
    - user: root
    - creates: {{ percona_settings.datadir }}/mysql/
    - require:
      - pkg: percona_server
    - require_in:
      - service: percona_svc
{% endif %}

{% for name, user in percona_settings.db_users.items() %}
mysql_user_{{ name }}_{{ user['host'] }}:
  mysql_user.present:
    - name: {{ name }}
    - host: {{ user['host'] }}
    - password: {{ user['password'] }}
    - connection_pass: {{ percona_settings.get('root_password', '') }}
    - require:
      - pkg: mysql_python_dep
      - service: percona_svc
{%   if os_family in ['RedHat', 'Suse'] %}
      - mysql_user: mysql_root_password
{%   endif %}
{%   for db in user['databases'] %}
mysql_grant_{{ name }}_{{ user['host'] }}_{{ loop.index0 }}:
  mysql_grants.present:
    - grant: '{{db['grant']|join(",")}}'
    - database: '{{ db['database'] }}.*'
    - user: {{ name }}
    - host: {{ user['host'] }}
    - connection_pass: {{ percona_settings.get('root_password', '') }}
    - require:
      - mysql_user: mysql_user_{{ name }}_{{ user['host'] }}

{%   endfor %}
{% endfor %}
