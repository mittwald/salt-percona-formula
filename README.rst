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

Install and start percona-server. Includes percona.config, percona.client and percona.repo.

``percona.client``
-------

Install the client. Includes percona.config and percona.repo.

``percona.config``
-------

If pillar "mysql.config.<filename>" is set, manage those. Server will not be
restarted by default, set pillar "mysql.restart_on_change: True" for
autorestart on config change.

``percona.repo``
-------

Just configure the repo.

TODO
====

* Write support for autoscale and performance optimizations
* Write support for dynamic variables
