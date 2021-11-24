# Boxit - development box

FROM ubuntu:latest
LABEL maintainer="Ido Samuelson <ido.samuelson@gmail.com>"
ENV TZ="America/Chicago"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update -y && apt install -y lsb sudo build-essential pkg-config libssl-dev zsh mc git-all wget vim curl

#github cli
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    apt update \
    apt install gh

# create user
RUN adduser --quiet --disabled-password --shell /bin/zsh --home /home/devuser --gecos "User" devuser && \
    echo "devuser:dev1" | chpasswd && \
    usermod -aG sudo devuser
RUN adduser devuser sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#ADD scripts/installthemes.sh /home/devuser/installthemes.sh
USER devuser

# oh-my-zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)"
WORKDIR /home/devuser

COPY ./.zshrc ./
COPY ./.p10k.zsh ./

# rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH=".cargo/bin:${PATH}"
RUN env
RUN cargo install bandwhich bat lsd topgrade bottom jsonxf

ENV TERM xterm-256color

VOLUME ["/home/devuser/Code"]

CMD ["zsh"]
