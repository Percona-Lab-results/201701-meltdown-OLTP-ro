for bp in 100 50 25
do
for i in 1 2 4 8 16 64 128 256 ; do ./parse.pl respar.db res-OLTP-RW-meltdown-network-4.9.62-21.56-oltp_read_only/mysql57-pareto.BP${bp}/thr$i/res.txt bp=${bp},kernel=4.9.62,workload=oltp_read_only ; done
done
