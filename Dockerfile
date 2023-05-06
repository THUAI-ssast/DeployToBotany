FROM ubuntu:22.04

# 更新软件包并安装必要的依赖
RUN echo "\
    # 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释\n\
    deb [trusted=yes] http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse\n\
    # deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse\n\
    deb [trusted=yes] http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse\n\
    # deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse\n\
    deb [trusted=yes] http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse\
    # deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse\n\
    \n\
    deb [trusted=yes] http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse\n\
    # deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse\n\
    \n\
    # deb [trusted=yes] http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse\n\
    # # deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse\n\
    \n\
    # 预发布软件源，不建议启用\n\
    # deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse\n\
    # # deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse\n\
    " > /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    gcc \
    make \
    libc-dev \
    libcap-dev \
    bash \
    g++ \
    lua5.4 \
    liblua5.4-dev \
    python3 \
    libhiredis-dev \
    libb2-dev \
    curl \
    git

# 安装 pwsh
RUN apt-get install -y wget apt-transport-https software-properties-common && \
    wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell && \
    rm packages-microsoft-prod.deb

# 设置工作目录
WORKDIR /app

COPY . .

# 编译和安装 isolate
RUN cd /app/isolate && \
    make isolate && \
    make install && \
    cd /app/judge && \
    ./build.sh && \
    isolate --init


# 启动命令（根据您的项目需求自定义）
WORKDIR /app/judge
ENV REDIS_ADDR=redis
ENV REDIS_PORT=6379
ENV API_ROOT=http://botany:3434/api
ENV API_SIGKEY=aha
ENTRYPOINT "./a.out" -i 1 -d / -a "$REDIS_ADDR" -s "$API_ROOT" -k "$API_SIGKEY"