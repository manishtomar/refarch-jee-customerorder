#!/bin/bash

set -ex

function connstring() {
	host="$1"
	db="$2"
	echo "database=$db;hostname=$host;port=50000;uid=db2inst1;pwd=password"
}

function wait_for_db2() {
	host="$1"
	db="$2"
	conn=$(connstring $host $db)
	sqlcmd='"select SCHEMANAME from syscat.schemata limit 1"'
	cmd="echo $sqlcmd | ./db2cli execsql -inputsql /dev/stdin -connstring \"$conn\""
	until eval $cmd | grep "FetchAll: 1 rows fetched."; do
		echo "$db on $host unavailable. sleeping for 1s"
		sleep 1
	done
}

cd /opt/ibm/odbc_cli/clidriver/bin
wait_for_db2 db2_order ORDERDB
wait_for_db2 db2_inventory INDB
conn=$(connstring db2_order ORDERDB)
./db2cli execsql -inputsql /config/createOrderDB.sql -statementdelimiter ';' -connstring $conn
./db2cli execsql -inputsql /config/initialDataSet.sql -statementdelimiter ';' -connstring $conn
conn=$(connstring db2_inventory INDB)
./db2cli execsql -inputsql /config/InventoryDdl.sql -statementdelimiter ';' -connstring $conn
./db2cli execsql -inputsql /config/InventoryData.sql -statementdelimiter ';' -connstring $conn

exec "$@"
