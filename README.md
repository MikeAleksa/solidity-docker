# Solidity Development Docker Image

Docker image for Solidity development that includes:
- Go
- Go-Ethereum (geth)
- Solidity-Compiler (solc)
- zsh, oh-my-zsh, and helpful plugins

---

## Tags

<b>current (1.17-1.10.15-0.8.11)</b>
- Go: 1.17
- Go-Ethereum: 1.10.15
- solc: 0.8.11

---

## Build Instructions

Go, Go-Ethereum, and solc versions can be passed as arguments to the docker build command.

The supplied `build-and-push.sh` script can be used to initiate a multi-arch build (linux/arm64, linux/amd64) and push to dockerhub.