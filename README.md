# [andrewmackrodt/nginx-letsencrypt-cloudflare](https://github.com/andrewmackrodt/nginx-letsencrypt-cloudflare)

[docker-compose](https://docs.docker.com/compose/overview/) template for running
a reverse proxy with support for:

- Let's Encrypt certificate generation
- Automatic Cloudflare DNS record additions

## Usage

### Configuration

Copy `.env.dist` to `.env` and set the below environment variables. A Cloudflare
account is required and the domain must be configured to use Cloudflare for DNS.
The **Global API Key** can be retrieved from https://dash.cloudflare.com/profile/api-tokens.

```sh
# cloudflare email address
CF_EMAIL=admin@mydomain.com

# cloudflare api token
CF_TOKEN=bf9d3cbb93d0

# cloudflare domain name
CF_DOMAIN=mydomain.com

# the cname target
CF_TARGET=mydomain.com

# cloudflare domain zone id
CF_ZONE_ID=1234567890
```

### Starting

```sh
docker-compose up -d
```

### Adding new services

Additional services can be added by exposing the service port and setting the
required environment variables during container creation. For example, to add a
service with the subdomain `whoami` where `CF_DOMAIN=mydomain.com` (i.e.
`whoami.mydomain.com`), use the following configuration:

**docker-compose:**

```yml
services:
  whoami:
    container_name: whoami
    image: containous/whoami
    expose:
      - 80
    environment:
      VIRTUAL_HOST: whoami.mydomain.com
      VIRTUAL_PORT: 80
      LETSENCRYPT_HOST: whoami.mydomain.com
      LETSENCRYPT_EMAIL: admin@mydomain.com
    restart: unless-stopped
```

**docker cli:**

```bash
docker run --name whoami --restart=always --expose 80 \
  --env "VIRTUAL_HOST=whoami.mydomain.com" \
  --env "VIRTUAL_PORT=80" \
  --env "LETSENCRYPT_HOST=whoami.mydomain.com" \
  --env "LETSENCRYPT_EMAIL=admin@mydomain.com" \
  containous/whoami
```

Services that are not a subdomain of `CF_DOMAIN` can also be added, although
DNS records will not automatically be created for them.
