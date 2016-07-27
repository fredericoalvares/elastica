worker_processes  @@@PROCESSES@@@;

events {
    worker_connections  15000;
    multi_accept        on;
    use                 epoll;
}

worker_rlimit_nofile 65535; 

http {
   
    sendfile           on;
    tcp_nopush         on;
    tcp_nodelay        on;
    keepalive_timeout  128;
 
    upstream lbworkers {    
        @@@WORKERS@@@
	keepalive 32;
    }

    log_format logstash '{ "@timestamp": "$time_iso8601", '
                         '"remote_addr": "$remote_addr", '
                         '"remote_user": "$remote_user", '
                         '"body_bytes_sent": "$body_bytes_sent", '
                         '"request_time": $request_time, '
                         '"status": "$status", '
                         '"request": "$request", '
                         '"request_method": "$request_method", '
                         '"http_referrer": "$http_referer", '
                         '"http_user_agent": "$http_user_agent", '
                         '"mode": "$upstream_http_mode" }';
  

    access_log /root/access_nginx.log logstash;

#    log_format simple '$time_iso8601 $body_bytes_sent $request_time $status';

#    access_log /root/access_nginx.log simple;

    server {
       listen @@@PORT@@@;
       location / {
          proxy_pass http://lbworkers;
	  proxy_redirect    off;
          proxy_http_version 1.1;
          proxy_set_header  X-Forwarded-For $remote_addr;
          proxy_set_header Connection "";
       }
    }
   
 
}
