#!/bin/bash

rm -rf ./clidriver/*
rm ./IBM.Data.DB2.Core.dll
cp -a ./IBM.Data.DB2.Core-lnx/build/clidriver/. ./clidriver/
cp -f ./IBM.Data.DB2.Core-lnx/lib/netstandard2.0/IBM.Data.DB2.Core.dll ./IBM.Data.DB2.Core.dll

echo "##vso[task.setvariable variable=PATH]$PATH:$PWD/clidriver/bin:$PWD/clidriver/lib"
echo "##vso[task.setvariable variable=LD_LIBRARY_PATH]$PWD/clidriver/lib/"

docker run -d --name informix -e LICENSE=ACCEPT --privileged -it -p 9089:9089 ibmcom/informix-developer-database:12.10.FC12W1DE


docker ps -a

retries=0
status="1"
until docker logs informix | grep -q 'Informix container login Information'; do
    sleep 5
    retries=`expr $retries + 1`
    echo waiting for informix to start
    if [ $retries -gt 100 ]; then
        echo informix not started or takes too long to start
        exit 1
    fi;
done

docker ps -a

docker start informix

docker ps -a

echo Generate CREATE DATABASE script
cat <<-EOSQL > linq2db.sql
CREATE DATABASE testdb WITH BUFFERED LOG
EOSQL
docker cp linq2db.sql informix:/opt/ibm/data/linq2db.sql
docker exec informix dbaccess sysadmin /opt/ibm/data/linq2db.sql

docker logs informix

