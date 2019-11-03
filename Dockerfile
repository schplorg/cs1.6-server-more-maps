FROM debian:8

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  lib32gcc1 \
  wget \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m steam
WORKDIR /home/steam
USER steam

RUN wget -nv https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz

RUN /home/steam/steamcmd.sh +login anonymous +force_install_dir /home/steam/cs16 +app_set_config 90 mod cstrike +quit
RUN /home/steam/steamcmd.sh +login anonymous +force_install_dir /home/steam/cs16 +app_update 90 validate +quit; exit 0
RUN /home/steam/steamcmd.sh +login anonymous +force_install_dir /home/steam/cs16 +app_update 90 validate +quit; exit 0
RUN /home/steam/steamcmd.sh +login anonymous +force_install_dir /home/steam/cs16 +app_update 90 validate +quit
RUN /home/steam/steamcmd.sh +login anonymous +force_install_dir /home/steam/cs16 +app_update 70 validate +quit || :
RUN /home/steam/steamcmd.sh +login anonymous +force_install_dir /home/steam/cs16 +app_update 10 validate +quit || :

RUN mkdir -p ~/.steam && ln -s ~/linux32 ~/.steam/sdk32

WORKDIR /home/steam/cs16

# Add metamod
RUN mkdir -p cstrike/addons/metamod/dlls
COPY metamod_i386.so cstrike/addons/metamod/dlls/
COPY metamod.so cstrike/addons/metamod/dlls/

# Add bots
COPY podbot cstrike/addons/podbot
RUN echo "linux addons/podbot/podbot_mm_i386.so" > cstrike/addons/metamod/plugins.ini
COPY liblist.gam cstrike/

# Copy configs
COPY *.cfg cstrike/

EXPOSE 27015/tcp
EXPOSE 27015/udp

CMD ./hlds_run -game cstrike -strictportbind -autoupdate -ip 0.0.0.0 +map de_dust2 -maxplayers 32
