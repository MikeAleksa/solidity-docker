ARG GO_VERSION=1.17
ARG GETH_VERSION=1.10.15
ARG SOLIDITY_VERSION=0.8.11

# # # # # # # # # # # # # # # # # # 
# BUILD GETH
# # # # # # # # # # # # # # # # # # 
FROM golang:${GO_VERSION}-alpine AS geth
ARG GETH_VERSION
RUN apk --update add --virtual build-dependencies gcc libc-dev linux-headers git
RUN mkdir -p /go/src/github.com/ethereum
WORKDIR /go/src/github.com/ethereum 
RUN git clone https://github.com/ethereum/go-ethereum.git
WORKDIR /go/src/github.com/ethereum/go-ethereum
RUN git checkout tags/v${GETH_VERSION}
RUN go build -ldflags="-w -s" -o /go/bin/geth cmd/geth/*.go
RUN go build -ldflags="-w -s" -o /go/bin/abigen cmd/abigen/*.go

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
RUN adduser -D solidity
USER solidity
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
USER root
COPY docker-zshrc /home/solidity/.zshrc
RUN touch /home/solidity/.z
RUN chown -R solidity:solidity /home/solidity/.zshrc /home/solidity/.z
RUN sed -i 's/\/bin\/ash/\/bin\/zsh/g' /etc/passwd
# copy geth, solc, abigen and other binaries
RUN apk --no-cache add z3-dev
COPY --from=geth /go/bin/geth /bin/geth
COPY --from=solc /go/bin/solc /bin/solc
COPY --from=geth /go/bin/abigen /bin/abigen
# expose ports
EXPOSE 8545/tcp
EXPOSE 8546/tcp
USER solidity
ENTRYPOINT [ "/bin/zsh" ]