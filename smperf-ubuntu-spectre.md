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
* fix (proposed, not GA yet) - kernel 4.4.0-112-generic

With the fix,  have
```
Spectre and Meltdown mitigation detection tool v0.27

Checking for vulnerabilities against live running kernel Linux 4.4.0-112-generic #135-Ubuntu SMP Fri Jan 19 11:48:36 UTC 2018 x86_64

CVE-2017-5753 [bounds check bypass] aka 'Spectre Variant 1'
* Checking count of LFENCE opcodes in kernel:  YES 
> STATUS:  NOT VULNERABLE  (115 opcodes found, which is >= 70, heuristic to be improved when official patches become available)

CVE-2017-5715 [branch target injection] aka 'Spectre Variant 2'
* Mitigation 1
*   Hardware (CPU microcode) support for mitigation:  YES 
*   Kernel support for IBRS:  YES 
*   IBRS enabled for Kernel space:  YES 
*   IBRS enabled for User space:  NO 
* Mitigation 2
*   Kernel compiled with retpoline option:  NO 
*   Kernel compiled with a retpoline-aware compiler:  NO 
> STATUS:  NOT VULNERABLE  (IBRS mitigates the vulnerability)

CVE-2017-5754 [rogue data cache load] aka 'Meltdown' aka 'Variant 3'
* Kernel supports Page Table Isolation (PTI):  YES 
* PTI enabled and active:  YES 
> STATUS:  NOT VULNERABLE  (PTI mitigates the vulnerability)

```

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

bp | workload | threads | tps no-fix | tps fix | ratio no-fix/fix 
---|----------|--------|------------|---------|-----------------
100|oltp_read_only|1|810.76|655.34|1.24
100|oltp_read_only|2|1589.66|1277.02|1.24
100|oltp_read_only|8|6233.69|5018.11|1.24
100|oltp_read_only|16|11253.28|9477.18|1.19
100|oltp_read_only|64|22702.29|18564.30|1.22
100|oltp_read_only|128|22281.22|18357.06|1.21
100|oltp_point_select|1|16095.32|12380.20|1.30
100|oltp_point_select|2|32665.97|24907.84|1.31
100|oltp_point_select|8|132480.34|101787.44|1.30
100|oltp_point_select|16|236832.94|189087.10|1.25
100|oltp_point_select|64|498322.41|415631.91|1.20
100|oltp_point_select|128|496661.65|414495.64|1.20

# buffer pool 50G
## connection via local socket

bp | workload | threads | tps no-fix | tps fix | ratio no-fix/fix 
---|----------|--------|------------|---------|-----------------
50|oltp_read_only|1|683.09|595.63|1.15
50|oltp_read_only|2|1390.70|1143.30|1.22
50|oltp_read_only|8|5262.02|4493.87|1.17
50|oltp_read_only|16|9842.04|8242.02|1.19
50|oltp_read_only|64|21021.20|17644.76|1.19
50|oltp_read_only|128|21526.21|17932.34|1.20
50|oltp_point_select|1|14535.73|11758.57|1.24
50|oltp_point_select|2|28721.43|23277.60|1.23
50|oltp_point_select|8|108422.96|90189.94|1.20
50|oltp_point_select|16|203876.31|167382.92|1.22
50|oltp_point_select|64|447757.48|376506.97|1.19
50|oltp_point_select|128|473894.73|384301.33|1.23

# buffer pool 25G
## connection via local socket

bp | workload | threads | tps no-fix | tps fix | ratio no-fix/fix 
---|----------|--------|------------|---------|-----------------
25|oltp_read_only|1|542.09|470.88|1.15
25|oltp_read_only|2|1074.54|931.02|1.15
25|oltp_read_only|8|4169.10|3621.79|1.15
25|oltp_read_only|16|7626.30|6716.29|1.14
25|oltp_read_only|64|18206.18|15702.90|1.16
25|oltp_read_only|128|20224.22|16966.13|1.19
25|oltp_point_select|1|11107.73|9294.73|1.20
25|oltp_point_select|2|22486.65|18526.84|1.21
25|oltp_point_select|8|86385.70|73226.44|1.18
25|oltp_point_select|16|161409.65|135689.48|1.19
25|oltp_point_select|64|370809.49|320848.79|1.16
25|oltp_point_select|128|433324.54|358947.61|1.21


