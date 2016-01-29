# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:latest

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive

# Set the ENV variable to control plex's config directory
RUN echo /volumes/config > /etc/container_environment/PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR

# Download Plex Server
RUN curl -o /tmp/plex.deb -s https://d094b47584b89614f59f-d7ec5dd44c7e2bf2d2eb5be09fa8b339.ssl.cf1.rackcdn.com/plex_amd64.deb

RUN apt-get update -qq \
	&& dpkg -i /tmp/plex.deb \
	&& rm -f /tmp/plex.deb \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Data Storage & Permissions
RUN mkdir -p /volumes/config /volumes/data \
  	&& chown -R plex:plex /volumes

# Add plex to runit
RUN mkdir /etc/service/plex
ADD plex.sh /etc/service/plex/run
RUN chmod +x /etc/service/plex/run

# Modify default configurations
ADD default_settings /etc/default/plexmediaserver

# Enable SSH
# RUN rm -f /etc/service/sshd/down
# ADD id_rsa.pub /tmp/id_rsa.pub
# RUN cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && rm -f /tmp/id_rsa.pub
# EXPOSE 22

# Web Interface
EXPOSE 32400

# Path to a directory that only contains the nzbget.conf
VOLUME /volumes/config
VOLUME /volumes/data
