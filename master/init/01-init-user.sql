CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY 'replpw';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;