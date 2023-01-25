#! /bin/sh

set -e

export MIX_ENV=prod
export MIX_TARGET=rpi3 
export HOST=ball_beam.local

MIX_TARGET=host mix do deps.get, assets.deploy
mix deps.get
mix firmware
mix upload $HOST
