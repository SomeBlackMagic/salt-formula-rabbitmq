=========================
Usage
=========================

RabbitMQ is a complete and highly reliable enterprise messaging
system based on the emerging AMQP standard.

Sample pillars
==============

NON ACTUAL. See pillar.example

Standalone Broker
-----------------

RabbitMQ as AMQP broker with admin user and vhosts:

.. code-block:: yaml

    rabbitmq:
      server:
        enabled: true
        memory:
          vm_high_watermark: 0.4
        bind:
          address: 0.0.0.0
          port: 5672
        secret_key: rabbit_master_cookie
        admin:
          name: adminuser
          password: pwd
        plugins:
        - amqp_client
        - rabbitmq_management
        host:
          '/monitor':
            enabled: true
            user: 'monitor'
            password: 'password'

RabbitMQ as a Stomp broker:

.. code-block:: yaml

    rabbitmq:
      server:
        enabled: true
        secret_key: rabbit_master_cookie
        bind:
          address: 0.0.0.0
          port: 5672
        host:
          '/monitor':
            enabled: true
            user: 'monitor'
            password: 'password'
        plugins_runas_user: rabbitmq
        plugins:
        - rabbitmq_stomp

RabbitMQ cluster
----------------

RabbitMQ as base cluster node:

.. code-block:: yaml

    rabbitmq:
      server:
        enabled: true
        master: openstack1
        {% if grains['host'] == 'openstack1' %}
        role: master
        {% else %}
        role: slave
        {% endif %}
        bind:
          address: 0.0.0.0
          port: 5672
        secret_key: rabbit_master_cookie
        admin:
          name: adminuser
          password: pwd
      cluster:
        enabled: true
        role: master
        mode: disc
        members:
        - name: openstack1
          host: 10.10.10.212
        - name: openstack2
          host: 10.10.10.213

HA Queues definition:

.. code-block:: yaml

    rabbitmq:
      server:
        enabled: true
        ...
        host:
          '/monitor':
            enabled: true
            user: 'monitor'
            password: 'password'
            policies:
            - name: HA
              pattern: '^(?!amq\.).*'
              definition: '{"ha-mode": "all"}'

Enable TLS support
------------------

To enable support of TLS for rabbitmq-server you need to provide
a path to cacert, server cert and private key:

.. code-block:: yaml

   rabbitmq:
      server:
        enabled: true
        ...
        ssl:
          enabled: True
          key_file: /etc/rabbitmq/ssl/key.pem
          cert_file: /etc/rabbitmq/ssl/cert.pem
          ca_file: /etc/rabbitmq/ssl/ca.pem

To manage content of these files you can either use the following
options:

.. code-block:: yaml

   rabbitmq:
      server:
        enabled: true
        ...
        ssl:
          enabled: True

          key_file: /etc/rabbitmq/ssl/key.pem
          key: |
          -----BEGIN RSA PRIVATE KEY-----
                    ...
          -----END RSA PRIVATE KEY-------

          ca_file: /etc/rabbitmq/ssl/ca.pem
          cacert_chain: |
          -----BEGIN CERTIFICATE-----
                    ...
          -----END CERTIFICATE-------

          cert_file: /etc/rabbitmq/ssl/cert.pem
          cert: |
          -----BEGIN CERTIFICATE-----
                    ...
          -----END CERTIFICATE-------


Or you can use the `salt.minion.cert` salt state which
creates all required files according to defined reclass model.
See
https://github.com/Mirantis/reclass-system-salt-model/tree/master/salt/minion/cert/rabbitmq
for details. In this case you need just to enable ssl and nothing more:

.. code-block:: yaml

   rabbitmq:
      server:
        enabled: true
        ...
        ssl:
          enabled: True

Defaut port for TLS is ``5671``:

.. code-block:: yaml

  rabbitmq:
    server:
      bind:
        ssl:
         port: 5671

Usage
=====

Check cluster status, example shows running cluster with 3 nodes:
ctl-1, ctl-2, ctl-3

.. code-block:: yaml

    > rabbitmqctl cluster_status

    Cluster status of node 'rabbit@ctl-1' ...
    [{nodes,[{disc,['rabbit@ctl-1','rabbit@ctl-2','rabbit@ctl-3']}]},
     {running_nodes,['rabbit@ctl-3','rabbit@ctl-2','rabbit@ctl-1']},
     {partitions,[]}]
    ...done.

Setup management user:

.. code-block:: yaml

    > rabbitmqctl add_vhost vhost
    > rabbitmqctl add_user user alive
    > rabbitmqctl set_permissions -p vhost user ".*" ".*" ".*"
    > rabbitmqctl set_user_tags user management

EPD process is Erlang Port Mapper Daemon. It's a feature of the
Erlang runtime that helps Erlang nodes to find each other. It's a
pretty tiny thing and doesn't contain much state (other than "what
Erlang nodes are running on this system?") so it's not a huge deal for
it to still be running.

Although it's running as user rabbitmq, it was started automatically
by the Erlang VM when we started. We've considered adding "epmd -kill"
to our shutdown script - but that would break any other Erlang apps
running on the system; it's more "global" than RabbitMQ.

Read more
=========

* http://www.rabbitmq.com/admin-guide.html
* https://github.com/saltstack/salt-contrib/blob/master/states/rabbitmq_plugins.py
* http://docs.saltstack.com/ref/states/all/salt.states.rabbitmq_user.html
* http://stackoverflow.com/questions/14699873/how-to-reset-user-for-rabbitmq-management
* http://www.rabbitmq.com/memory.html

Clustering
==========

* http://www.rabbitmq.com/clustering.html#auto-config
* https://github.com/jesusaurus/hpcs-salt-state/tree/master/rabbitmq
* http://gigisayfan.blogspot.cz/2012/06/rabbit-mq-clustering-python-fabric.html
* http://docwiki.cisco.com/wiki/OpenStack_Havana_Release:_High-Availability_Manual_Deployment_Guide#RabbitMQ_Installation

Documentation and Bugs
======================

* http://salt-formulas.readthedocs.io/
   Learn how to install and update salt-formulas

* https://github.com/salt-formulas/salt-formula-rabbitmq/issues
   In the unfortunate event that bugs are discovered, report the issue to the
   appropriate issue tracker. Use the Github issue tracker for a specific salt
   formula

* https://launchpad.net/salt-formulas
   For feature requests, bug reports, or blueprints affecting the entire
   ecosystem, use the Launchpad salt-formulas project

* https://launchpad.net/~salt-formulas-users
   Join the salt-formulas-users team and subscribe to mailing list if required

* https://github.com/salt-formulas/salt-formula-rabbitmq
   Develop the salt-formulas projects in the master branch and then submit pull
   requests against a specific formula

* #salt-formulas @ irc.freenode.net
   Use this IRC channel in case of any questions or feedback which is always
   welcome
