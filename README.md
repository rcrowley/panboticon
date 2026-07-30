Panboticon
==========

A prison for AI agents.

Panboticon launches and bootstraps EC2 instances with

* a human user account with direct access to GitHub,
* a bot user account with access to GitHub brokered by a GitHub App (which you must bring yourself) in order to prevent impersonation,
* typical AI agent harness tools pre-installed, and
* kernel audit logging enabled so you can always see what your bots are up to.

Those kernel audit logs are intense so <https://github.com/rcrowley/panboticon-skills> includes an _audit_ skill to help you summarize them.

Installation
------------

    export PATH="/path-to-panboticon-work-tree/bin:$PATH"

TODO: Implement `make install`.

Usage
-----

    panboticon config --format json >~/.panboticon.json
    # edit ~/.panboticon.json to configure it

    panboticon --help

    panboticon launch # launch and bootstrap a new Panboticon instance in EC2

    panboticon ssh # SSH into your Panboticon instance

    panboticon boxen # list all your Panboticon boxen

    panboticon bootstrap # re-bootstrap your already-launched Panboticon instance

    panboticon terminate # terminate your Panboticon instance

Most commands accept a _name_ to operate on a single Panboticon instance at a time.
