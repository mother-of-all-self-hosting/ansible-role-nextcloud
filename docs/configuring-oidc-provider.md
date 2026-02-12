<!--
SPDX-FileCopyrightText: 2026 Timofej Luitle

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Configuring the OIDC Provider for Nextcloud

This role can optionally enable and configure the [OpenID Connect Provider App](https://github.com/H2CK/oidc), so that users can login to other services using their Nextcloud accounts via OAuth2.

## Basic usage

To configure an OIDC client for a service, add the respective identifier to the `nextcloud_oidc_clients_list` variable and enable the respective OIDC client:

```yml
nextcloud_oidc_clients_list:
  - forgejo
  - mobilizon
  
forgejo_oidc_client_enabled: true
mobilizon_oidc_client_enabled: true
```

If the clients don't have a callback url defined in their `defaults.yml`, it is necessary to set a `redirect_uris` variable:

```yml
forgejo_oidc_redirect_uris: "https://{{ forgejo_hostname }}/user/oauth2/{{ forgejo_oidc_provider_name | urlencode }}/callback"
mobilizon_oidc_redirect_uris: "https://{{ mobilizon_hostname }}/auth/keycloak/callback"
```

Optionally set a `client_name`. If absent, it generally defaults to the identifier:

```yml
forgejo_oidc_client_name: "{{ forgejo_identifier }}"
mobilizon_oidc_client_name: "{{ mobilizon_identifier }}"
```

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

Furthermore, the client options can be configured with the following variables per service:

```yml
## Client configuration for the Nextcloud OIDC Provider

# The name of the client
mobilizon_oidc_client_name: "{{ mobilizon_identifier }}"
# An array of redirect uris
mobilizon_oidc_redirect_uris: "https://{{ mobilizon_hostname }}/auth/keycloak/callback"
# The client id to be used. If not provided the client id will be generated internally.
# Requirements: chars A-Za-z0-9 & min length 32 & max length 64
mobilizon_oidc_client_id: ""
# The client secret to be used. If not provided the client secret will be generated internally.
# Requirements: chars A-Za-z0-9 & min length 32 & max length 64
mobilizon_oidc_client_secret: ""
# The allowed scopes for the client. E.g. ´openid profile roles´.
# If not defined any scope is accepted.
mobilizon_oidc_scopes: "openid email profile"
# The signing algorithm to use. Can be ´RS256´ or ´HS256´.
mobilizon_oidc_algorithm: "RS256"
# The flow type to use for authentication. Can be ´code´ or ´code id_token´.
mobilizon_oidc_flow: "code"
# The type of the client. Can be ´public´ or ´confidential´. 
mobilizon_oidc_type: "confidential"
# The type of the access token created for the client.
# If set to ´jwt´ a RFC9068 conforming access token is generated.
mobilizon_oidc_token_type: "opaque"
# The regular expression to select the used email from all email addresses of a user (primary and secondary).
# If not set always the primary email address will be used.
mobilizon_oidc_email_regex: ""
# The resource URL for this client (RFC 9728). Must be a valid URL with max length 512 characters.
mobilizon_oidc_resource_url: ""
```
>[!NOTE]
>It is possible to leave the `client_id` and the `client_secret` blank, in which case a random ID and secret will be generated and conveyed at the end of the playbook execution for retrieval.
>Please add the `client_id` and `client_secret` to your variables as recommended after task completion.

## Considerations

This task will request a list of all installed OIDC clients, remove clients if settings don't match and (re-)install clients with the provided configuration.

Additionally it will ensure that the `name` of the handled clients are unique and will therefore remove all namesake clients. Be mindful.

>[!NOTE]
>If an optional client configuration variable is not defined, this task first try to reuse the previously set value before setting a default.
>Therefore if a client setting is adjusted in the UI (at https://{{ nextcloud_hostname }}/settings/admin/oidc_provider), the change is respected only if the associated variable in not set.

Removing an OIDC client is also possible by setting the `oidc_client_enabled` variable to `false` while retaining the client in `nextcloud_oidc_clients_list`:

```yml
nextcloud_oidc_clients_list:
  - forgejo
  - mobilizon
  
forgejo_oidc_client_enabled: true
mobilizon_oidc_client_enabled: false
```

The OIDC app also supports creating [custom claims](https://github.com/H2CK/oidc/wiki/User-Documentation#custom-claims) for clients which this task currently does not address.
