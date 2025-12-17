#!/bin/bash
systemctl stop apache2; systemctl start nginx; 
\cp ports.conf /etc/apache2; cp 000-default.conf /etc/apache2/sites-enabled; 
\cp index.html /var/www/html; systemctl start apache2; 
\systemctl restart prometheus-node-exporter; 
\cp jvm.options /etc/elasticsearch/jvm.options.d; cp elasticsearch.yml /etc/elasticsearch; 
\systemctl daemon-reload; systemctl enable --now elasticsearch.service; 
\cp kibana.yml /etc/kibana; systemctl daemon-reload; systemctl restart kibana; 
\cp logstash.yml /etc/logstash; cp logstash-nginx-es.conf /etc/logstash/conf.d; systemctl restart logstash.service; 
\cp filebeat.yml /etc/filebeat; systemctl restart filebeat; 
\cp mysqld.cnf /etc/mysql/mysql.conf.d; service mysql restart; 
\cp mysqldamp.sh /usr/local/bin; cp root /var/spool/cron/crontabs; ./script_replica.sh
