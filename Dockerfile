FROM ricwang/docker-wechat:base

ARG TARGETPLATFORM

# 根据平台下载对应的微信安装包
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        curl -O "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.deb"; \
    else \
        curl -O "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"; \
    fi && \
    dpkg -i WeChatLinux_*.deb 2>&1 | tee /tmp/wechat_install.log && \
    rm WeChatLinux_*.deb

RUN echo '#!/bin/sh' > /startapp.sh && \
    echo 'exec /usr/bin/wechat' >> /startapp.sh && \
    chmod +x /startapp.sh

VOLUME /root/.xwechat
VOLUME /root/xwechat_files
VOLUME /root/downloads

# 配置微信版本号
RUN set-cont-env APP_VERSION "$(grep -o 'Unpacking wechat ([0-9.]*)' /tmp/wechat_install.log | sed 's/Unpacking wechat (\(.*\))/\1/')"
