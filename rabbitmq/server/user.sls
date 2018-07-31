{%- from "rabbitmq/map.jinja" import server, rabbitmq_users with context %}
{%- if server.enabled %}

include:
- rabbitmq.server.service

{%- if server.admin is defined %}

rabbit_user_admin_present:
  rabbitmq_user.present:
  - name: {{ server.admin.name }}
  - password: {{ server.admin.password }}
  - force: True
  - tags: administrator
  - perms:
    {%- for vhost_name, vhost in server.get('host', {}).iteritems() %}
    - '{{ vhost_name }}':
      - '.*'
      - '.*'
      - '.*'
    {%- endfor %}
  - require:
    - service: rabbitmq_service

{%- endif %}

{%- if 'guest' not in rabbitmq_users.keys() %}
{#- Delete default guest user if we are not using it #}
rabbitmq_user_guest_absent:
  rabbitmq_user.absent:
  - name: guest
  - require:
    - service: rabbitmq_service
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