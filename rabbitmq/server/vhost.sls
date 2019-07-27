{%- from "rabbitmq/map.jinja" import server with context %}

{%- for vhost in pillar['rabbitmq'].get('vhosts', []) %}
rabbit_vhost_{{ loop.index }}:
  {%- if vhost['present'] is defined and vhost['present'] is not none and vhost['present'] %}
  rabbitmq_vhost.present:
    {%- elif vhost['absent'] is defined and vhost['absent'] is not none and vhost['absent'] %}
  rabbitmq_vhost.absent:
    {%- endif %}
    - name: '{{ vhost['name'] }}'
{%- endfor %}
