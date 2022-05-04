# CronosSandPit
Dockerised version of the CRONOS network with a validator, sentry node (not implemented yet) and explorer.

this is me learning the ecosystem and will form the foundation of what i will be trying to pwn.


/etc/hosts
127.0.0.1	traefik.noodletestnet.local croval01.noodletestnet.local logs.noodletestnet.local explorer.noodletestnet.local



explorer wont run on ARM atm.. think its getting confused during build.. try it out on a amd64 native distro

explorer not tried yet and should be the area of focus, node SOLO mode works quite well and container logs can be viewed at the LOGS url.

im to the point where the explorer compiles, its just a case of hooking it up to the validator and should be done.