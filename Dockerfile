ARG GO_VERSION=1.17
ARG GETH_VERSION=1.10.15
ARG SOLIDITY_VERSION=0.8.11

# # # # # # # # # # # # # # # # # # 
# BUILD GETH
# # # # # # # # # # # # # # # # # # 
FROM golang:${GO_VERSION}-alpine AS geth
ARG GETH_VERSION
RUN apk --update add --virtual build-dependencies make gcc libc-dev linux-headers git
RUN mkdir -p /go/src/github.com/ethereum
WORKDIR /go/src/github.com/ethereum 
RUN git clone https://github.com/ethereum/go-ethereum.git
WORKDIR /go/src/github.com/ethereum/go-ethereum
RUN git checkout tags/v${GETH_VERSION}
RUN make all
WORKDIR /go/src/github.com/ethereum/go-ethereum/build/bin
RUN mv * /go/bin

# # # # # # # # # # # # # # # # # # 
# BUILD SOLC
# # # # # # # # # # # # # # # # # # 
FROM golang:${GO_VERSION}-alpine AS solc
ARG SOLIDITY_VERSION
RUN apk --update add --virtual build-dependencies curl g++ make cmake boost-dev boost-static z3-dev
WORKDIR /go/src/github.com/solc
RUN curl -fsSLO https://github.com/ethereum/solidity/releases/download/v${SOLIDITY_VERSION}/solidity_${SOLIDITY_VERSION}.tar.gz
RUN tar -xzf solidity_${SOLIDITY_VERSION}.tar.gz && rm solidity_${SOLIDITY_VERSION}.tar.gz
RUN cd solidity_${SOLIDITY_VERSION} && mkdir build && cd build && cmake .. && make
RUN cp /go/src/github.com/solc/solidity_${SOLIDITY_VERSION}/build/solc/solc /go/bin/solc

# # # # # # # # # # # # # # # # # # 
# SETUP ZSH, GO, GETH, SOLC
# # # # # # # # # # # # # # # # # # 
FROM golang:${GO_VERSION}-alpine
# setup shell environment: zsh, oh-my-zsh and plugins, nano
RUN apk --no-cache add zsh git curl nano
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
COPY docker-zshrc /root/.zshrc
RUN touch /root/.z
RUN sed -i 's/\/bin\/ash/\/bin\/zsh/g' /etc/passwd
# copy solc and go-ethereum binaries
COPY --from=solc /go/bin/solc /bin/solc
COPY --from=geth /go/bin/abidump /bin/abidump
COPY --from=geth /go/bin/abigen /bin/abigen
COPY --from=geth /go/bin/bootnode /bin/bootnode
COPY --from=geth /go/bin/clef /bin/clef
COPY --from=geth /go/bin/ethkey /bin/ethkey
COPY --from=geth /go/bin/faucet /bin/faucet
COPY --from=geth /go/bin/geth /bin/geth
COPY --from=geth /go/bin/p2psim /bin/p2psim
COPY --from=geth /go/bin/rlpdump /bin/rlpdump
COPY --from=geth /go/bin/checkpoint-admin /bin/checkpoint-admin
COPY --from=geth /go/bin/devp2p /bin/devp2p
COPY --from=geth /go/bin/evm /bin/evm
COPY --from=geth /go/bin/puppeth /bin/puppeth
# add additional packages
RUN apk --no-cache add gcc musl-dev z3-dev
# expose ports
EXPOSE 8545/tcp
EXPOSE 8546/tcp
ENTRYPOINT [ "/bin/zsh" ]