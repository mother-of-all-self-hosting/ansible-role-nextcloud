<!--
SPDX-FileCopyrightText: 2026 Timofej Luitle

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Configuring the OIDC Provider for Nextcloud

This role can optionally enable and configure the [OpenID Connect Provider App](https://github.com/H2CK/oidc), so that users can login to other services using their Nextcloud accounts via OAuth2.

The `oidc.yml` task provided in this role will request a list of all installed OIDC clients, remove clients if settings don't match and (re-)install clients with the provided configuration.

## Basic usage

First, enable the OIDC Provider app:

```yml
nextcloud_app_oidc_enabled: true
```

Then, add an entry to the `nextcloud_oidc_clients` dictionary for each service you want to configure as an OIDC client:

```yml
nextcloud_oidc_clients:
  forgejo:
    enabled: true
    redirect_uris: "https://{{ forgejo_hostname }}/user/oauth2/{{ forgejo_oidc_provider_name | urlencode }}/callback"
  mobilizon:
    enabled: true
    redirect_uris: "https://{{ mobilizon_hostname }}/auth/keycloak/callback"
```

To configure a client it is necessary to set the `enabled: true` as well as the appropriate `redirect_uris` entry.

Optionally set `client_name`, `client_id` and `client_secret`:

```yml
nextcloud_oidc_clients:
  forgejo:
    enabled: true
    redirect_uris: "https://{{ forgejo_hostname }}/user/oauth2/{{ forgejo_oidc_provider_name | urlencode }}/callback"
    client_name: "my-awesome-forgejo-instance"
    client_id: "" # generate with e.g. pwgen -s 64 1
    client_secret: "" # generate with e.g. pwgen -s 64 1
```

>[!NOTE]
>Be mindful that `client_name` is used to discover installed clients when there is no matching `client_id`, for cases when `client_id` is changed or not set.
>To avoid duplicates, all clients with the same `client_name` that are not configured in `nextcloud_oidc_clients` will be removed.
>Use unique `client_name` values to avoid deletion of manually installed namesake clients.
>If not set, `client_name` defaults to the client descriptor in the `nextcloud_oidc_clients` dictionary, in the configuration above it would be `forgejo` and `mobilizon` respectively.

>[!NOTE]
>It is possible to leave the `client_id` and the `client_secret` blank, in which case a random ID and secret will be generated and conveyed at the end of the playbook execution for retrieval.
>It is recommended to add the generated `client_id` and `client_secret` to your variables after task completion.

Run the configuration task with:

```cmd
just run-tags configure-oidc-provider-nextcloud
```

## Additional configuration

By default, the `groups` and `roles` claims for all clients contain a list of the GIDs (internal Group ID) the user is part of, which might not be identical to the group display names seen in the Nextcloud UI.

To provide the display name instead for a given claim, set the following variables (`gid` is default):

```yml
nextcloud_oidc_group_claim_type: "displayname"
nextcloud_oidc_role_claim_type: "gid"
```

Furthermore, the client options can be configured with the following variables:

```yml
## Client configuration for the Nextcloud OIDC Provider
nextcloud_oidc_clients:
  mobilizon:
    # If enabled, OIDC client will be installed, otherwise it will be deleted
    enabled: true
    # The name of the client
    client_name: "{{ mobilizon_identifier }}"
    # A space-separated array of redirect uris, e.g. "https://first.uri https://second.uri"
    redirect_uris: "https://{{ mobilizon_hostname }}/auth/keycloak/callback"
    # The client id to be used. If not provided the client id will be generated internally.
    # Requirements: chars A-Za-z0-9 & min length 32 & max length 64
    client_id: ""
    # The client secret to be used. If not provided the client secret will be generated internally.
    # Requirements: chars A-Za-z0-9 & min length 32 & max length 64
    client_secret: ""
    # The allowed scopes for the client. E.g. ´openid profile roles´.
    # If not defined any scope is accepted.
    scopes: "openid email profile"
    # The signing algorithm to use. Can be ´RS256´ or ´HS256´.
    algorithm: "RS256"
    # The flow type to use for authentication. Can be ´code´ or ´code id_token´.
    flow: "code"
    # The type of the client. Can be ´public´ or ´confidential´.
    type: "confidential"
    # The type of the access token created for the client.
    # If set to ´jwt´ a RFC9068 conforming access token is generated.
    token_type: "opaque"
    # The regular expression to select the used email from all email addresses of a user (primary and secondary).
    # If not set always the primary email address will be used.
    email_regex: ""
    # The resource URL for this client (RFC 9728). Must be a valid URL with max length 512 characters.
    resource_url: ""
```

>[!NOTE]
>If an optional client configuration variable is not defined, this task will reuse the previously configured value before resetting to the default.
>Therefore if a client setting is adjusted in the UI (at https://<nextcloud_hostname>/settings/admin/oidc_provider), the change is respected only if the associated variable in not set.
>To reset a variable, specify it explicitly within `nextcloud_oidc_clients`, e.g. `resource_url: ""`.

Removing an OIDC client is possible by removing or setting the `enabled` variable to `false` while retaining the client in `nextcloud_oidc_clients`:

```yml
nextcloud_oidc_clients:
  forgejo:
    enabled: false
```

The OIDC app also supports creating [custom claims](https://github.com/H2CK/oidc/wiki/User-Documentation#custom-claims) for clients which this task currently does not address.
