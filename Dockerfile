FROM registry.access.redhat.com/rhscl/python-27-rhel7


ENV ELASTALERT_VERSION=v0.2.1

# Elastalert rules directory.
ENV ELASTALERT_HOME=/opt/elastalert
ENV RULES_DIRECTORY=$ELASTALERT_HOME/rules
ENV CONFIG_DIRECTORY=$ELASTALERT_HOME/config

USER root

RUN INSTALL_PKGS="python-devel python-setuptools net-tools " && \
    yum -y --disablerepo=* --enablerepo=rhel-7-server-rpms --enablerepo=rhel-server-rhscl-7-rpms install ${INSTALL_PKGS} && \
    yum -y update && \
    yum -q clean all

RUN cd $HOME

RUN wget https://github.com/Yelp/elastalert/archive/${ELASTALERT_VERSION}.tar.gz -O elastalert-${ELASTALERT_VERSION}.tar.gz


RUN ls -l && pwd

RUN tar xvf elastalert-${ELASTALERT_VERSION}.tar.gz

RUN ls -l

# Copy config
COPY configuration/run.sh $ELASTALERT_HOME/run.sh

# Create default user and change ownership of files
RUN useradd -u 1000 -r -g 0 -m -d $HOME -s /sbin/nologin -c "elastalert user" elastalert && \
    cp -r /etc/skel/. $HOME && \
    chown -R elastalert:0 $HOME && \
    fix-permissions $HOME && \
    fix-permissions /opt/app-root

# Create dirs
RUN chmod +x $ELASTALERT_HOME/run.sh && \
    ln -s $ELASTALERT_HOME/run.sh $HOME/run.sh && \
    mkdir $ELASTALERT_HOME/rules && \
    mkdir $ELASTALERT_HOME/config

VOLUME $RULES_DIRECTORY

VOLUME $CONFIG_DIRECTORY

# Install workaround
RUN . /opt/app-root/etc/scl_enable && \
    pip install --upgrade pip && \
    pip install --upgrade setuptools && \
    pip install elastalert

# switch to elastalert
USER 1000

ENTRYPOINT ["/opt/app-root/src/run.sh"]