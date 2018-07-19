#!/bin/sh

# 사용자 설정
ARCHIVE=mariadb-10.2.12-linux-x86_64.tar.gz
DBPW='kws123!@#'

# 환경변수
APPDIR=/usr/local
BASEDIR=$APPDIR/mysql
DATADIR=/home1/mysql
ARCHIVE_PREFIX=${ARCHIVE%.tar.gz*}

# 사용자 정보 생성
useradd -s /sbin/nologin --no-create-home mysql 2>&-

# 파일 복사
# rpm -ivh libaio-0.3.109-13.el7.x86_64.rpm
tar xfz $ARCHIVE -C $APPDIR
ln -s $APPDIR/${ARCHIVE_PREFIX}/ $BASEDIR
\cp my.cnf /etc/

# 디렉토리 권한 설정
cd $BASEDIR
chown -R mysql .
chgrp -R mysql .
scripts/mysql_install_db --user=mysql --basedir=$BASEDIR --datadir=$DATADIR --defaults-file=/etc/my.cnf
chown -R root .
chown -R mysql $DATADIR

# 서비스 파일 등록
\cp support-files/mysql.server /etc/init.d/mysql

# 실행파일 복사
\cp bin/* /usr/local/bin/

# 메뉴얼 파일 복사
\cp -R man/* /usr/local/share/man/

# 서비스 시작
service mysql start

# root 계정 비밀번호 설정
bin/mysqladmin -u root password "$DBPW"

# 서비스 등록
chkconfig --add mysql


# DB 설치
# 사용자 등록
# mysql -u root -p mysql
#
# >
#     create user 'kws'@'10.0.80.%' identified by 'kws123!@#';
#     grant all privileges on aptxsm.* to 'kws'@'10.0.80.%';
#     create user 'kws'@'localhost' identified by 'kws123!@#';
#     grant all privileges on aptxsm.* to 'kws'@'localhost';
#     flush privileges;
#
#     create user 'kws'@'%' identified by 'kws123!@#';
#     grant all privileges on aptxsm.* to 'kws'@'%';
#     create user 'kws'@'localhost' identified by 'kws123!@#';
#     grant all privileges on aptxsm.* to 'kws'@'localhost';
#     flush privileges;
#
