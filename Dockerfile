FROM debian:stretch-slim

# Install, update & upgrade packages
# Create user for the server
# This also creates the home directory we later need
# Clean TMP, apt-get cache and other stuff to make the image smaller
# Create Directory for SteamCMD
# Download SteamCMD
# Extract and delete archive
RUN set -x \
	&& dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		lib32stdc++6 \
		libcurl4-gnutls-dev:i386 \
		wget \
		ca-certificates \
	&& useradd -m steam \
	&& su steam -c \
		"mkdir -p /home/steam/steamcmd \
		&& cd /home/steam/steamcmd \
		&& wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf -" \
        && apt-get clean autoclean \
        && apt-get autoremove -y \
        && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Switch to user steam
USER steam

# Install L4d2 server
RUN set -x \
 ./home/steam/steamcmd/steamcmd.sh \
        +login anonymous \
        +force_install_dir /home/steam/dst \
        +app_update 343050 validate \
        +quit

VOLUME /home/steam/steamcmd

# Set Entrypoint; Technically 2 steps: 1. Update server, 2. Start server
ENTRYPOINT ./home/steam/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/dst +app_update 343050 +quit && \ echo "pds-g^KU_o3FCkNjU^nKoLgoKhGhmSlY1+oq6DFhgguyWrcwUqilOiRv3buE4=" >> /home/steam/.klei//DoNotStarveTogether/cluster_token.txt && \
        ./home/steam/dst/bin/dontstarve_dedicated_server_nullrenderer

# Expose ports
EXPOSE 0.0.0.0:10999:10999/udp