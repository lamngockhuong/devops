# Blue Green Deployment

Create the systemd service:

```bash
chmod +x create-systemd-service.sh # run it only once
sudo ./create-systemd-service.sh
```

Create the nginx configuration:

```bash
chmod +x create-nginx-sites.sh # run it only once
sudo ./create-nginx-sites.sh
```

Build & deploy:

```bash
chmod +x blue-green-deploy.sh # run it only once
sudo ./blue-green-deploy.sh
```

## References

- <https://vaadin.com/blog/a-minimal-zero-downtime-deployment-using-nginx-spring-boot>
