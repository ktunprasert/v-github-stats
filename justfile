alias b := build
alias r := run
alias c := clear
alias d := dev

flags := "-d use_openssl"

# flag only required for linux builds
default:
    v {{flags}} run .

dev:
    v -d veb_livereload watch {{flags}} run . -d -c

_build:
    @echo "Building V project"
    v -prod -compress -d use_openssl -cflags '-static -Os -flto' -o main .

build: _build
    @echo "Building Docker image"
    docker-compose build

run:
    docker-compose up --build

clear:
    rm public/*.svg
