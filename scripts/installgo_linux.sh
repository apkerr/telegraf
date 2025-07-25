#!/bin/sh

set -eux

GO_VERSION="1.24.4"
GO_ARCH="linux-amd64"
# from https://go.dev/dl
GO_VERSION_SHA="77e5da33bb72aeaef1ba4418b6fe511bc4d041873cbf82e5aa6318740df98717"

# Download Go and verify Go tarball
setup_go () {
    echo "installing go"
    curl -L https://go.dev/dl/go${GO_VERSION}.${GO_ARCH}.tar.gz --output go${GO_VERSION}.${GO_ARCH}.tar.gz
    if ! echo "${GO_VERSION_SHA}  go${GO_VERSION}.${GO_ARCH}.tar.gz" | shasum --algorithm 256 --check -; then
        echo "Checksum failed" >&2
        exit 1
    fi

    sudo rm -rfv /usr/local/go
    sudo tar -C /usr/local -xzf go${GO_VERSION}.${GO_ARCH}.tar.gz
}

if command -v go >/dev/null 2>&1; then
    echo "Go is already installed"
    cd
    v=$(go version | { read -r _ _ v _; echo "${v#go}"; })
    echo "$v is installed, required version is ${GO_VERSION}"
    if [ "$v" != ${GO_VERSION} ]; then
        setup_go
    fi
else
    setup_go
fi

echo "$PATH"
command -v go
go version
