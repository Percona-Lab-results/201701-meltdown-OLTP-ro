# system

## CPU
* 2 x Intel(R) Xeon(R) CPU E5-2643 v2 @ 3.50GHz
* /proc/cpuinfo has 24 entries

## Server
Supermicro SC825TQ-R740LPB 2U

## Storage
* very fast PCIe Flash card

## CentOS 7.4
* no-fix - kernel 3.10.0-514.6.1.el7.x86_64
* fix - kernel 3.10.0-693.11.6.el7.x86_64 + microcode_ctl-2.1-22.2.el7.x86_64

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
* 64 tables, 10mln rows each
* datasize ~146GB

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

# in memory (buffer pool 200G)

| Threads | no-fix | fix | ratio no-fix/fix
|---------|--------|-----|----------------
|  1   | 881.87     | 892.33   | 0.99 
|  2   | 1733.15    | 1715.02  | 1.01 
|  4   | 3344.87    | 3299.46  | 1.01 
|  8   | 6275.43    | 6199.34  | 1.01 
|  16  | 10208.03   | 10006.03 | 1.02 
|  64  | 12531.92   | 12249.97 | 1.02 
|  128 | 11849.27   | 11870.70 | 1.00 
|  256 | 12305.5    | 12068.16 | 1.02 


# buffer pool 100G

 Threads | no-fix | fix | ratio no-fix/fix
---------|--------|-----|----------------
  1   | 524.63   | 521.96   | 1.01
  2   | 1027.61  | 1025.67  | 1.00
  4   | 2009.37  | 1987.23  | 1.01
  8   | 3752.05  | 3698.87  | 1.01
  16  | 6452.12  | 6370.77  | 1.01
  64  | 10508.43 | 10261.42 | 1.02
  128 | 9787.90  | 10158.86 | 0.96
  256 | 9821.94  | 9612.61  | 1.02


# buffer pool 50G

 Threads | no-fix | fix | ratio no-fix/fix
---------|--------|-----|----------------
  1   | 336.49  | 335.39  | 1.00   
  2   | 657.88  | 653.92  | 1.01   
  4   | 1274.54 | 1265.59 | 1.01    
  8   | 2369.01 | 2342.47 | 1.01    
  16  | 4145.79 | 4107.27 | 1.01    
  64  | 7982.03 | 7846.85 | 1.02    
  128 | 8493.85 | 8275.00 | 1.03    
  256 | 7574.23 | 8151.77 | 0.93    
  
# buffer pool 25G

Threads | no-fix | fix 
---------|--------|-----
  1   | 286.93  | 298.57
  2   | 559.91  | 591.30
  4   | 1082.12 | 1140.77
  8   | 2001.54 | 2052.33
  16  | 3481.70 | 3540.24
  64  | 6850.47 | 6672.06
  128 | 7666.29 | 7418.86
  256 | 7621.48 | 7510.59

