{%- from "rabbitmq/map.jinja" import server with context %}
{%- if server.enabled %}

{%- for host_name, host in server.get('host', {}).iteritems() %}

{%- if host.enabled %}

{%- if host_name != '/' %}
rabbitmq_vhost_{{ host_name }}:
  rabbitmq_vhost.present:
  - name: {{ host_name }}
  - require:
    - service: rabbitmq_service
{%- endif %}


{%- else %}

rabbitmq_vhost_{{ host_name }}:
  rabbitmq_vhost.absent:
  - name: {{ host_name }}
  - require:
    - service: rabbitmq_service

rabbitmq_user_{{ host.user }}:
  rabbitmq_user.absent:
  - name: {{ host.user }}
  - require:
    - service: rabbitmq_service

{%- endif %}

{%- endfor %}

{%- endif %}
