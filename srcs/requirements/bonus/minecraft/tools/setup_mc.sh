#!/bin/bash

# Download Minecraft Server (Vanilla 1.20.4) if not present
if [ ! -f /server/server.jar ]; then
    echo "Downloading Minecraft Server 1.20.4..."
    wget -q "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar" -O /server/server.jar
fi

# Automatically accept EULA
if [ ! -f /server/eula.txt ]; then
    echo "eula=true" > /server/eula.txt
fi

# Optimization: reduce server rendering distance and disable online mode for faster startup / testing if needed
# We will just run standard online-mode server here.

echo "Starting Minecraft Server..."
exec java -Xmx1024M -Xms1024M -jar /server/server.jar nogui
