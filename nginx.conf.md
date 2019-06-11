# nginx 配置文件注释版本

```
# 运行用户
user www-data;

# 启动进程,通常设置成和cpu的数量相等
# cat /proc/cpuinfo | grep processor | wc -l # 查询 cpu 信息
worker_processes  auto;

# 一个nginx进程打开的最多文件描述符数目，理论值应该是最多打开文件数（ulimit -n）与 nginx 进程数相除，但是 nginx 分配请求并不是那么均匀，所以最好与 ulimit -n 的值保持一致。
worker_rlimit_nofile 51200;
# worker_rlimit_nofile = worker_connections * worker_processes

#全局错误日志及PID文件
error_log  /var/log/nginx/error.log;
pid        /var/run/nginx.pid;

#工作模式及连接数上限
events {
        # use [ kqueue | rtsig | epoll | /dev/poll | select | poll ]; 
        # epoll模型是Linux 2.6以上版本内核中的高性能网络I/O模型，如果跑在FreeBSD上面，就用kqueue模型。
        use epoll; 
        worker_connections 51200; # 单个后台worker process进程的最大并发链接数, 最大客户数也由系统的可用 socket 连接数限制（~ 64K），所以设置不切实际的高没什么好处。
        multi_accept on; # worker 接受尽可能多的链接，需谨慎使用，可能会导致服务奔溃。
}

http
    {
    
        ##
        # Basic Settings
        ##
        
        # 是否暴露 nginx 版本
        server_tokens off;

        # 开启高效传输模式。
        sendfile on; 
        
        # 防止网络阻塞，告诉nginx在一个数据包里发送所有头文件，而不一个接一个的发送
        tcp_nopush on;

        # 给客户端分配 keep-alive 链接超时时间，单位 "秒", 服务器将在这个超时时间过后关闭链接, 我们将它设置低些可以让 ngnix 持续工作的时间更长。
        keepalive_timeout 60;

        # 告诉 nginx 不要缓存数据，而是一段一段的发送：当需要及时发送数据时，就应该给应用设置这个属性，这样发送一小块数据信息时就不能立即得到返回值。
        tcp_nodelay on;
        
        types_hash_max_size 2048;
        
        服务器名字的hash表大小
        server_names_hash_bucket_size 128;
        
        # 指定来自客户端请求头的 hearer buffer 大小
        client_header_buffer_size 32k;
        
        # 指定客户端请求中较大的消息头的缓存最大数量和大小。
        large_client_header_buffers 4 32k;
        
        # 客户端请求单个文件的最大字节数
        client_max_body_size 50m;

        # 默认文件类型
        default_type  application/octet-stream;
        
        # 文件扩展名与文件类型映射表
        include       mime.types;

        ##
        # Logging Settings
        ##
        
        log_format  main  '$http_x_forwarded_for - $remote_addr - $remote_user [$time_local] "$request" '
           '$status $body_bytes_sent "$http_referer" '
           '"$http_user_agent" "$request_time"';

        # 设置nginx是否将存储访问日志。
        access_log off; 
        access_log /var/log/nginx/access.log; # 可以在 server 段配置具体的 log。

        ##
        # SSL Settings
        ##
                
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        ##
        # Gzip Settings
        ##
        
        gzip on;
        gzip_disable "msie6";

        gzip_vary on;
        gzip_proxied any;
        gzip_comp_level 6;
        gzip_buffers 16 8k;
        gzip_http_version 1.1;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        ##
        # FastCGI Setting 
        # 相关参数是为了改善网站的性能：减少资源占用，提高访问速度。
        ##
        
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        fastcgi_buffer_size 64k;
        fastcgi_buffers 4 64k;
        fastcgi_busy_buffers_size 128k;
        fastcgi_temp_file_write_size 256k;

        include vhost/*.conf;
}
    
```

``` log format
$remote_addr 与 $http_x_forwarded_for 用以记录客户端的ip地址；
$remote_user ：用来记录客户端用户名称；
$time_local ：用来记录访问时间与时区；
$request  ：用来记录请求的url与http协议；
$status ：用来记录请求状态； 
$body_bytes_sent ：记录发送给客户端文件主体内容大小；
$http_referer ：用来记录从那个页面链接访问过来的；
$http_user_agent ：记录客户端浏览器的相关信息
```