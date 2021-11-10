##############################################################
#                                                            #
#                  Moodle docker instance                    #
#                      Version 0.0.1                         #
##############################################################
FROM ubuntu:18.04
LABEL maintainer="dohnetwork@gmail.com"
ENV TZ=Asia/Bangkok
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*
RUN add-apt-repository ppa:ondrej/php

RUN apt-get install nginx php7.4 php7.4-dev php7.4-xml  php7.4-fpm -y --allow-unauthenticated

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update

RUN ACCEPT_EULA=Y

RUN ACCEPT_EULA=Y apt-get install -y --allow-unauthenticated msodbcsql17 mssql-tools

RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
#source ~/.bashrc
# optional: for unixODBC development headers
RUN apt-get install -y unixodbc-dev

RUN pecl config-set php_ini /etc/php/7.4/fpm/php.ini
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.4/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.4/mods-available/pdo_sqlsrv.ini
RUN phpenmod -v 7.4 sqlsrv pdo_sqlsrv

RUN apt-get install -y  nano vsftpd  memcached redis supervisor
COPY ./default /etc/nginx/sites-available/default
COPY ./a.php /var/www/html
#/etc/nginx/sites-available
EXPOSE 80
STOPSIGNAL SIGQUIT
#HEALTHCHECK --interval=5s --timeout=3s --retries=3 CMD curl -f http://localhost || exit 1
#RUN service php7.4-fpm start
CMD ["nginx", "-g", "daemon off;"]

#ADD supervisor.conf /etc/supervisor.conf
#ENTRYPOINT ["/usr/bin/supervisord -c /etc/supervisor.conf"]

#CMD service php7.4-fpm start && /usr/sbin/nginx -D FOREGROUND
#COPY entrypoint.sh /entrypoint.sh
#RUN chmod 755 /entrypoint.sh
#CMD ["/entrypoint.sh"]
#----------------------------------------------
#ENTRYPOINT /usr/sbin/php7.4-fpm --nodaemonize
#RUN a2enconf php7.4-fpm
#RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer 
#EXPOSE 80
# Now start the server
# Start PHP-FPM worker service and run Apache in foreground
#CMD service php7.4-fpm start
