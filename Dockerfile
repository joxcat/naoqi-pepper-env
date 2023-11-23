FROM python:2.7-slim-buster

ENV HOME=/apps
ENV NAOQI_PEPPER_INSTALL_FOLDER=${HOME}/softbankRobotics
ARG DEPENDENCIES_FOLDER=/dependencies

# Create required folders
RUN mkdir -p \
    ${NAOQI_PEPPER_INSTALL_FOLDER} \
    ${DEPENDENCIES_FOLDER}

# Install OS dependencies
RUN apt update \
    && apt install -y curl supervisor nginx \
    && rm -rf /var/lib/apt/lists/*

# Get dependencies
COPY ./setup-scripts/vendor_deps.sh ${DEPENDENCIES_FOLDER}
COPY ./deps ${DEPENDENCIES_FOLDER}/deps
WORKDIR ${DEPENDENCIES_FOLDER}
RUN bash vendor_deps.sh --no-pack

WORKDIR ${HOME}

# Install naoqi SDK
RUN tar xvzf ${DEPENDENCIES_FOLDER}/deps/pynaoqi-python.tar.gz --directory ${NAOQI_PEPPER_INSTALL_FOLDER}
ENV PYTHONPATH="${PYTHONPATH}:${NAOQI_PEPPER_INSTALL_FOLDER}/pynaoqi-python2.7-2.5.5.5-linux64/lib/python2.7/site-packages"

# Install Choregraphe suite
RUN tar xvzf ${DEPENDENCIES_FOLDER}/deps/choregraphe-suite.tar.gz --directory ${NAOQI_PEPPER_INSTALL_FOLDER}
ENV PATH="${PATH}:${NAOQI_PEPPER_INSTALL_FOLDER}/choregraphe-suite-2.5.10.7-linux64/bin"

# Install qibullet
RUN tar xvzf ${DEPENDENCIES_FOLDER}/deps/qibullet-master.tar.gz --directory ${NAOQI_PEPPER_INSTALL_FOLDER}
RUN cd ${NAOQI_PEPPER_INSTALL_FOLDER}/qibullet-master \
    && sed -i 's|numpy|numpy==1.15|' setup.py \
    && python setup.py install
ENV PYTHONPATH="${PYTHONPATH}:${NAOQI_PEPPER_INSTALL_FOLDER}/qibullet-master"

# Install Python pepper kinematics
RUN tar xvzf ${DEPENDENCIES_FOLDER}/deps/python-pepper-kinematics.tar.gz --directory ${NAOQI_PEPPER_INSTALL_FOLDER}
RUN cd ${NAOQI_PEPPER_INSTALL_FOLDER}/python_pepper_kinematics-master \
    && python setup.py install
ENV PYTHONPATH="${PYTHONPATH}:${NAOQI_PEPPER_INSTALL_FOLDER}/python_pepper_kinematics-master"

# Install libqi-js
RUN tar xvzf ${DEPENDENCIES_FOLDER}/deps/libqi-js.tar.gz --directory ${NAOQI_PEPPER_INSTALL_FOLDER}

# Install naoqi tablet simulator
RUN tar xvzf ${DEPENDENCIES_FOLDER}/deps/naoqi-tablet-simulator.tar.gz --directory ${NAOQI_PEPPER_INSTALL_FOLDER}
COPY ./config/naoqi-tablet-simulator_config.yml ${NAOQI_PEPPER_INSTALL_FOLDER}/naoqi-tablet-simulator-master/config/config.yml
RUN sed -i "s|{{NAOQI_PEPPER_INSTALL_FOLDER}}|${NAOQI_PEPPER_INSTALL_FOLDER}|g" ${NAOQI_PEPPER_INSTALL_FOLDER}/naoqi-tablet-simulator-master/config/config.yml \
    && sed -i 's|QIMESSAGING_JSON_DIR="/path/to/libqi-js"|QIMESSAGING_JSON_DIR="'${NAOQI_PEPPER_INSTALL_FOLDER}'/libqi-js-master"|' ${NAOQI_PEPPER_INSTALL_FOLDER}/naoqi-tablet-simulator-master/launcher.sh \
    && sed -i 's|$QIMESSAGING_JSON_DIR|python $QIMESSAGING_JSON_DIR|' ${NAOQI_PEPPER_INSTALL_FOLDER}/naoqi-tablet-simulator-master/launcher.sh

# Install other python dependencies
RUN pip install \
    chardet==3.0.4 \
    urllib3==1.25.2 \
    requests==2.22.0 \
    cryptography \
    algorithmia==1.1.4 \
    tornado==3.2.2 \
    pyyaml \
    TornadIO2

# Bash styling
RUN echo 'PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ "' >> /etc/bash.bashrc

# Nginx
COPY ./config/nginx-naoqi.conf /etc/nginx-naoqi.conf
RUN sed -i "s|{{NAOQI_PEPPER_INSTALL_FOLDER}}|${NAOQI_PEPPER_INSTALL_FOLDER}|g" /etc/nginx-naoqi.conf

# Process management
RUN mkdir -p /var/log/supervisor
COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN sed -i "s|{{NAOQI_PEPPER_INSTALL_FOLDER}}|${NAOQI_PEPPER_INSTALL_FOLDER}|g" /etc/supervisor/conf.d/supervisord.conf
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf" ]