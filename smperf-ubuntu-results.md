# system

## CPU
* 2 x Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz (Codename Haswell)
* /proc/cpuinfo has 48 entries

## Server
Supermicro Motherboard X10DRI

## Storage
* NVMi Intel DC 36000 

## Ubuntu 16.04
* no-fix - kernel  4.4.0-104-generic
* fix - kernel 4.4.0-108-generic

However, with the fix, I still have
```
# cat /sys/kernel/debug/x86/pti_enabled
cat: /sys/kernel/debug/x86/pti_enabled: No such file or directory
root@sm-perf01:~# cat /sys/kernel/debug/x86/ibpb_enabled
cat: /sys/kernel/debug/x86/ibpb_enabled: No such file or directory
root@sm-perf01:~# mount -t debugfs none /sys/kernel/debug/
mount: none is already mounted or /sys/kernel/debug busy
root@sm-perf01:~# cat /sys/kernel/debug/x86/ibrs_enabled
cat: /sys/kernel/debug/x86/ibrs_enabled: No such file or directory

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
https://github.com/Percona-Lab-results/201701-meltdown-OLTP-ro/blob/master/run_sysbench.sh


# results
* the results are in transactions per sec (more is better)

# in memory (buffer pool 100G)
## connection via local socket

threads | tps no-fix | tps fix | ratio no-fix/fix 
--------|------------|---------|-----------------
1|967.92|911.20|1.06
2|1804.79|1776.63|1.02
4|3601.12|3575.22|1.01
8|7025.68|6908.25|1.02
16|13121.80|12808.71|1.02
64|25711.85|24798.52|1.04
128|25035.37|24440.12|1.02
256|24501.57|23766.12|1.03

# buffer pool 50G
## connection via local socket

threads | tps no-fix | tps fix | ratio no-fix/fix 
--------|------------|---------|-----------------
1|487.30|457.37|1.07
2|960.97|955.99|1.01
4|1900.58|1864.12|1.02
8|3726.22|3628.85|1.03
16|7025.80|6981.11|1.01
64|17536.65|17147.05|1.02
128|20690.44|20312.74|1.02
256|21008.47|20580.03|1.02

# buffer pool 25G
## connection via local socket

threads | tps no-fix | tps fix | ratio no-fix/fix 
--------|------------|---------|-----------------
1|296.32|294.02|1.01
2|597.30|555.78|1.07
4|1167.02|1149.71|1.02
8|2219.55|2220.48|1.00
16|4172.11|4137.19|1.01
64|10098.34|10050.68|1.00
128|11361.70|11362.16|1.00
256|11454.57|11457.23|1.00

# in memory (buffer pool 100G)
## connection via tcp localhost 

threads | tps no-fix | tps fix | ratio no-fix/fix 
--------|------------|---------|-----------------
1|766.64|801.51|0.96
2|1519.51|1543.86|0.98
4|3184.74|3109.86|1.02
8|6198.99|6016.57|1.03
16|11181.19|10838.63|1.03
64|22502.97|21878.01|1.03
128|22048.03|21627.42|1.02
256|21605.72|21089.12|1.02

# buffer pool 50G
## connection via tcp localhost 
threads | tps no-fix | tps fix | ratio no-fix/fix 
--------|------------|---------|-----------------
1|442.99|428.01|1.03
2|899.01|879.05|1.02
4|1780.88|1719.86|1.04
8|3453.01|3324.49|1.04
16|6540.82|6385.55|1.02
64|16294.81|15868.40|1.03
128|18965.17|18491.31|1.03
256|19061.06|18548.72|1.03

# buffer pool 50G
## connection via tcp localhost 
threads | tps no-fix | tps fix | ratio no-fix/fix 
--------|------------|---------|-----------------
1|275.04|270.03|1.02
2|545.95|545.00|1.00
4|1095.99|1065.72|1.03
8|2112.91|2070.17|1.02
16|3977.02|3918.86|1.01
64|9937.52|9885.03|1.01
128|11348.92|11341.89|1.00
256|11460.59|11461.72|1.00


# point select, buffer pool 100GB, network = tcp connection
threads | tps no-fix | tps fix | ratio no-fix/fix 
--------|------------|---------|-----------------
8|133320.74|129939.92|1.03
16|237260.19|230735.43|1.03
64|494362.04|478426.57|1.03
128|493426.07|474064.87|1.04

# point select, buffer pool 50GB, network = tcp connection
threads | tps no-fix | tps fix | ratio no-fix/fix 
--------|------------|---------|-----------------
8|70395.28|68748.30|1.02
16|131885.68|130437.24|1.01
64|330001.99|320485.27|1.03
128|404435.95|391564.61|1.03

# point select, buffer pool 25GB, network = tcp connection
threads | tps no-fix | tps fix | ratio no-fix/fix 
--------|------------|---------|-----------------
8|41984.57|41722.68|1.01
16|78284.35|77235.30|1.01
64|195251.40|194190.85|1.01
128|220492.18|220502.14|1.00
