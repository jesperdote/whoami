# whoami

DevOps/SRE portfolio page, self-hosted at [infdxeta.info/whoami/](https://infdxeta.info/whoami/).

Plain HTML/CSS/JS, no build step - a custom `nginx:alpine` image serves it directly.

## Deployment

Self-hosted on a BananaPi device via Jenkins (`deploy-whoami` pipeline, see `Jenkinsfile`),
same setup as this author's [blog](https://github.com/jesperdote/blog). Unlike the blog,
there's no cross-arch build step needed (the Dockerfile builds fine directly on the
BananaPi's armv7), so it's a single-stage pipeline: pull, `docker-compose -f
docker-compose.prod.yml up -d --build --force-recreate`.

A front-proxy (`klept-lab/proj`, `front/nginx/default.conf`) routes `/whoami/` to this
container's published port (8014), and a Cloudflare Tunnel on the BananaPi exposes it
publicly.

`entrypoint.sh` writes a live `uptime.txt` (polled by the footer every 5s) and
`monitoring/` runs a host-level systemd watchdog that restarts the container if
`/health.txt` stops responding - both predate the Jenkins pipeline and are left in place.

## Local dev

```bash
docker compose up -d --build
```

Bind-mounts the working directory over the Nginx html folder for live-reload; not used
in production (`docker-compose.prod.yml` bakes files into the image instead).
