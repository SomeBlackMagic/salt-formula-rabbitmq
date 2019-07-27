{%- from "rabbitmq/map.jinja" import server with context %}
{%- if server.enabled %}
{% if grains['os_family'] == 'Debian' %}
erlang_repo:
  pkgrepo.managed:
    - humanname: Erlang Repository
    - name: deb http://packages.erlang-solutions.com/ubuntu {{ grains['oscodename'] }} contrib
    - file: /etc/apt/sources.list.d/erlang.list
    - key_url: http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
    - require_in:
    - pkg: esl-erlang
rabbit_repo:
  pkgrepo.managed:
    - humanname: RabbitMQ Repository
    - name: deb https://dl.bintray.com/rabbitmq/debian {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/rabbitmq.list
    - key_url: https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc

{% elif grains['os'] == 'CentOS' and grains['osmajorrelease'][0] == '6' %}
rabbitmq_repo:
  pkgrepo.managed:
    - humanname: RabbitMQ Packagecloud Repository
    - baseurl: https://packagecloud.io/rabbitmq/rabbitmq-server/el/6/$basearch
    - gpgcheck: 1
    - enabled: True
    - gpgkey: https://packagecloud.io/gpg.key
    - sslverify: 1
    - sslcacert: /etc/pki/tls/certs/ca-bundle.crt
    - require_in:
    - pkg: rabbitmq-server
{% endif %}

{%- endif %}
