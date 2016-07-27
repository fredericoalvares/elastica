
worker_processes  @@@PROCESSES@@@;

events {
    worker_connections 15000;
    multi_accept        on;
    use                 epoll;
}

worker_rlimit_nofile 65535;

http {
   
    sendfile           on;
    tcp_nopush         on;
    tcp_nodelay        on;
    keepalive_timeout  128;
 
    log_format logstash '{ "@timestamp": "$time_iso8601", '
                         '"remote_addr": "$remote_addr", '
                         '"remote_user": "$remote_user", '
                         '"body_bytes_sent": "$body_bytes_sent", '
                         '"request_time": $request_time, '
                         '"status": "$status", '
                         '"request": "$request", '
                         '"request_method": "$request_method", '
                         '"http_referrer": "$http_referer", '
                         '"http_user_agent": "$http_user_agent" }';
  

    access_log /root/access_nginx.log logstash;

    server {
       listen @@@PORT@@@;
       root @@@WWW_ROOT@@@;
       
       location ~ \.php$ {
	  fastcgi_split_path_info ^(.+\.php)(/.+)$;
	  fastcgi_pass 127.0.0.1:9000;
	  fastcgi_index index.php;
	  include /etc/nginx/fastcgi_params;
	  fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
       }
    }
   
 
}
