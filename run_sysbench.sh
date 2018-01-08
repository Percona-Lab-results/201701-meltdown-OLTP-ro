#HOST="--mysql-socket=/tmp/mysql.sock"
HOST="--mysql-host=127.0.0.1"
MYSQLDIR=/opt/vadim/sysbench/Percona-Server-5.7.20-19-Linux.x86_64.ssl100
DATADIR=/mnt/nvmi/sysbench
CONFIG=/opt/vadim/sysbench/cnf/my.cnf

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

startmysql(){
  pushd $MYSQLDIR
  sync
  sysctl -q -w vm.drop_caches=3
  echo 3 > /proc/sys/vm/drop_caches
  ulimit -n 1000000
  numactl --interleave=all bin/mysqld --defaults-file=$CONFIG --datadir=$DATADIR --basedir=$PWD --user=root --ssl=0 --log-error=$DATADIR/error.log --innodb-buffer-pool-size=${BP}G
}

shutdownmysql(){
  echo "Shutting mysqld down..."
  $MYSQLDIR/bin/mysqladmin shutdown -S /tmp/mysql.sock
}

waitmysql(){
        set +e

        while true;
        do
                $MYSQLDIR/bin/mysql -Bse "SELECT 1" mysql

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
  $MYSQLDIR/bin/mysqladmin ext -i10 > $OUTDIR/mysqladminext.txt &
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

runid="mysql57-104.BP$BP"

# perform warmup
sysbench oltp_read_only --tables=32 --table_size=10000000 --threads=100 $HOST --mysql-user=root --time=600 --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off run | tee -a  res.warmup.ro.txt

for i in 1 2 4 8 16 64 128 256
do

        OUTDIR=res-OLTP-meltdown-network/$runid/thr$i
        mkdir -p $OUTDIR

        # start stats collection
        initialstat
        collect_dstat_stats 

        time=300
        sysbench oltp_read_only --tables=32 --table_size=10000000 --threads=$i $HOST --mysql-user=root --time=$time --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off run | tee -a $OUTDIR/res.txt

        # kill stats
        set +e
        kill $PIDDSTATSTAT
        set -e

        sleep 30
done

shutdownmysql

done
