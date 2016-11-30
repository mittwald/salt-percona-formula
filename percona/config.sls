{% from "percona/map.jinja" import percona_settings with context %}

{{ percona_settings.config_directory }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - require_in:
      - pkg: percona_client

include:
  - .service

mysql_python_dep:
  pkg.installed:
    - name: {{ percona_settings.python_mysql }}
    - reload_modules: True


{% if 'config' in percona_settings and percona_settings.config is mapping %}
{% set global_params= {} %}
{%   if 'my.cnf' in percona_settings.config %}
{%     do global_params.update(percona_settings.config['my.cnf'].get('mysqld',{})) %}
{%   endif %}
{%   for file, content in percona_settings.config|dictsort %}
{%     do global_params.update(percona_settings.config[file].get('mysqld',{})) if file != 'my.cnf' %}
{%     if file == 'my.cnf' %}
{%       set filepath = percona_settings.my_cnf_path %}
{%     else %}
{%       set filepath = percona_settings.config_directory + '/' + file %}
{%     endif %}
{{ filepath }}:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - source: salt://percona/files/mysql.cnf.j2
    - template: jinja
    - context:
        config: {{ content |default({}) }}
{%     if percona_settings.reload_on_change %}
    - watch_in:
      - service: percona_svc
{%     endif %}
{%   endfor %}
{% endif %}

{% for global, value in global_params.iteritems() %}
{{ global }}:
  percona.setglobal:
    - value: {{ value }}
    - connection_pass: {{ percona_settings.root_password }}
    - fail_on_missing: False
    - fail_on_readonly: False
    - require:
      - service: percona_svc
      - pkg: mysql_python_dep
{% endfor %}
