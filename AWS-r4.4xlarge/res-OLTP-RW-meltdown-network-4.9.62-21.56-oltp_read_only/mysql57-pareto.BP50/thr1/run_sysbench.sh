#HOST="--mysql-socket=/tmp/mysql.sock"
HOST="--mysql-host=127.0.0.1"
MYSQLDIR=/opt/vadim/sysbench/Percona-Server-5.7.20-19-Linux.x86_64.ssl100
DATADIR=/data/mysql
CONFIG=/root/sysbench/cnf/my.cnf
TEST=oltp_read_only

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

startmysql(){
  sync
  sysctl -q -w vm.drop_caches=3
  echo 3 > /proc/sys/vm/drop_caches
  ulimit -n 1000000
  numactl --interleave=all mysqld --defaults-file=$CONFIG --datadir=$DATADIR --basedir=$PWD --user=root --ssl=0 --log-error=$DATADIR/error.log --innodb-buffer-pool-size=${BP}G
}

shutdownmysql(){
  echo "Shutting mysqld down..."
  mysqladmin shutdown 
}

waitmysql(){
        set +e

        while true;
        do
                mysql -Bse "SELECT 1" mysql

                if [ "$?" -eq 0 ]
                then
                        break
                fi

                sleep 30

                echo -n "."
        done
        set -e
}

initialstat(){
  cp $CONFIG $OUTDIR
  cp $0 $OUTDIR
}

collect_mysql_stats(){
  mysqladmin ext -i10 > $OUTDIR/mysqladminext.txt &
  PIDMYSQLSTAT=$!
}
collect_dstat_stats(){
  vmstat 1 > $OUTDIR/vmstat.out &
  PIDDSTATSTAT=$!
}


# cycle by buffer pool size

for BP in 100 50 25
do

startmysql &
sleep 10
waitmysql

runid="mysql57-pareto.BP$BP"

# perform warmup
sysbench oltp_read_only --tables=32 --table_size=10000000 --threads=100 $HOST --mysql-user=root --time=900 --max-requests=0 --report-interval=1 --rand-type=pareto --mysql-db=sbtest --mysql-ssl=off run | tee -a  res.warmup.ro.txt

for i in  1 2 8 16 64 128 
#for i in 1 2 4 8 16 64 128 256
do

        OUTDIR=res-OLTP-RW-meltdown-network-4.4.0-111-$TEST/$runid/thr$i
        mkdir -p $OUTDIR

        # start stats collection
        initialstat
        collect_dstat_stats 

        time=900
        sysbench $TEST --tables=32 --table_size=10000000 --threads=$i $HOST --mysql-user=root --time=$time --max-requests=0 --report-interval=1 --rand-type=pareto --mysql-db=sbtest --mysql-ssl=off run | tee -a $OUTDIR/res.txt

        # kill stats
        set +e
        kill $PIDDSTATSTAT
        set -e

        sleep 30
done

shutdownmysql

done
