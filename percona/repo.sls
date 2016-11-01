{% from "percona/map.jinja" import percona_settings with context %}

{% if 'repos' in percona_settings and percona_settings.repos is list %}
{%   for repo in percona_settings.repos if repo is mapping and 'name' in repo %}

{%     if 'gpgkey' in repo and repo.gpgkey.startswith('file') %}
gpgkey{{ loop.index }}:
  file.managed:
    - name: {{ repo.gpgkey | replace('file://','') }}
    - user: root
    - group: root
    - source: salt://percona/files/{{ repo.gpgkey.split('/')|last }}
    - makedirs: True
    - require_in:
      - pkgrepo: perconarepo_{{ loop.index }}
{%     endif %}

"perconarepo_{{ loop.index }}":
  pkgrepo.managed:
{%     for k, v in repo.iteritems() %}
    - {{k}}: {{v}}
{%     endfor %}
{%   endfor %}
{% endif %}
