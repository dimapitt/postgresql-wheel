if [[ $1 =~ refs/tags/([0-9]+\.[0-9]+).*$ ]];
then
    VERSION=${BASH_REMATCH[1]}
    echo "Building ${VERSION}"
else
    VERSION=13.4
fi
JOBS_NUMBER=4
POSTGIS_VERSION=3.2.5dev

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y install zlib1g-dev libreadline-dev libossp-uuid-dev libxml2-dev \
                    libxslt1-dev curl make gcc pkg-config libgeos-dev libxml2-utils \
                    libjson-c-dev proj-bin g++ libsqlite3-dev libtiff-dev \
                    libcurl4-gnutls-dev libprotobuf-c-dev libgdal-dev libsfcgal-dev \
                    libproj-dev protobuf-c-compiler build-essential &&

# Build Postgresql
curl -L -O https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.gz
tar -xzf postgresql-${VERSION}.tar.gz
cd postgresql-${VERSION}
./configure --prefix=`pwd`/../src/postgresql --with-ossp-uuid --with-libxml --with-libxslt
make -j ${JOBS_NUMBER} world-bin
make install-world-bin
cd ..

# Build PostGIS
curl -L -O https://postgis.net/stuff/postgis-${POSTGIS_VERSION}.tar.gz
tar -xzvf postgis-${POSTGIS_VERSION}.tar.gz
cd postgis-${POSTGIS_VERSION}
./configure --with-pgconfig=`pwd`/../src/postgresql/bin/pg_config
make -j ${JOBS_NUMBER}
make install
cd ..
