<!--
SPDX-FileCopyrightText: 2020 - 2024 MDAD project contributors
SPDX-FileCopyrightText: 2020 - 2025 Slavi Pantaleev
SPDX-FileCopyrightText: 2020 Aaron Raimist
SPDX-FileCopyrightText: 2020 Chris van Dijk
SPDX-FileCopyrightText: 2020 Dominik Zajac
SPDX-FileCopyrightText: 2020 Mickaël Cornière
SPDX-FileCopyrightText: 2022 François Darveau
SPDX-FileCopyrightText: 2022 Julian Foad
SPDX-FileCopyrightText: 2022 Warren Bailey
SPDX-FileCopyrightText: 2023 - 2024 MASH project contributors
SPDX-FileCopyrightText: 2023 Antonis Christofides
SPDX-FileCopyrightText: 2023 Felix Stupp
SPDX-FileCopyrightText: 2023 Gergely Horváth
SPDX-FileCopyrightText: 2023 Pierre 'McFly' Marty
SPDX-FileCopyrightText: 2024 - 2025 Suguru Hirahara
SPDX-FileCopyrightText: 2024 Philipp Homann

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Setting up Nextcloud

This is an [Ansible](https://www.ansible.com/) role which installs [Nextcloud](https://nextcloud.com) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

Nextcloud is one of the most popular self-hosted collaboration solutions.

See the project's [documentation](https://docs.nextcloud.com) to learn what Nextcloud does and why it might be useful to you.

## Prerequisites

To run a Nextcloud instance it is necessary to prepare a database. You can use a [SQLite](https://www.sqlite.org/), [Postgres](https://www.postgresql.org/), or [MySQL](https://www.mysql.com/) compatible database server. By default it is configured to use Postgres.

If you are looking for Ansible roles for a Postgres or MySQL compatible server, you can check out [ansible-role-postgres](https://github.com/mother-of-all-self-hosting/ansible-role-postgres) and [ansible-role-mariadb](https://github.com/mother-of-all-self-hosting/ansible-role-mariadb), both of which are maintained by the [Mother-of-All-Self-Hosting (MASH)](https://github.com/mother-of-all-self-hosting) team.

>[!NOTE]
> Nextcloud recommends MySQL / MariaDB on [this page](https://docs.nextcloud.com/server/latest/admin_manual/configuration_database/linux_database_configuration.html) of the documentation. Note that not all versions of them are recommended. See [this page](https://docs.nextcloud.com/server/latest/admin_manual/installation/system_requirements.html#server) for system requirements.

## Adjusting the playbook configuration

To enable Nextcloud with this role, add the following configuration to your `vars.yml` file.

**Note**: the path should be something like `inventory/host_vars/mash.example.com/vars.yml` if you use the [MASH Ansible playbook](https://github.com/mother-of-all-self-hosting/mash-playbook).

```yaml
########################################################################
#                                                                      #
# nextcloud                                                            #
#                                                                      #
########################################################################

nextcloud_enabled: true

########################################################################
#                                                                      #
# /nextcloud                                                           #
#                                                                      #
########################################################################
```

### Set the hostname

To enable Nextcloud you need to set the hostname as well. To do so, add the following configuration to your `vars.yml` file. Make sure to replace `example.com` with your own value.

```yaml
nextcloud_hostname: "example.com"
```

After adjusting the hostname, make sure to adjust your DNS records to point the domain to your server.

>[!NOTE]
> Changing the hostname after the first installation is currently not supported by Nextcloud. See [this page](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/domain_change.html) on the documentation as well.

### Configure database

By default Nextcloud is configured to use Postgres, but you can choose other databases such as MySQL (MariaDB) and SQLite.

To use MariaDB, add the following configuration to your `vars.yml` file:

```yaml
nextcloud_database_type: mysql
```

Set `mysql` for MySQL compatible database or `sqlite` for SQLite, respectively.

For other settings, check variables such as `nextcloud_database_mysql_*` and `nextcloud_database_*` on [`defaults/main.yml`](../defaults/main.yml).

>[!NOTE]
> It is possible to convert a SQLite database to a MySQL, MariaDB or PostgreSQL database with the Nextcloud command line tool. See [this page](docs.nextcloud.com/server/latest/admin_manual/configuration_database/db_conversion.html) on the documentation for details.

### Configure the default language (optional)

You can set the default language on your Nextcloud instance with ISO_639-1 language codes as below:

```yml
nextcloud_config_parameter_default_language: de
```

By default it is set to English.

### Configure the default phone region (optional)

You can set the default region for phone numbers on your Nextcloud instance with ISO 3166-1 country codes as below:

```yml
nextcloud_config_parameter_default_phone_region: GB
```

It is not set by default.

### Configure the default timezone (optional)

It is also possible to set the default timezone with IANA identifiers such as `Europe/Berlin` as below:

```yml
nextcloud_config_parameter_default_timezone: Europe/Berlin
```

By default it is set to UTC.

>[!NOTE]
> Setting a proper timezone is important for some instances such as using Nextcloud applications like [Calendar](https://apps.nextcloud.com/apps/calendar) and [Forms](https://apps.nextcloud.com/apps/forms) where it is possible to set an expiration date to a form.

### Configure memory caching (optional)

Nextcloud recommends to set up memory caching for improving performance and preventing file locking problems. You can use [APCu](https://pecl.php.net/package/APCu), [Memcached](https://www.memcached.org/), and [Redis](https://redis.io/).

If you are looking for an Ansible role for Redis, you can check out [ansible-role-redis](https://github.com/mother-of-all-self-hosting/ansible-role-redis) maintained by the [Mother-of-All-Self-Hosting (MASH)](https://github.com/mother-of-all-self-hosting) team. The roles for [KeyDB](https://keydb.dev/) ([ansible-role-keydb](https://github.com/mother-of-all-self-hosting/ansible-role-keydb)) and [Valkey](https://valkey.io/) ([ansible-role-valkey](https://github.com/mother-of-all-self-hosting/ansible-role-valkey)) are available as well.

To enable Redis for Nextcloud, add the following configuration to your `vars.yml` file, so that the Nextcloud instance will connect to the server:

```yaml
nextcloud_redis_hostname: YOUR_REDIS_SERVER_HOSTNAME_HERE
nextcloud_redis_password: YOUR_REDIS_SERVER_PASSWORD_HERE
nextcloud_redis_port: 6379
```

Make sure to replace `YOUR_REDIS_SERVER_HOSTNAME_HERE` and `YOUR_REDIS_SERVER_PASSWORD_HERE` with your own values.

See below for details:

- <https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/caching_configuration.html>
- <https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/config_sample_php_parameters.html#memory-caching-backend-configuration>

### Configure the mailer (optional)

You can configure a SMTP mailer by adding the following configuration to your `vars.yml` file as below (adapt to your needs):

```yaml
# Set the hostname of the SMTP server
nextcloud_environment_variables_smtp_host: ""

# Set the port number of the SMTP server
nextcloud_environment_variables_smtp_port: 587

# Specify the localpart of the sender (localpart@domain)
nextcloud_environment_variables_mail_from_address: ""

# Specify the domain for the external SMTP server if it is different from the domain where Nextcloud is installed
nextcloud_environment_variables_mail_domain: ""

# Set the username for the SMTP server
nextcloud_environment_variables_smtp_name: ""

# Set the password for the SMTP server
nextcloud_environment_variables_smtp_password: ""

# Set `ssl` or `tls` if one of them is used for communication with the SMTP server
nextcloud_environment_variables_smtp_secure: ""

# Specify the method used for authentication. Set PLAIN if no authentication is required.
nextcloud_environment_variables_smtp_authtype: LOGIN
```

⚠️ **Note**: without setting an authentication method such as DKIM, SPF, and DMARC for your hostname, emails are most likely to be quarantined as spam at recipient's mail servers. If you have set up a mail server with the [MASH project's exim-relay Ansible role](https://github.com/mother-of-all-self-hosting/ansible-role-exim-relay), you can enable DKIM signing with it. Refer [its documentation](https://github.com/mother-of-all-self-hosting/ansible-role-exim-relay/blob/main/docs/configuring-exim-relay.md#enable-dkim-support-optional) for details.

### Configure object storages as primary storage (optional)

>[!WARNING]
> Configuring an object storage on an existing Nextcloud instance as the primary one will make **all existing files on the instance inaccessible**!
>
> Before proceeding, please have a look at [this page](https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/primary_storage.html) to know differences between the primary storage and an external storage. Also make sure to understand important implications of using the primary object storage, such as the one that *your files on the primary storage will ONLY be able to be retrieved through the Nextcloud instance, making it necessary to take it into consideration when planning a data backup strategy.*

It is possible to configure object storages such as OpenStack Swift or Amazon S3 or any compatible S3-implementation as the primary storage.

Since required settings are different among implementations, the role does not set default configurations for them. You can check [this section](https://github.com/docker-library/docs/blob/master/nextcloud/README.md#auto-configuration-via-environment-variables) to see what needs configuring for your storage provider. Consult the documentation by the provider as well.

To use a S3 compatible object storage as the primary storage, check `OBJECTSTORE_S3_*` environment variables. For OpenStack Swift, you can use `OBJECTSTORE_SWIFT_*` environment variables.

For example, you can have the Nextcloud instance use the bucket named `example` on Storj (a S3 compatible storage) as the primary storage by adding the following configuration to your `vars.yml` file:

```yaml
nextcloud_environment_variables_additional_variables: |
  OBJECTSTORE_S3_BUCKET=example
  OBJECTSTORE_S3_HOST=gateway.storjshare.io
  OBJECTSTORE_S3_KEY=YOUR_ACCESS_KEY_HERE
  OBJECTSTORE_S3_SECRET=YOUR_SECRET_KEY_HERE
  OBJECTSTORE_S3_USEPATH_STYLE=true
```

### Enable Samba (optional)

To enable [Samba](https://www.samba.org/) external Windows fileshares using [smbclient](https://www.samba.org/samba/docs/current/man-html/smbclient.1.html), add the following configuration to your `vars.yml` file:

```yaml
nextcloud_container_image_customizations_samba_enabled: true
```

With this configuration a customized image with the smbclient package installed will be built.

### Extending the configuration

There are some additional things you may wish to configure about the component.

Take a look at:

- [`defaults/main.yml`](../defaults/main.yml) for some variables that you can customize via your `vars.yml` file. You can override settings (even those that don't have dedicated playbook variables) using the `nextcloud_environment_variables_additional_variables` variable

See its [environment variables](https://github.com/docker-library/docs/blob/master/nextcloud/README.md#auto-configuration-via-environment-variables) for a complete list of Nextcloud's config options that you could put in `nextcloud_environment_variables_additional_variables`.

## Installing

After configuring the playbook, run the installation command of your playbook as below:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all,start
```

If you use the MASH playbook, the shortcut commands with the [`just` program](https://github.com/mother-of-all-self-hosting/mash-playbook/blob/main/docs/just.md) are also available: `just install-all` or `just setup-all`

## Usage

After running the command for installation, the Nextcloud instance becomes available at the URL specified with `nextcloud_hostname` and `nextcloud_path_prefix`. With the configuration above, the service is hosted at `https://example.com`.

### Update configuration

Before logging in to the instance, update the configuration (URL paths, trusted reverse-proxies, etc.) by running the command below:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=adjust-nextcloud-config
```

>[!NOTE]
> You should re-run the command every time the Nextcloud version is updated.

You can open the URL with a web browser to log in to the instance. See [this official guide](https://docs.nextcloud.com/server/latest/admin_manual/contents.html) to get started.

### Run mimetype migrations

After the initial installation or upgrading the instance, there might appear a warning on the administration overview page at `https://example.com/settings/admin/overview` about mimetype migrations.

The command below is available for the migrations:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=mimetype-migrations-nextcloud
```

### Integrate Collabora Online Development Edition (optional)

It is possible to integrate the Collabora Online Development Edition (CODE) instance to Nextcloud.

If you are looking for an Ansible role for CODE, you can check out [ansible-role-collabora-online](https://github.com/mother-of-all-self-hosting/ansible-role-collabora-online) maintained by the [Mother-of-All-Self-Hosting (MASH)](https://github.com/mother-of-all-self-hosting) team.

After installing CODE and [defining an allowed WOPI (Web Application Open Platform Interface) host](https://sdk.collaboraonline.com/docs/installation/CODE_Docker_image.html#how-to-configure-docker-image) to the `aliasgroup1` environment variable for the CODE instance, add the following configuration for Nextcloud to your `vars.yml` file:

```yaml
nextcloud_app_collabora_wopi_url: YOUR_CODE_INSTANCE_URL_HERE
```

Then, run this command to install and configure the [Office](https://apps.nextcloud.com/apps/richdocuments) app for Nextcloud:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=install-nextcloud-app-collabora
```

Open the URL `https://example.com/settings/admin/richdocuments` to have the instance set up the connection with the CODE instance.

You should then be able to open any document (`.doc`, `.odt`, `.pdf`, etc.) and create new ones in Nextcloud Files with Collabora Online Development Edition's editor.

>[!NOTE]
> By default, various private IPv4 networks are whitelisted to connect to the WOPI API (document serving API). If your CODE instance does not live on the same server as Nextcloud, you may need to adjust the list of networks. If necessary, redefine the `nextcloud_app_collabora_wopi_allowlist` environment variable on `vars.yml`.

### Enable Preview Generator app (optional)

It is also possible to set up preview generation by following the steps below.

The Preview Generator has two stages, [according to its README](https://github.com/nextcloud/previewgenerator).

- a generate-all phase — this has to be executed only a single time
- a pre-generate phase — this should be run in a cronjob. That runs quite fast if the generate-all phase finished.

As we do not want to run the generate-all phase multiple times, its execution timing is decided based on existence of the file created on the host side.

#### Enable preview on `vars.yml`

First, add the following configuration to `vars.yml` and run the playbook.

```yaml
nextcloud_preview_enabled: true
```

>[!NOTE]
> If it is set back to `false`, the host side files are cleaned up, and also the cron job is changed, not to call preview generation again. Note that the database and generated previews are kept intact thereafter.

You can edit other settings by adding the following configuration to your `vars.yml` file:

```yaml
# Specify the maximum size of the preview in pixels
nextcloud_preview_preview_max_x: MAX_HORIZONTAL_SIZE_HERE
nextcloud_preview_preview_max_y: MAX_VERTICAL_SIZE_HERE

# Specify JPEG quality for preview images
nextcloud_preview_app_jpeg_quality: MAX_QUALITY_VALUE_HERE
```

#### Install the app on Nextcloud

Next, install the Preview Generator app (<https://apps.nextcloud.com/apps/previewgenerator>) from the Settings/Application menu in your Nextcloud instance.

#### Run the command for config adjustment

After it is installed, run the command below against your server, so that initial preview-generation is started and periodic generation of new images on your server is enabled:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=adjust-nextcloud-config
```

Running it sets up the variables and calls the generate-all script, that will also create the file —— signalling its finished state —— on the host.

**Notes**:

- The initial generation may take a long time, and a continuous prompt is presented by Ansible as some visual feedback (it is being run as an async task). Note it will timeout after approximately 27 hours. For reference, it should take about 10 minutes to finish generating previews of 60 GB data, most of which being image files.
- If it takes more time to run than a day, you may want to start it by running the command on the host:

    ```sh
    /usr/bin/env docker exec mash-nextcloud-server php /var/www/html/occ preview:generate-all
    ```

## Troubleshooting

### Check the service's logs

You can find the logs in [systemd-journald](https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html) by logging in to the server with SSH and running `journalctl -fu nextcloud-server` (or how you/your playbook named the service, e.g. `mash-nextcloud-server`).

### Query the server status

Run the command below to query the Nextcloud server status:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=query-status-nextcloud
```

#### Enable debug mode

You can enable debugging mode for Nextcloud by adding the following configuration to your `vars.yml` file:

```yml
nextcloud_config_parameter_debug: true
```

Make sure to run the command below to update the configuration:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=adjust-nextcloud-config
```

#### Increase logging verbosity

If you want to increase the verbosity, add the following configuration to your `vars.yml` file:

```yaml
nextcloud_config_parameter_loglevel: 0

nextcloud_config_parameter_loglevel_frontend: 0
```
