##
#  Generic dockerfile for dbt image building.
#  See README for operational details
##

# Top level build args
ARG build_for=linux/amd64

##
# base image (abstract)
##
FROM --platform=$build_for python:3.9.9-slim-bullseye as base

# N.B. The refs updated automagically every release via bumpversion
# N.B. dbt-postgres is currently found in the core codebase so a value of dbt-core@<some_version> is correct


# System setup
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    git \
    ssh-client \
    software-properties-common \
    make \
    build-essential \
    ca-certificates \
    libpq-dev \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Env vars
ENV PYTHONIOENCODING=utf-8
ENV LANG=C.UTF-8

# Update python
RUN python -m pip install --upgrade pip setuptools wheel --no-cache-dir

# Set docker basics
WORKDIR /usr/app/dbt/
VOLUME /usr/app
ENTRYPOINT ["dbt"]

##
# dbt-core
##
FROM base as dbt-core
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/dbt-core@v1.0.1#egg=dbt-core&subdirectory=core"

##
# dbt-postgres
##
FROM base as dbt-postgres
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/dbt-core@v1.0.1#egg=dbt-postgres&subdirectory=plugins/postgres"


##
# dbt-redshift
##
FROM base as dbt-redshift
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/dbt-redshift@v1.0.0#egg=dbt-redshift"


##
# dbt-bigquery
##
FROM base as dbt-bigquery
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/dbt-bigquery@v1.0.0#egg=dbt-bigquery"


##
# dbt-snowflake
##
FROM base as dbt-snowflake
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/dbt-snowflake@v1.0.0#egg=dbt-snowflake"

##
# dbt-spark
##
FROM base as dbt-spark
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    python-dev \
    libsasl2-dev \
    gcc \
    unixodbc-dev \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/dbt-spark@v1.0.0#egg=dbt-spark[all]"


##
# dbt-third-party
##
#FROM dbt-core as dbt-third-party
#RUN python -m pip install --no-cache-dir "${dbt_third_party}"

##
# dbt-all
##
FROM base as dbt-all
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    python-dev \
    libsasl2-dev \
    gcc \
    unixodbc-dev \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*
  RUN python -m pip install --no-cache "git+https://github.com/dbt-labs/dbt-redshift@v1.0.0#egg=dbt-redshift"
  RUN python -m pip install --no-cache "git+https://github.com/dbt-labs/dbt-dbt-bigquery@v1.0.0#egg=dbt-bigquery"
  RUN python -m pip install --no-cache "git+https://github.com/dbt-labs/dbt-snowflake@v1.0.0#egg=dbt-snowflake"
  RUN python -m pip install --no-cache "git+https://github.com/dbt-labs/dbt-spark@v1.0.0#egg=dbt-spark[all]"
  RUN python -m pip install --no-cache "git+https://github.com/dbt-labs/dbt-core@v1.0.1#egg=dbt-postgres&subdirectory=plugins/postgres"
