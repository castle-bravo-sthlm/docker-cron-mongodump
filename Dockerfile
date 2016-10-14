#
# The ENTRYPOINT from parent image will run everything in the directory docker-entrypoint.d before executing CMD
#
# Everything in directory ./cronjobs will be added as cronjobs
# Everything in ./scripts vill be available at /scripts
#

FROM castlebravo/docker-cron:onbuild

ENV GPG_KEYS \
	DFFA3DCF326E302C4787673A01C4E7FAAAB2461C \
	42F3E95A2C4F08279C4960ADD68FA50FEA312927
RUN set -ex \
	&& for key in $GPG_KEYS; do \
		apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

ENV MONGO_VERSION 3.2

ENV CRON_SCHEDULE "0 * * * *"

RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/$MONGO_VERSION main" > /etc/apt/sources.list.d/mongodb-org.list
RUN apt-get update && apt-get install -y \
  mongodb-org-tools \
  && rm -rf /var/lib/apt/lists/*
