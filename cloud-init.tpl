#cloud-config
runcmd:
  - sed -i '/\[Service\]/a Environment="PORT=${service_port}"' /etc/systemd/system/fastify-hello-world.service
  - sudo systemctl daemon-reload
  - sudo systemctl restart fastify-hello-world
