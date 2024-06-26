#! /bin/bash

sudo chown -R $(whoami) ~/projects
sudo chgrp -R $(whoami) ~/projects
sudo chmod -R ugo=rwx ~/projects

sudo chown -R 65534 ~/projects/docker/nfs
sudo chgrp -R 65534 ~/projects/docker/nfs
