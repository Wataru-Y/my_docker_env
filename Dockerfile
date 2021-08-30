ARG nvidia_cudagl_version=11.1.1-devel-ubuntu20.04
ARG python_version=3.8.2
#ARG zsh_theme=bureau

FROM nvidia/cudagl:${nvidia_cudagl_version}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y sudo

ARG DOCKER_UID=1000
ARG DOCKER_USER=amsl
ARG DOCKER_PASSWORD=docker
RUN useradd -m --uid ${DOCKER_UID} --groups sudo ${DOCKER_USER} \
  && echo ${DOCKER_USER}:${DOCKER_PASSWORD} | chpasswd

## [1] zsh (https://github.com/ohmyzsh/ohmyzsh)
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        git 
#SHELL ["/bin/zsh", "-c"]
#RUN wget http://github.com/ohmyzsh/ohmyzsh/raw/master/tools/install.sh -O - | zsh
#ARG zsh_theme
#ENV ZSH_THEME=${zsh_theme}
#RUN sed -i 's/robbyrussell/${ZSH_THEME}/' /home/amsl/.zshrc
#RUN sed -i 's/robbyrussell/${ZSH_THEME}/' /root/.zshrc
#ENV DISABLE_AUTO_UPDATE=true

# [2] pyenv (https://github.com/pyenv/pyenv/wiki/common-build-problems)
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        make \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
        python-openssl \
        git \
        python3-pip
#RUN curl https://pyenv.run | zsh && \
#    echo 'eval "$(pyenv init -)"' >> /root/.zshrc

#USER ${DOCKER_USER}

RUN git clone https://github.com/pyenv/pyenv.git /home/amsl/.pyenv

#RUN curl https://pyenv.run | bash && \
#    echo 'eval "$(pyenv init -)"' >> /home/amsl/.bashrc
ENV PATH=/home/amsl/.pyenv/shims:/home/amsl/.pyenv/bin:$PATH
#export PATH="$PYENV_ROOT/bin:$PATH"
#ENV PATH=/home/amsl/.pyenv/bin:$PATH
RUN echo 'eval "$(pyenv init -)"' >> /home/amsl/.bashrc && \
     eval "$(pyenv init -)"
RUN CFLAGS=-I/usr/include \
     LDFLAGS=-L/usr/lib
ARG python_version
ENV PYTHON_VERSION=${python_version}
RUN pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION}
#USER ${DOCKER_USER}
RUN pip install -U pip

#USER root

# X window and window manager
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xvfb \
        x11vnc \
        python-opengl \
        icewm \
        screen
COPY start_vnc.sh /home/amsl/

# clean cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ${DOCKER_USER}
WORKDIR /home/amsl/
#WORKDIR /root
CMD ["bash"]
