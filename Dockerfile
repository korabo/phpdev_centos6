# https://kappariver.hatenablog.jp/entry/2018/08/12/000919
# https://qiita.com/bezeklik/items/9766003c19f9664602fe
# https://www.saintsouth.net/blog/update-libstdcpp-on-centos6/

FROM centos:centos6.10

LABEL MAINTAINER="S.TAKEUCHI(KRB/SPG)" version="1.1" updated="191024" containerid="centos-vsc"

ENV container docker

# RUN             PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
# RUN             yum update -y && yum clean all
#  extras  updates  centos-sclo-rh  centos-sclo-sclo  epel  remi-php56  remi-safe  Google:gcsfuse  stackdriver


# change repos to vault (IF in vault)
# https://qiita.com/Higemal/items/5949e9d807ac278fe228

# RUN cp -p /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo_bak \
#   && sed -i -e "s|mirror\.centos\.org/centos/\$releasever|vault\.centos\.org/6.10|g" /etc/yum.repos.d/CentOS-Base.repo \
#   && sed -i -e "s|#baseurl=|baseurl=|g" /etc/yum.repos.d/CentOS-Base.repo \
#   && sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-Base.repo

# Install Alt Repos

RUN yum makecache fast\
    && yum install -y \
        epel-release \
        http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
        centos-release-SCL \
        yum-utils \
        scl-utils \
    && yum clean all

# Install packages needed

RUN yum makecache fast\
    && yum install -y \
        expect ntp wget vim-common vim-enhanced vim-minimal unzip zip \
        vixie-cron sudo mailcap m4 autoconf automake make gcc rpm-build \
        subversion gcc-c++ iftop net-snmp net-snmp-utils rrdtool pciutils \
        bc screen nkf unzip unrar iftop lsof git hg \
    && yum clean all

RUN yum makecache fast\
    && yum install -y \
        libicu libtool-ltdl mcrypt unixODBC aspell net-snmp libtidy libxslt \
    && yum clean all


# httpd

RUN yum makecache fast\
    && yum install -y \
        httpd httpd-devel httpd-tools mod_ssl \
    && yum clean all


# MySQL5.6

RUN yum makecache fast\
    && yum install -y \
        mysql mysql-libs \
    && yum clean all


# PHP (remi-php56)

RUN yum makecache fast\
    && yum-config-manager --enable remi \
    && yum-config-manager --enable remi-php56 \
    && yum install -y \
        php php-cli php-common php-devel php-fedora-autoloader \
        php-gd php-mbstring php-mysqlnd php-opcache php-pdo \
        php-pear php-pecl-apcu php-pecl-imagick php-pecl-jsonc \
        php-pecl-jsonc-devel php-pecl-zip php-process php-tidy \
        php-xml php56-php-common php56-php-pecl-imagick php56-php-pecl-jsonc \
        php56-php-pecl-zip php56-runtime \
    && yum clean all

# Image Magic + JPeg

RUN yum makecache fast\
    && yum install -y \
        ImageMagick ImageMagick-devel \
        lcms2 openjpeg2 \
    && yum clean all


# Ghost Script

RUN yum makecache fast\
    && yum install -y \
        ghostscript ghostscript-devel ghostscript-fonts \
    && yum clean all


# Nfs, etc

RUN yum makecache fast\
    && yum install -y \
        nfs-utils nfs-utils-lib \
    && yum clean all

# Prepare directories, serivces

RUN  set -xeu && \
    mkdir -p /etc/skel/Maildir/{new,cur,tmp} && \
    mkdir -p /etc/skel/{public_html,logs,tmp} && \
    mkdir -p ~/Maildir/{new,cur,tmp} && \
    echo "SELINUX=disabled">/etc/sysconfig/selinux && \
    echo "SELINUXTYPE=targeted">>/etc/sysconfig/selinux && \
    echo "SETLOCALDEFS=0">>/etc/sysconfig/selinux && \
    chkconfig iptables off && \
    chkconfig httpd on && \
    chkconfig --add httpd

# # xdebug # #
# required-packages: php-pecl-apc php-devel gcc
RUN  pecl install xdebug-2.2.7

# for vscode extention
# GLIBC 3.4.15 yum install http://centos.biz.net.id/7/os/x86_64/Packages/libstdc++-4.8.5-28.el7.i686.rpm
# http://vault.centos.org/7.0.1406/os/x86_64/Packages/bash-4.2.45-5.el7.x86_64.rpm
# http://vault.centos.org/7.0.1406/os/x86_64/Packages/libstdc++-4.8.2-16.el7.x86_64.rpm
# http://vault.centos.org/7.0.1406/os/x86_64/Packages/glibc-2.17-55.el7.x86_64.rpm
# http://vault.centos.org/7.0.1406/os/x86_64/Packages/glibc-common-2.17-55.el7.x86_64.rpm
# rpm --nodeps -i --force libstdc++-4.8.2-16.el7.x86_64.rpm

RUN  cd /root && \
    curl -O http://vault.centos.org/7.0.1406/os/x86_64/Packages/libstdc++-4.8.2-16.el7.x86_64.rpm && \
    curl -O http://vault.centos.org/7.0.1406/os/x86_64/Packages/glibc-2.17-55.el7.x86_64.rpm && \
    curl -O http://vault.centos.org/7.0.1406/os/x86_64/Packages/glibc-common-2.17-55.el7.x86_64.rpm && \
    rpm --nodeps -i --force glibc-common-2.17-55.el7.x86_64.rpm glibc-2.17-55.el7.x86_64.rpm libstdc++-4.8.2-16.el7.x86_64.rpm

EXPOSE          80
EXPOSE          443

RUN  echo "<?php phpinfo(); ?>" > /var/www/html/index.php

ENTRYPOINT ["/bin/bash",  "-c", "service httpd restart; [ -t 1 ] && bash || sleep infinity"]
