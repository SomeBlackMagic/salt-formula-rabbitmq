{%- from "rabbitmq/map.jinja" import server with context %}

rabbitmq_server:
  pkg.installed:
  - name: {{ server.pkg }}
  {%- if server.version is defined %}
  - version: {{ server.version }}
  {%- endif %}

rabbitmq_config:
  file.managed:
  - name: {{ server.config_file }}
#  - source: salt://rabbitmq/files/rabbitmq.config
  - template: jinja
  - user: rabbitmq
  - group: rabbitmq
  - makedirs: True
  - mode: 440
  - require:
    - pkg: rabbitmq_server
  - contents: |
        # This file is managed by Salt, changes will be overwritten
  {%- for config_line in pillar['rabbitmq'].get('config', []) %}
        {{ config_line }}
  {%- endfor %}

{%- if grains.os_family == 'Debian' %}

rabbitmq_default_config:
  file.managed:
  - name: {{ server.default_file }}
  - source: salt://rabbitmq/files/default
  - template: jinja
  - user: rabbitmq
  - group: rabbitmq
  - mode: 440
  - require:
    - pkg: rabbitmq_server

{%- endif %}{# grains.os_family == 'Debian'  #}

{%- if grains.init == 'systemd' %}

rabbit_systemd_service_create:
  file.directory:
    - name: /etc/systemd/system/rabbitmq-server.service.d
    - require:
        - pkg: rabbitmq_server
    - makedirs: True

rabbit_set_ulimit:
  file.managed:
    - name: /etc/systemd/system/rabbitmq-server.service.d/limits.conf
    - require:
        - pkg: rabbitmq_server
    - contents: |
        [Service]
        LimitNOFILE=65536

rabbit_systemd_service:
  service.running:
    - name: rabbitmq-server
    - enable: True
{%- endif %}{# grains.init == 'systemd'  #}

