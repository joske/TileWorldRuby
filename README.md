# TileWorldRuby

sudo gem install gtk3 algorithms

ruby main.rb

in Docker:

docker build -t tileworld .

(On macOS, make sure XQuartz is running and allowing network connections)

docker run --rm -e DISPLAY=host.docker.internal:0 -ti --init tileworld