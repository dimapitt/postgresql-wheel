if [[ $1 =~ refs/tags/([0-9]+\.[0-9]+).*$ ]];
then
    VERSION=${BASH_REMATCH[1]}
    echo "Building ${VERSION}"
else
    VERSION=13.4
fi
POSTGIS_VERSION=3.2.5dev

yum install -y dnf-plugins-core epel-release
yum config-manager --set-enabled powertools
yum install -y zlib-devel readline-devel uuid-devel libxml2-devel libxslt-devel
curl -L -O https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.gz

tar -xzf postgresql-${VERSION}.tar.gz
cd postgresql-${VERSION}
./configure --prefix=`pwd`/../src/postgresql --with-ossp-uuid --with-libxml --with-libxslt
make -j 4 world-bin
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