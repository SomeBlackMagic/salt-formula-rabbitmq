{%- from "rabbitmq/map.jinja" import server, rabbitmq_users with context %}
{%- if server.enabled %}

include:
- rabbitmq.server.service

{%- if server.admin is defined %}

rabbit_user_admin_present:
  rabbitmq_user.present:
    - name: {{ pillar['rabbitmq']['admin']['name'] }}
    - password: {{ pillar['rabbitmq']['admin']['password'] }}
    - force: True
    - tags: administrator
    - perms:
        - '/':
            - '.*'
            - '.*'
            - '.*'
  {%- for vhost in pillar['rabbitmq'].get('vhosts', []) %}
      {%- if vhost['present'] is defined and vhost['present'] is not none and vhost['present'] %}
        - '{{ vhost['name'] }}':
            - '.*'
            - '.*'
            - '.*'
      {%- endif %}
  {%- endfor %}
{%- endif %}


{%- endif %}

{%- if server.users is defined %}

  {%- for user_key, user in server.get('users', {}).iteritems() %}

    {%- if user.enabled %}

rabbitmq_add_user_{{ user.username }}:
  rabbitmq_user.present:
  - name: {{ user.username }}
  - password: {{ user.password }}
  - force: true
  - tags: {{ user.tags | default('', true) }}
  - perms:
    - '{{ user.vhost }}':
      - '.*'
      - '.*'
      - '.*'

      {%- for policy in user.get('policies', []) %}

rabbitmq_policy_{{ user.vhost }}_{{ policy.name }}:
  rabbitmq_policy.present:
  - name: {{ policy.name }}
  - pattern: {{ policy.pattern }}
  - definition: {{ policy.definition|json }}
  - priority: {{ policy.get('priority', 0)|int }}
  - vhost: {{ user.vhost }}
  - require:
    - service: rabbitmq_service

      {%- endfor %}

      {%- else %}

rabbitmq_drop_user_{{ user.user }}:
  rabbitmq_user.absent:
  - name: guest
  - require:
    - service: rabbitmq_service


      {%- for policy in user.get('policies', []) %}

rabbitmq_policy_{{ user.vhost }}_{{ policy.name }}:
  rabbitmq_policy.present:
  - name: {{ policy.name }}
  - pattern: {{ policy.pattern }}
  - definition: {{ policy.definition|json }}
  - priority: {{ policy.get('priority', 0)|int }}
  - vhost: {{ user.vhost }}
  - require:
    - service: rabbitmq_service

      {%- endfor %}

    {%- endif %}

  {%- endfor %}

{%- endif %}
