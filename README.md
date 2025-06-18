# mysql-replication
MySQL 8.0 기반 데이터베이스 복제와 GTID mode 실습

`docker-entrypoint-initdb.d`에서 User 생성, 권한 부여, 복제 구성 설정 등을 자동화하고 있습니다.


- `01-init-user.sql` : 복제를 담당할 User 생성 및 권한 부여 (Master Node)
- `02-configure-replication.sql` : Slave Node에서 실행될 복제 구성

<br>

## 📁 디렉토리 구조

```plaintext
.
├── README.md
├── master/
│   ├── init/
│   │   └── 01-init-user.sql
│   └── my.cnf
├── slave/
│   ├── init/
│   │   └── 02-configure-replication.sql
│   └── my.cnf
├── docker-compose.yml

```

<br>

## MySQL 8.0 복제(Replication)

### 1. Docker-compose 실행

```
    docker-compose up -d
```

- `mysql-master` port: 3307
- `mysql-slave` port: 3308

<br>

### 3. Master Node의 상태 확인

```
docker exec -it mysql-master mysql -uroot -prootpw -e "SHOW MASTER STATUS\G"
```

- `File`, `Position` 값을 복제 구성에서 설정

<br>

### 4. Master Node 덤프 파일 생성 및 Slave 복원

```
docker exec mysql-master sh -c "mysqldump -uroot -prootpw --all-databases --master-data=2" > dbdump.sql
docker cp dbdump.sql mysql-slave:/dbdump.sql
docker exec -i mysql-slave mysql -uroot -prootpw < /dbdump.sql
```

<br>

### 5. Slave Node의 복제 구성

```
docker exec -it mysql-slave mysql -uroot -prootpw -e "
CHANGE MASTER TO
  MASTER_HOST='mysql-master',
  MASTER_PORT=3306,
  MASTER_USER='repl',
  MASTER_PASSWORD='replpw',
  MASTER_LOG_FILE=,
  MASTER_LOG_POS=;
START SLAVE;"
```

- `MASTER_LOG_FILE`, `MASTER_LOG_POS`는 3번 항목에서 진행한대로, `SHOW MASTER STATUS`를 통해서 실제 자동 생성된 로그 파일 이름을 확인해야한다.

<br>


### 6. 복제(Replication) 확인

```
docker exec -it mysql-slave mysql -uroot -prootpw -e "SHOW SLAVE STATUS\G"
```

- `Slave_IO_Running`, `Slave_SQL_Running`이 Yes인지 확인

<br>

<br>

## GTID 기반 복제(Replication)

gtid 브랜치에서 `my.cnf` 변경사항 확인하기

<br>

### Slave Node의 복제 구성에서 변경 사항 적용하기

```
CHANGE MASTER TO
  MASTER_HOST='mysql-master',
  MASTER_USER='repl',
  MASTER_PASSWORD='replpw',
  MASTER_AUTO_POSITION = 1;
START SLAVE;

```

덤프 파일만 잘 옮기면 나머지 Log Position 계산 없이 자동으로 동기화된다.


