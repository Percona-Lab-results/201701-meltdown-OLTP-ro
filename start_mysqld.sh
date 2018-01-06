sync
sysctl -q -w vm.drop_caches=3
echo 3 > /proc/sys/vm/drop_caches
ulimit -n 1000000
numactl --interleave=all /opt/vadim/sysbench/Percona-Server-5.7.20-19-Linux.x86_64.ssl100/bin/mysqld --defaults-file=/opt/vadim/sysbench/cnf/my.cnf --basedir=/opt/vadim/sysbench/Percona-Server-5.7.20-19-Linux.x86_64.ssl100/ --user=root
