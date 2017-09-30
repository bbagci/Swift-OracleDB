# Swift-OracleDB Installation

## 0. Anforderung

* Ubuntu 16.04 LTS x64
* Oracle Account

## 1. Vorbereitung

1. Ubuntu 16.04 auf den aktuellen Stand bringen:
    ```bash
    apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade && apt-get -y clean
    shutdown -r now
    ```
2. Swift (<https://swift.org/download/#releases>) für Ubuntu 16.04 herunterladen.
3. Von der GitHub Webseite (<https://github.com/vrogier/ocilib/releases/latest>) das OCILIB (`ocilib-*-gnu.tar.gz`) herunterladen.
4. Mithilfe des Oracle Accounts von der Oracle Webseite (<http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html>) das Instant Client Package - Basic (`instantclient-basic-linux.x64-*.zip`) und das Instant Client Package - SDK (`instantclient-sdk-linux.x64-*.zip`) herunterladen.

## 2. Installation von Swift

Im Download-Ordner:

```bash
apt-get install -y clang libicu-dev
tar -xzf $(find swift-*-RELEASE-ubuntu16.04.tar.gz)
cd swift-*-RELEASE-ubuntu16.04/usr
cp -R ./* /usr/
```

## 3. Installation der Oracle Instant Client Packages

Im Download-Ordner:

```bash
apt-get install -y unzip libaio1
unzip $(find instantclient-basic-linux.x64-*.zip)
unzip $(find instantclient-sdk-linux.x64-*.zip)
mkdir /opt/oracle
mv ./instantclient_* /opt/oracle/instantclient
cd /opt/oracle/instantclient
ln -s libclntsh.so.* libclntsh.so
ln -s libocci.so.* libocci.so
echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf
ldconfig
export OCI_LIB_DIR=/opt/oracle/instantclient
export OCI_INC_DIR=/opt/oracle/instantclient/sdk/include
```

## 4. Installation von OCILIB

Im Download-Ordner:

```bash
apt-get install -y build-essential
tar -xzf $(find ocilib-*-gnu.tar.gz)
cd ocilib-*
./configure --with-oracle-headers-path=/opt/oracle/instantclient/sdk/include --with-oracle-lib-path=/opt/oracle/instantclient
make
make install
```