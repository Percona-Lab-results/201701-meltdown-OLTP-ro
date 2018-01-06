ulimit -n 100000
HOST="--mysql-socket=/tmp/mysql.sock"
sysbench oltp_read_only --tables=32 --table_size=10000000 --threads=100 $HOST --mysql-user=root --time=300 --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off run | tee -a res.warmup.ro.txt
OUT="res.ps57-inmem"
DIR="res-OLTP/$OUT"
mkdir -p $DIR
#for i in 1 2 3 4 5 6 8 10 13 16 20 25 31 38 46 56 68 82 100 120 145 175 210 250 300 360 430 520 630 750 870 1000
for i in 1 2 4 8 16 64 128 256
do
time=300
sysbench oltp_read_only --tables=32 --table_size=10000000 --threads=$i $HOST --mysql-user=root --time=$time --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off run | tee -a $DIR/res.thr${i}.txt
#./sysbench --forced-shutdown=1 --test=tests/db/oltp.lua --oltp_tables_count=10 --oltp_table_size=10000000 --num-threads=${i} $HOST --mysql-user=sbtest --mysql-password=sbtest --mysql-db=sbtest10t --oltp-read-only=off --max-time=$time --max-requests=0 --report-interval=10 --rand-type=pareto --rand-init=on --mysql-ssl=off run | tee -a $DIR/res.thr${i}.txt
sleep 30
done
