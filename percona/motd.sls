{% from "percona/map.jinja" import percona_settings with context %}
{% set osfullname = salt['grains.get']('osfullname') %}

{% if percona_settings.get('install_motd', False) %}
{%   if osfullname == 'Ubuntu' %}
/etc/update-motd.d/99-mysqlversion:
  file.managed:
    - source: salt://percona/files/motd
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: percona_server
{%   endif %}
{% endif %}
