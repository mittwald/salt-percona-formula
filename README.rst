======
percona
======

Install percona version 5.7
Tested with:
* Ubuntu 16.04
* CentOS 7.2

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``percona.server``
-------

Install and start percona-server. Includes percona.config and percona.install.

``percona.client``
-------

Install the client. Includes percona.config-files and percona.repo.

``percona.install``
-------

Install percona-server and enable it. Includes percona.config-files, percona.client and percona.repo.

``percona.config-files``
-------

If pillar "mysql.config.<filename>" is set, manage those.

``percona.config``
-------

Includes percona.config-files and adds autorestart on config change if pillar "mysql.restart_on_change: True" is set. Additionally changes dynamic configuration at runtime.

``percona.repo``
-------

Just configure the repo.

TODO
====

* Write support for autoscale and performance optimizations
* Write support for dynamic variables
