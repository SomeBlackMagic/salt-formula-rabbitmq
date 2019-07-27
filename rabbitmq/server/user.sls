{%- from "rabbitmq/map.jinja" import server, rabbitmq_users with context %}

include:
- rabbitmq.server.service

{%- if server.admin is defined %}
rabbit_user_admin_present:
  rabbitmq_user.present:
    - name: {{ server.admin.login }}
    - password: {{ server.admin.password }}
    - force: True
    - tags: administrator
    - perms:
        - '/':
            - '.*'
            - '.*'
            - '.*'
  {%- for vhost in pillar['rabbitmq']['server'].get('vhosts', []) %}
      {%- if vhost['present'] is defined and vhost['present'] is not none and vhost['present'] %}
        - '{{ vhost['name'] }}':
            - '.*'
            - '.*'
            - '.*'
      {%- endif %}
  {%- endfor %}
{%- endif %}


{%- if server.users is defined %}

  {%- for user in pillar['rabbitmq']['server'].get('users', []) %}

rabbit_user_{{ user['name'] }}:
  {%- if user['present'] is defined and user['present'] is not none and user['present'] %}
  rabbitmq_user.present:
    - name: '{{ user['name'] }}'
    - password: {{ user['password'] }}
    - force: True
    - tags: {{ user.get('tags', []) }}
    - perms: {{ user.get('perms', []) }}
    {%- elif user['absent'] is defined and user['absent'] is not none and user['absent'] %}
  rabbitmq_user.absent:
    - name: '{{ user['name'] }}'
    {%- endif %}
  {%- endfor %}
{%- endif %}


