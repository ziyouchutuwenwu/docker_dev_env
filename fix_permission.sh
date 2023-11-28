#! /bin/bash

sudo chown -R `whoami` ~/projects/docker/
sudo chgrp -R `whoami` ~/projects/docker/
sudo chmod -R ugo=rwx ~/projects/docker/

sudo chown -R 65534 ~/projects/docker/nfs
sudo chgrp -R 65534 ~/projects/docker/nfs
