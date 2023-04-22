# [andrewmackrodt/traefik-letsencrypt-cloudflare](https://github.com/andrewmackrodt/traefik-letsencrypt-cloudflare)

[docker-compose](https://docs.docker.com/compose/overview/) template for running
a reverse proxy with support for:

- Let's Encrypt certificate generation (using DNS Challenge)
- Automatic Cloudflare DNS record additions

## Usage

### Configuration

#### Cloudflare

Copy `.env.dist` to `.env` and set the below `CF_*` fields. A Cloudflare account
is required and the domain must be configured to use Cloudflare for DNS. The
**Global API Key** can be retrieved from https://dash.cloudflare.com/profile/api-tokens.

```sh
# cloudflare email address
CF_API_EMAIL=admin@mydomain.com

# cloudflare api token
CF_API_TOKEN=bf9d3cbb93d0

# cloudflare domain name
CF_DOMAIN=mydomain.com

# cloudflare domain zone id
CF_ZONE_ID=1234567890
```

#### Traefik Dashboard

The Traefik Dashboard can be enabled at `https://traefik.${CF_DOMAIN}` by
setting the environment variables:

- `TRAEFIK_API_BASIC_AUTH_USERS`
- `TRAEFIK_API_ENABLE`

HTTP basic auth is used for authentication, credentials can be generated with
`htpasswd`, e.g.

```
# generate password interactively using bcrypt (recommended)
htpasswd -nB admin
> admin:$2y$05$mHw3zw1oXbgwHrHTIVQn2uHkPlyirynsXNSHPn8GUWEzoDT2QESnu

# generate password non-interactively using bcrypt
htpasswd -nbB admin password
> admin:$2y$05$mHw3zw1oXbgwHrHTIVQn2uHkPlyirynsXNSHPn8GUWEzoDT2QESnu
```

It is recommended to enclose the credentials using a single quote when adding
them to `.env`. This prevents errors with docker-compose and/or your shell when
interpreting `$`, e.g.

```sh
TRAEFIK_API_BASIC_AUTH_USERS='admin:$2y$05$2UxZBKKL3T8qZEhdExSczOI5OYnCLJj14o3zjJPswMTWmFAhARXNG'
```

Multiple credentials can be specified by separating them with a comma.

### Starting

```sh
docker-compose up -d
```

### Adding new services

Additional services can be added by setting the required `traefik` labels during
container creation. For example, to add a service with the subdomain `whoami`
where `CF_DOMAIN=mydomain.com` (i.e. `whoami.mydomain.com`), use the following
configuration:

**docker-compose:**

```yml
services:
  whoami:
    container_name: whoami
    image: traefik/whoami
    labels:
      - traefik.enable=true
      - traefik.http.routers.whoami.rule=Host(`whoami.mydomain.com`)
      - traefik.http.services.whoami.loadBalancer.server.port=80
    restart: unless-stopped
```

**docker cli:**

```bash
docker run --name whoami --restart=always \
  --label "traefik.enable=true" \
  --label "traefik.http.routers.whoami.rule=Host(\`whoami.mydomain.com\`)" \
  --label "traefik.http.services.whoami.loadBalancer.server.port=80" \
  traefik/whoami
```

Services that are not a subdomain of `CF_DOMAIN` can also be added, although
DNS records will not automatically be created for them.

#### Advanced service configuration

**Use a wildcard certificate for the domain:**

```sh
--label "traefik.http.routers.whoami.tls.domains[0].main=mydomain.com"
--label "traefik.http.routers.whoami.tls.domains[0].sans=*.mydomain.com"
```

**Connect to an https enabled backend:**

```sh
--label "traefik.http.services.whoami.loadBalancer.server.scheme=https"
```
