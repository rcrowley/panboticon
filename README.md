Panboticon
==========

A prison for AI agents where you can see what they're up to.

Panboticon launches and bootstraps EC2 instances with

* a human user account with direct access to GitHub,
* a bot user account with access to GitHub brokered by a GitHub App (which you must bring yourself) in order to prevent impersonation,
* custom bootstrapping hooks for both human and bot where you can configure your preferred agent harness, and
* kernel audit logging enabled so you can always see what your bots are up to.

Those kernel audit logs are intense so <https://github.com/rcrowley/panboticon-skills> includes an _audit_ skill to help you summarize them.

Installation
------------

    make && make install prefix=~
    # or
    make && sudo make install # installs to /usr/local by default

From a Git work tree (say, if you're going to work on Panboticon itself):

    export PATH="/path-to-panboticon-work-tree/bin:$PATH"

While not strictly necessary to _install_ Panboticon, there are four prerequisites without which you won't make it very far _using_ Panboticon:

* The AWS CLI and one of the following authentication mechanisms:
    * Functioning `aws sso login` command.
    * Standing access via `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and sometimes `AWS_SESSION_TOKEN` environment variables.
    * Some other default credential provider the AWS SDK understands.
* AWS CLI [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
* AWS IAM role and instance profile with at least the AmazonSSMManagedInstanceCore policy attached
* GitHub App:
    1. Visit <https://github.com/settings/apps/new>. Give your bot a name and a homepage (which doesn't matter). Don't bother with a callback URL. Uncheck _Active_ in the **Webhook** section (unless you really want to receive webhooks). Grant read and write permissions for repository administration, contents, issues, and pull requests. Allow installation for _Any account_.
    2. Click **Generate a private key**. Keep the PEM file in a safe place locally or, much better yet, put it in 1Password.
    3. Upload an avatar for your GitHub App. If you don't, it will use your avatar and erode the anti-impersonation measures that are kind of the point here.
    4. In the left column, click **Install App**. Select the organization(s) in which you wish to install the app.

Usage
-----

    panboticon config --format json >~/.panboticon.json
    # edit ~/.panboticon.json to configure it
    # if your IAM role has greater permissions than AmazonSSMManagedInstanceCore and ReadOnlyAccess, we STRONGLY
    # recommend setting `PANBOTICON_BOT_REJECT_CIDR_PREFIXES` to `["169.254.169.254/32", "fd00:ec2::254/128"]`

    panboticon --help

    panboticon launch # launch and bootstrap a new Panboticon instance in EC2

    panboticon ssh # SSH into your Panboticon instance

    panboticon boxen # list all your Panboticon boxen

    panboticon bootstrap # re-bootstrap your already-launched Panboticon instance

    panboticon terminate # terminate your Panboticon instance

Most commands accept a _name_ to operate on a single Panboticon instance at a time.
