# PRÉ-REQUISITOS PARA INICIAR A INSTALAÇÃO 

O Moodle é desenvolvido principalmente em Linux, usando Apache, MySQL e PHP, mas também é testado regularmente com PostgreSQL e nos sistemas operativos Windows XP, Mac OS X e Netware 6.
Antes de iniciar a instalação é necessário que todo o ambiente web que funcionará por trás do Moodle esteja com as configurações mínimas para o perfeito funcionamento do Moodle. Além disso, as configurações devem suportar pelo menos 1000 (hum mil) usuários simultâneos na plataforma.
Estimar recursos de hardware para uma plataforma web é sempre um desafio. Dito  isso, seguem os requisitos mínimos necessários de hardware:

-	Servidor virtual para a aplicação:
	•	Sistema operacional Linux;
•	8 x Vcpus de 2.4 Ghz;
•	12 GB de memória RAM;
•	90 GB de disco rígido;
•	Link de 10 Mbit a 40 Mbit.

-	Servidor virtual para o banco de dados:
•	Sistema operacional Linux;
•	8 x Vcpus de 2.4 Ghz;
•	8 GB de memória RAM;
•	90 GB de disco rígido.

-Espaço em disco: 
o espaço em disco necessário para o programa principal do Moodle é mínimo (1GB), no entanto, o que realmente é preciso é de espaço para armazenar os materiais.

-Memória: 
a regra geral é que o Moodle pode suportar de 10 a 15 usuários concorrente para cada 1 GB de RAM, mas isso varia de acordo com a sua combinação de hardware e software específico e do tipo de uso. Concorrente não é online. Concorrente também não significa o número de usuários cadastrados no banco. Concorrente não é o número de logins. Concorrente é o número de processos que o servidor realiza ao mesmo tempo, ou seja, concorrendo os processadores.

Seguem os requisitos mínimos necessários de software:

•	Servidor Apache;
•	Banco de dados MariaDB 10.2.29 ou MySQL 5.7 ou Postgres 9.6 ou MSSQL 2012 ou Oracle 11.2;
•	Linguagem de programação PHP na versão 7.4.0;
•	PhpMyAdmin.

# 1º PASSO: CRIAR VOLUMES
docker volume create moodle-man-vol

docker volume create moodle-man-arch

# 2º PASSO: Criar container do BD
docker run -d \
--name moodle-man-db \
-p 3306:3306 \
--mount src=moodle-man-vol,dst=/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD="moodle" \
-e MYSQL_DATABASE="moodle" \
-e MYSQL_USER="moodle_user" \
-e MYSQL_PASSWORD="moodle_pass" \
mysql:5.7.30

# 3º PASSO: Crie a imagem a partir do dockerfile   

docker build -t moodle:1.0 .

# 4º PASSO: Crie o container da aplicação

docker run -d \
--name moodle-man-app \
-p 9090:80 \
--mount src=moodle-man-arch,dst=/var/www/moodledata \
-e MOODLE_DATABASE_NAME="moodle" \
-e MOODLE_DATABASE_USER="moodle_user" \
-e MOODLE_DATABASE_PASSSWORD="moodle_pass" \
-e MOODLE_DATABASE_HOST="moodle-man-db" \
moodle:1.0

# 5º PASSO: Crie as conexões

docker network create --attachable moodle-network

docker network connect moodle-network moodle-man-db

docker network connect moodle-network moodle-man-app

docker restart moodle-man-app

docker restart moodle-man-db

Acesse:http://ip.do.host:9090/moodle e prossiga com a instalação do moodle.


# INICIANDO O CRON

O cron.php é o script que roda todas as tarefas essencias para o bom funcionamento do moodle.
No console do container da aplicação digite:

/etc/init.d/cron restart

Acesse http://ip.do.host:9090/moodle/admin/index.php e verifique se o cron está sendo executado. Se não estiver, um aviso irá informar a quantidade de tempo que o script não é rodado. O recomendando e que rode de 1 em 1 minuto.

