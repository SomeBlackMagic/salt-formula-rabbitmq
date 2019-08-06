{%- from "rabbitmq/map.jinja" import server with context %}

include:
- rabbitmq.server.pkg
- rabbitmq.server.service
-
{%- if server.ssl.enabled %}
- rabbitmq.server.ssl
{%- endif %}

- rabbitmq.server.plugin
- rabbitmq.server.vhost
- rabbitmq.server.user
