alias b := build
alias r := run

flags := "-d use_openssl"

# flag only required for linux builds
default:
    v {{flags}} run main.v

build:
    @echo "Building V project"
    v -prod -compress -d use_openssl -cflags '-static -Os -flto' -o main .
    @echo "Building Docker image"
    docker build -t v-github-stats .

run:
    docker run --rm v-github-stats:latest
