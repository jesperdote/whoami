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

**`monitoring/` is not deployed by Jenkins - it requires a manual step.** The `deploy-whoami`
pipeline only ever touches the container (`git pull` + `docker-compose up`); it never copies
`monitoring/healthcheck-monitor.sh` to `/usr/local/bin/` or `monitoring/devops-profile-healthcheck.service`
to `/etc/systemd/system/` on the BananaPi, because the `jenkins` user has no sudo there and
those paths need root. **Any edit to either file in this repo silently does not reach the
running watchdog until someone manually re-copies it and restarts the service** - this already
caused a real incident once (the watchdog kept checking a URL from before a route rename,
404ing forever, restarting a perfectly healthy container every ~90s). After editing either
file, on the BananaPi:

```bash
sudo cp monitoring/healthcheck-monitor.sh /usr/local/bin/healthcheck-monitor.sh
sudo chmod +x /usr/local/bin/healthcheck-monitor.sh
# only if the .service file itself changed:
sudo cp monitoring/devops-profile-healthcheck.service /etc/systemd/system/devops-profile-healthcheck.service
sudo systemctl daemon-reload
sudo systemctl restart devops-profile-healthcheck.service
```

## Local dev

```bash
docker compose up -d --build
```

Bind-mounts the working directory over the Nginx html folder for live-reload; not used
in production (`docker-compose.prod.yml` bakes files into the image instead).
