CHANGE MASTER TO
  MASTER_HOST='mysql-master',
  MASTER_PORT=3306,
  MASTER_USER='repl',
  MASTER_PASSWORD='replpw',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=245;
START SLAVE;