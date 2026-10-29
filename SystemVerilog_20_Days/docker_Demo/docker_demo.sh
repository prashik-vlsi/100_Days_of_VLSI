#!/usr/bin/env bash

set -e

IMAGE="debian:bookworm"
CONTAINER="bookworm-demo"

# --------------------------------------------------
# Function: display command, then execute it
# --------------------------------------------------
run() {
    echo
    printf '$ '
    printf '%q ' "$@"
    echo
    "$@"
}

echo "========== DOCKER BOOKWORM DEMO =========="


# --------------------------------------------------
# 1. Check Docker
# --------------------------------------------------

echo
echo '$ command -v docker'

if command -v docker >/dev/null 2>&1; then
    echo "Docker is installed."
else
    echo "Docker not installed."

    if command -v apt >/dev/null 2>&1; then
        run sudo apt update
        run sudo apt install -y docker.io
    else
        echo "Automatic installation requires an apt-based Linux system."
        exit 1
    fi
fi


# --------------------------------------------------
# 2. Docker Version
# --------------------------------------------------

run docker --version


# --------------------------------------------------
# 3. Check Docker Engine
# --------------------------------------------------

echo
echo '$ sudo docker info'

if sudo docker info >/dev/null 2>&1; then
    echo "Docker Engine is running."
else
    echo "Docker Engine is not running."

    run sudo systemctl start docker
fi


# --------------------------------------------------
# 4. Check old demo container
# --------------------------------------------------

echo
echo '$ sudo docker container inspect bookworm-demo'

if sudo docker container inspect "$CONTAINER" >/dev/null 2>&1; then

    echo "Old container found."

    run sudo docker rm -f "$CONTAINER"

else
    echo "No old container found."
fi


# --------------------------------------------------
# 5. Check old Bookworm image
# --------------------------------------------------

echo
echo '$ sudo docker image inspect debian:bookworm'

if sudo docker image inspect "$IMAGE" >/dev/null 2>&1; then

    echo "Old Bookworm image found."

    run sudo docker rmi -f "$IMAGE"

else
    echo "No old Bookworm image found."
fi


# --------------------------------------------------
# 6. Pull fresh Bookworm image
# --------------------------------------------------

run sudo docker pull "$IMAGE"


# --------------------------------------------------
# 7. Show Docker image
# --------------------------------------------------

run sudo docker images "$IMAGE"


# --------------------------------------------------
# 8. Create Bookworm container
# --------------------------------------------------

run sudo docker run \
    -dit \
    --name "$CONTAINER" \
    "$IMAGE" \
    bash


# --------------------------------------------------
# 9. Show running container
# --------------------------------------------------

run sudo docker ps \
    --filter "name=$CONTAINER"


# --------------------------------------------------
# 10. Show OS running inside container
# --------------------------------------------------

run sudo docker exec \
    "$CONTAINER" \
    cat /etc/os-release


echo
echo "========== DEMO COMPLETE =========="
