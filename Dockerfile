FROM jlesage/baseimage-gui:debian-12-v4

# 安装必要依赖
RUN apt update && apt install -y fonts-noto-cjk-extra wget libglib2.0-0 libatomic1 libtiff5-dev \
    libxcomposite1 libxrender1 libxrandr2 libxkbcommon-x11-0 libfontconfig1 libdbus-1-3 libnss3 libx11-xcb1 \
    libxcb-glx0 desktop-file-utils libxcb-randr0 libxcb-icccm4 libxcb-shm0 \
    libatk1.0-0 libatk-bridge2.0-0 libxdamage1 libxfixes3 libgbm1 libpango-1.0-0 libcairo2 libasound2 \
    libxcb-keysyms1 libxcb-randr0 libxcb-render0 libxcb-image0 libxcb-xfixes0 libxcb-shape0 libxcb-sync1 libxcb-render-util0

RUN wget -O libtiff5.deb https://security.debian.org/pool/updates/main/t/tiff/libtiff5_4.2.0-1+deb11u5_arm64.deb && \
    wget -O libwebp6.deb https://security.debian.org/pool/updates/main/libw/libwebp/libwebp6_0.6.1-2.1+deb11u2_arm64.deb && \
    dpkg -i libtiff5.deb libwebp6.deb && \
    rm libtiff5.deb libwebp6.deb

# 清理工作
RUN apt clean && rm -rf /var/lib/apt/lists/*

# 生成微信图标
RUN APP_ICON_URL=https://res.wx.qq.com/a/wx_fed/assets/res/NTI4MWU5.ico && \
    install_app_icon.sh "$APP_ICON_URL"

# 设置应用名称
RUN set-cont-env APP_NAME "Wechat"

RUN wget -O WeChatLinux_arm64.deb https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.deb && \
    dpkg -i WeChatLinux_arm64.deb && \
    rm WeChatLinux_arm64.deb

RUN echo '#!/bin/sh' > /startapp.sh && \
    echo 'exec /usr/bin/wechat' >> /startapp.sh && \
    chmod +x /startapp.sh

VOLUME /root/.xwechat
VOLUME /root/xwechat_files
VOLUME /root/downloads

# 配置微信版本号
RUN set-cont-env APP_VERSION "$(grep -o 'Unpacking wechat ([0-9.]*)' /tmp/wechat_install.log | sed 's/Unpacking wechat (\(.*\))/\1/')"
