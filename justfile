flags := "-d use_openssl"

# flag only required for linux builds
default:
    v {{flags}} run main.v
