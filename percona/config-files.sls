{% from "percona/map.jinja" import percona_settings with context %}

include:
  - .install

{{ percona_settings.config_directory }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root

{% if 'config' in percona_settings and percona_settings.config is mapping %}
{%   for file, content in percona_settings.config|dictsort %}
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
    - require_in:
      - pkg: percona_client
      - pkg: percona_server
    - require:
      - file: {{ percona_settings.config_directory }}
{%   endfor %}
{% endif %}
