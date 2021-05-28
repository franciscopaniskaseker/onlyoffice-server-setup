aptUpdate()
{
    apt -qqq update &> /dev/null
}

setupRepositoryRedis()
{
  add-apt-repository -y ppa:redislabs/redis
  apt update
}

setupServiceRedis()
{
  apt -qqqy install redis-server
}

startSystemdServices()
{
  for local_systemd_service on $@
  do
    systemctl start $local_systemd_service
  done
}

enableSystemdServices()
{
  for local_systemd_service on $@
  do
    systemctl enable $local_systemd_service
  done
}

stopSystemdServices()
{
  for local_systemd_service on $@
  do
    systemctl stop $local_systemd_service
  done
}

restartSystemdServices()
{
  for local_systemd_service on $@
  do
    systemctl restart $local_systemd_service
  done
}

setupRepositoryNginx()
{
  add-apt-repository -y ppa:nginx/stable
}

setupServiceNginx()
{
  apt -qqqy install nginx-extras
}

setupRequirements()
{
  apt -qqqy install gnupg2 wget apt-transport-https
}

setupRepositoryRabbitqm()
{
  wget --quiet -O - https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | apt-key add -
  echo "deb https://dl.bintray.com/rabbitmq-erlang/debian focal erlang-22.x" > /etc/apt/sources.list.d/rabbitmq.list
}

setupServiceRabbitmq()
{
  apt -qqqy install rabbitmq-server
}

setupRepositoryPostgresql()
{
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
  echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
}

setupServicePostgresql()
{
  apt -qqqy install postgresql  
}

setupRepositoryOoffice()
{
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
  echo "deb https://download.onlyoffice.com/repo/debian squeeze main" > /etc/apt/sources.list.d/onlyoffice.list
}

setupServiceOoffice()
{
  # TODO answer mscorefonts
  # TODO answer database password onlyoffice
  apt -qqqy install ttf-mscorefonts-installer onlyoffice-documentserver
}

configureServicePostgresql()
{
  # TODO setup database
  #CREATE DATABASE onlyoffice;
  #CREATE USER onlyoffice WITH password '1297eh9128eh918eh198eVB35Y';
  #GRANT ALL privileges ON DATABASE onlyoffice TO onlyoffice;
}

setupRepositoryCertbot()
{
  snap install core
  snap refresh core
}

setupServiceCertbot()
{
  snap install --classic certbot
  ln -s /snap/bin/certbot /usr/bin/certbot
}

createSsl()
{
  stopSystemdService nginx
  cd /etc/ssl/certs/
  openssl dhparam -out dhparam.pem 4096
  # TODO CREATE SSL
  startSystemdService nginx
}

main()
{
  aptUpdate

  # repositories
  setupRepositoryRedis
  setupRepositoryNginx
  setupRepositoryRabbitqm
  setupRepositoryPostgresql
  setupRepositoryOoffice
  setupRepositoryCertbot

  aptUpdate
  setupRequirements

  # services
  setupServiceRedis
  setupServiceNginx  
  setupServiceRabbitmq
  setupServicePostgresql
  configureServicePostgresql
  setupServiceCertbot
  createSsl
  setupServiceOoffice

  # systemd
  enableSystemdServices $systemd_services
  restartSystemdServices $systemd_services
  exit 0
}
