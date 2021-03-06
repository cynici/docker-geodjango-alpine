#!/bin/sh

set -e # fail on any error


# Versions
# ===================================================================
GEOS_VERSION=3.4.2
PROJ_VERSION=4.9.2
PROJ_DATUMGRID_VERSION=1.5
GDAL_VERSION=1.11.2

# The Django 1.11.x series is the last to support Python 2.7.
# https://docs.djangoproject.com/en/2.0/releases/2.0/
DJANGO_VERSION=1.11


# Install build packages
# ===================================================================
PACKAGES="make g++ python-dev postgresql-dev"
apk --update add ${PACKAGES}


# Install geos
# ===================================================================
cd /tmp
wget http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2
tar xjf geos-${GEOS_VERSION}.tar.bz2
cd geos-${GEOS_VERSION}
./configure --enable-silent-rules CFLAGS="-D__sun -D__GNUC__"  CXXFLAGS="-D__GNUC___ -D__sun"
make -s
make -s install


# Install proj
# ===================================================================
cd /tmp
wget http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz
wget http://download.osgeo.org/proj/proj-datumgrid-${PROJ_DATUMGRID_VERSION}.tar.gz
tar xzf proj-${PROJ_VERSION}.tar.gz
cd proj-${PROJ_VERSION}/nad
tar xzf ../../proj-datumgrid-${PROJ_DATUMGRID_VERSION}.tar.gz
cd ..
./configure --enable-silent-rules
make -s
make -s install


# Install gdal
# ===================================================================
cd /tmp
wget http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz
tar xzf gdal-${GDAL_VERSION}.tar.gz
cd gdal-${GDAL_VERSION}
./configure --enable-silent-rules --with-static-proj4=/usr/local/lib
make -s
make -s install


# Install django and database packages
# ===================================================================
apk add py-mysqldb
pip install --no-cache-dir django==$DJANGO_VERSION psycopg2 PyMySQL
pip install --no-cache-dir raven --upgrade


# Clean up packages
# ===================================================================
apk del ${PACKAGES}
apk add tzdata libpq libstdc++


# Clean up
# ===================================================================
rm -rf /tmp/*
rm -rf /var/cache/apk/*
rm -r /root/.cache
