FROM debian:buster
RUN apt-get update

RUN mkdir /GeoNature
WORKDIR /GeoNature

# Install apt packages
COPY apt-packages.txt /GeoNature
RUN xargs apt-get install -y <apt-packages.txt

# Install python packages
RUN mkdir /GeoNature/backend
RUN mkdir -p /GeoNature/contrib/gn_module_import/backend
RUN mkdir -p /GeoNature/contrib/gn_module_export/backend
COPY backend/requirements.txt /GeoNature/backend
COPY backend/requirements-common.txt /GeoNature/backend
#COPY contrib/gn_module_export/backend/requirements.txt /GeoNature/contrib/gn_module_export/backend
#COPY contrib/gn_module_import/backend/requirements.txt /GeoNature/contrib/gn_module_import/backend
RUN pip3 install --upgrade pip
RUN pip3 install -r backend/requirements.txt
#RUN pip3 install -r contrib/gn_module_import/backend/requirements.txt
#RUN pip3 install -r contrib/gn_module_export/backend/requirements.txt


RUN echo "Europe/P" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# nb_NO.UTF-8 UTF-8/nb_NO.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="nb_NO.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=nb_NO.UTF-8 \
RUN export LC_ALL=fr_FR.UTF-8
RUN export LANGUAGE=fr_FR.UTF-8
RUN export LANG=fr_FR.UTF-8

#Install frontend dependences

COPY . /GeoNature/
COPY ./install/install_all/install_all.ini /GeoNature
COPY ./install/install_all/install_all.sh /GeoNature


ENTRYPOINT ["sh", "entrypoint.sh"]
EXPOSE 80
