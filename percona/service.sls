{% from "percona/map.jinja" import percona_settings with context %}

include:
  - .server

percona_svc:
  service.running:
    - name: {{ percona_settings.server_svc }}
    - enable: True
    - require:
      - pkg: percona_server
