# Percona MySQL Install for 8

## MySQL
```
curl -sL https://raw.githubusercontent.com/Renbull1994/Percona-MySQL-Install/main/Install.sh >> install.sh | chmod +x install.sh
```

```
Usage:
        /bin/bash install.sh [options] 
    Options:
        -i8  [port]   Install mysql 8.0.x with port , ex: /bin/bash install.sh -i8 6603
        -i8x [port]   Install mysql 8.3.x with port , ex: /bin/bash install.sh -i8x 6603
        -help       Help document
```

## Xtrabackup
```
curl -sL https://raw.githubusercontent.com/Renbull1994/Percona-MySQL-Install/main/xtrabackup.sh >> xtrabackup.sh | chmod +x xtrabackup.sh
```

```
Usage:
        /bin/bash xtrabackup.sh [options] | [--exclude] Options::
    Options:
        all [port]  | Backup mysql with port number, ex: /bin/bash xtrabackup.sh all 6603 
        help        | Help document
```
