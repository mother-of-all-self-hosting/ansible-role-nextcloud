<!--
SPDX-FileCopyrightText: 2020 - 2024 MDAD project contributors
SPDX-FileCopyrightText: 2020 - 2024 Slavi Pantaleev
SPDX-FileCopyrightText: 2020 Aaron Raimist
SPDX-FileCopyrightText: 2020 Chris van Dijk
SPDX-FileCopyrightText: 2020 Dominik Zajac
SPDX-FileCopyrightText: 2020 Mickaël Cornière
SPDX-FileCopyrightText: 2022 François Darveau
SPDX-FileCopyrightText: 2022 Julian Foad
SPDX-FileCopyrightText: 2022 Warren Bailey
SPDX-FileCopyrightText: 2023 Antonis Christofides
SPDX-FileCopyrightText: 2023 Felix Stupp
SPDX-FileCopyrightText: 2023 Pierre 'McFly' Marty
SPDX-FileCopyrightText: 2024 - 2025 Suguru Hirahara

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Setting up Semaphore UI

This is an [Ansible](https://www.ansible.com/) role which installs [Semaphore UI](https://semaphoreui.com) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

Semaphore UI is a modern UI for Ansible, Terraform/OpenTofu/Terragrunt, PowerShell and other DevOps tools.

See the project's [documentation](https://docs.semaphoreui.com/) to learn what Semaphore UI does and why it might be useful to you.

## Prerequisites

To run a Semaphore UI instance it is necessary to prepare a database. You can use a [SQLite](https://www.sqlite.org/), [Postgres](https://www.postgresql.org/), or [MySQL](https://www.mysql.com/) compatible database server. By default it is configured to use SQLite.

If you are looking for Ansible roles for a Postgres or MySQL compatible server, you can check out [ansible-role-postgres](https://github.com/mother-of-all-self-hosting/ansible-role-postgres) and [ansible-role-mariadb](https://github.com/mother-of-all-self-hosting/ansible-role-mariadb), both of which are maintained by the [Mother-of-All-Self-Hosting (MASH)](https://github.com/mother-of-all-self-hosting) team.

## Adjusting the playbook configuration

To enable Semaphore UI with this role, add the following configuration to your `vars.yml` file.

**Note**: the path should be something like `inventory/host_vars/mash.example.com/vars.yml` if you use the [MASH Ansible playbook](https://github.com/mother-of-all-self-hosting/mash-playbook).

```yaml
########################################################################
#                                                                      #
# semaphore                                                            #
#                                                                      #
########################################################################

semaphore_enabled: true

########################################################################
#                                                                      #
# /semaphore                                                           #
#                                                                      #
########################################################################
```

### Set the hostname

To enable Semaphore UI you need to set the hostname as well. To do so, add the following configuration to your `vars.yml` file. Make sure to replace `example.com` with your own value.

```yaml
semaphore_hostname: "example.com"
```

After adjusting the hostname, make sure to adjust your DNS records to point the domain to your server.

To host Semaphore UI under a subpath, add the following configuration to your `vars.yml` file.

```yaml
semaphore_environment_variables_web_root: "https://example.com/semaphore"
```

### Configure database

You can specify the database to use by setting a value to `semaphore_database_type` as below:

```yaml
semaphore_database_type: postgres
```

Set `mysql` for MySQL compatible database. If neither of them is selected, Semaphore UI will default to SQLite.

>[!NOTE]
> BoltDB support has been deprecated with [v2.16.7](https://github.com/semaphoreui/semaphore/releases/tag/v2.16.7).

For other settings, check variables such as `semaphore_database_mysql_*` and `semaphore_database_postgres_*` on [`defaults/main.yml`](../defaults/main.yml) .

### Set details for the admin user

You also need to create an instance's admin user. To create one, add the following configuration to your `vars.yml` file. Make sure to replace values with your own ones.

```yaml
semaphore_admin_username: ADMIN_USERNAME_HERE
semaphore_admin_password: ADMIN_PASSWORD_HERE
semaphore_admin_name: ADMIN_ACTUAL_NAME_HERE
semaphore_admin_email: ADMIN_EMAIL_ADDRESS_HERE
```

Generating a strong password (e.g. `pwgen -s 64 1`) is recommended for `semaphore_admin_password`.

### Set a string for encrypting access keys

You also need to specify a string used for encrypting access keys in database. To do so, add the following configuration to your `vars.yml` file. The value can be generated with `head -c32 /dev/urandom | base64` or in another way.

```yaml
semaphore_access_key_encryption: YOUR_SECRET_KEY_HERE
```

>[!NOTE]
> Other type of values such as one generated with `pwgen -s 64 1` does not work.

### Enable 2FA authentication with TOTP (optional)

You can optionally enable two-factor authentication with TOTP by adding the following configuration to your `vars.yml` file:

```yaml
semaphore_environment_variables_totp_enabled: true
```

To allow a user to reset TOTP with a recovery code, add the following configuration as well:

```yaml
semaphore_environment_variables_totp_allow_recovery: true
```

### Configure the mailer

You can configure a SMTP mailer by adding the following configuration to your `vars.yml` file as below (adapt to your needs):

```yaml
# Set the email address that emails will be sent from
semaphore_environment_variables_email_sender: semaphore@example.com

# Set the hostname of the SMTP server
semaphore_environment_variables_email_host: smtp.example.com

# Set the port number of the SMTP server
semaphore_environment_variables_email_port: ''

# Set the username for the SMTP server
semaphore_environment_variables_email_username: semaphore@example.com

# Set the password for the SMTP server
semaphore_environment_variables_email_password: YOUR_PASSWORD_HERE

# Set to true if SSL or TLS is used for communication with the SMTP server
semaphore_environment_variables_email_secure: false
```

⚠️ **Note**: without setting an authentication method such as DKIM, SPF, and DMARC for your hostname, emails are most likely to be quarantined as spam at recipient's mail servers. If you have set up a mail server with the [MASH project's exim-relay Ansible role](https://github.com/mother-of-all-self-hosting/ansible-role-exim-relay), you can enable DKIM signing with it. Refer [its documentation](https://github.com/mother-of-all-self-hosting/ansible-role-exim-relay/blob/main/docs/configuring-exim-relay.md#enable-dkim-support-optional) for details.

### Extending the configuration

There are some additional things you may wish to configure about the component.

Take a look at:

- [`defaults/main.yml`](../defaults/main.yml) for some variables that you can customize via your `vars.yml` file. You can override settings (even those that don't have dedicated playbook variables) using the `semaphore_environment_variables_additional_variables` variable

See its [environment variables](https://docs.semaphoreui.com/administration-guide/configuration/) for a complete list of Semaphore UI's config options that you could put in `semaphore_environment_variables_additional_variables`.

## Installing

After configuring the playbook, run the installation command of your playbook as below:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all,start
```

If you use the MASH playbook, the shortcut commands with the [`just` program](https://github.com/mother-of-all-self-hosting/mash-playbook/blob/main/docs/just.md) are also available: `just install-all` or `just setup-all`

## Usage

After running the command for installation, Semaphore UI becomes available at the specified hostname like `https://example.com`.

You can open the page with a web browser to log in to the instance. See [this official guide](https://docs.semaphoreui.com/user-guide/projects/) to get started.

## Troubleshooting

[The official documentation](https://docs.semaphoreui.com/faq/troubleshooting/) is available for troubleshooting.

### Check the service's logs

You can find the logs in [systemd-journald](https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html) by logging in to the server with SSH and running `journalctl -fu semaphore` (or how you/your playbook named the service, e.g. `mash-semaphore`).
