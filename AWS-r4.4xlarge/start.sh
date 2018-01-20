sync
sysctl -q -w vm.drop_caches=3
echo 3 > /proc/sys/vm/drop_caches
ulimit -n 1000000
numactl --interleave=all mysqld --defaults-file=/root/sysbench/cnf/my.cnf  --user=root
