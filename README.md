# sql-azure-firewall-opener
Script and Dockerfile for utility script which opens the current external IP on a SQL Azure server firewall

# multi-architecture builds
`docker buildx build --platform linux/amd64,linux/arm64 --tag redriversoftware/sql-azure-firewall-opener:version_here --push -f Dockerfile .`