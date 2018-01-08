# system

## CPU
* 2 x Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
* /proc/cpuinfo has 48 entries

## Server
Supermicro SC825TQ-R740LPB 2U

## Storage
* NVMi Intel DC 36000 

## Ubuntu 16.04
* no-fix - kernel  4.4.0-104-generic
* fix - kernel 

However, with the fix, I still have
```
# cat /sys/kernel/debug/x86/pti_enabled
1
# cat /sys/kernel/debug/x86/ibpb_enabled
0
# cat /sys/kernel/debug/x86/ibrs_enabled
0
```
The checker https://github.com/raphaelsc/Am-I-affected-by-Meltdown
reports that the system with "no-fix" is affected and the system with "fix" IS NOT affected

# Workload
* sysbench 1.0.11 oltp_read_only
* 32 tables, 10mln rows each
* datasize ~73GB

# Server
* Percona-Server-5.7.20-19-Linux.x86_64 binary distribution
* config https://github.com/Percona-Lab-results/201701-meltdown-OLTP-ro/blob/master/my.cnf

# sysbench script
```
ulimit -n 100000
HOST="--mysql-socket=/tmp/mysql.sock"
sysbench oltp_read_only --tables=64 --table_size=10000000 --threads=100 $HOST --mysql-user=root --time=300 --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off run | tee -a res.warmup.ro.txt
OUT="res.ps57-inmem"
DIR="res-OLTP/$OUT"
mkdir -p $DIR
for i in 1 2 4 8 16 64 128 256
do
time=300
sysbench oltp_read_only --tables=64 --table_size=10000000 --threads=$i $HOST --mysql-user=root --time=$time --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off run | tee -a $DIR/res.thr${i}.txt
sleep 30
done
```


# results
* the results are in transactions per sec (more is better)

# in memory (buffer pool 100G)



