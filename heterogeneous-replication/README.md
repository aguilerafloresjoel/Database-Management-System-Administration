# ACTIVIDAD 5: REPLICACIÓN DE SISTEMAS HETEROGÉNEOS

----

En la práctica anterior trabajamos la fragmentación de datos en las bases de datos con la herencia de registros entre tablas, y en esta nueva práctica vamos a trabajar la migración de datos entre distintos servidores de bases de datos. Concretamente, en este caso vamos a trabajar con MySQL y PostgreSQL.

----

## PARTE 0: Preparación del escenario 

---

En primer lugar vamos a proceder a obtener la base de datos que se nos demanda para la máquina servidora de MySQL.

```bash
joel@joelmysqlserver:~$ sudo apt update
sudo apt install -y wget unzip
[sudo] password for joel: 
Des:1 https://apt.postgresql.org/pub/repos/apt noble-pgdg InRelease [107 kB]
Obj:2 http://es.archive.ubuntu.com/ubuntu noble InRelease                      
Des:3 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Des:4 http://es.archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Des:5 https://apt.postgresql.org/pub/repos/apt noble-pgdg/main amd64 Packages [356 kB]
```

Descargamos el paquete del repositorio de github.

```bash
joel@joelmysqlserver:~$ wget https://github.com/datacharmer/test_db/archive/refs/heads/master.zip
--2026-02-02 12:05:01--  https://github.com/datacharmer/test_db/archive/refs/heads/master.zip
Resolving github.com (github.com)... 140.82.121.4
Connecting to github.com (github.com)|140.82.121.4|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://codeload.github.com/datacharmer/test_db/zip/refs/heads/master [following]
--2026-02-02 12:05:01--  https://codeload.github.com/datacharmer/test_db/zip/refs/heads/master
```
Descomprimimos con:

```bash
joel@joelmysqlserver:~$ unzip master.zip
cd test_db-master
Archive:  master.zip
3c7fa05e04b4c339d91a43b7029a210212d48e6c
   creating: test_db-master/
  inflating: test_db-master/Changelog  
  inflating: test_db-master/README.md  
  inflating: test_db-master/employees.sql  
  inflating: test_db-master/employees_partitioned.sql  
  inflating: test_db-master/employees_partitioned_5.1.sql  
   creating: test_db-master/images/
```
```bash
joel@joelmysqlserver:~/test_db-master$ ls
Changelog                      load_dept_manager.dump  README.md
employees_partitioned_5.1.sql  load_employees.dump     sakila
employees_partitioned.sql      load_salaries1.dump     show_elapsed.sql
employees.sql                  load_salaries2.dump     sql_test.sh
images                         load_salaries3.dump     test_employees_md5.sql
load_departments.dump          load_titles.dump        test_employees_sha.sql
load_dept_emp.dump             objects.sql             test_versions.sh
````
Cargamos la base de datos a mysql con:

```bash
joel@joelmysqlserver:~/test_db-master$ sudo mysql < employees.sql
INFO
CREATING DATABASE STRUCTURE
INFO
storage engine: InnoDB
INFO
LOADING departments
INFO
LOADING employees
INFO
```
Entramos en la base de datos y comprobamos que los registros coinciden con los que debería de haber:

```bash
Database changed
mysql> SELECT COUNT(*) FROM employees;
+----------+
| COUNT(*) |
+----------+
|   300024 |
+----------+
1 row in set (0,03 sec)
```
Ahora en la misma M.Servidor.MySQL vamos a compilar el pgloader pero con la versión de “dimitri” de github, porque la versión que se descarga por defecto nos da errores de compatibilidad.

```bash
joel@joelmysqlserver:~$ sudo apt install -y \
  build-essential sbcl unzip curl git \
  libsqlite3-dev libssl-dev libffi-dev
[sudo] password for joel: 
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
unzip ya está en su versión más reciente (6.0-28ubuntu4.1).
curl ya está en su versión más reciente (8.5.0-2ubuntu10.6).
git ya está en su versión más reciente (1:2.43.0-1ubuntu7.3).
fijado git como instalado manualmente.
```
Ahora clonamos el repositorio original…

```bash
joel@joelmysqlserver:~$ git clone https://github.com/dimitri/pgloader.git
cd pgloader
Cloning into 'pgloader'...
remote: Enumerating objects: 12050, done.
remote: Counting objects: 100% (215/215), done.
remote: Compressing objects: 100% (132/132), done.
```

Compilamos con **make** y lo enviamos a una ruta estándar. 

> [!WARNING]
> Pero antes vamos a instalar unas dependencias para la librería **libsybdb.so.5** que nos falta.

```bash
joel@joelmysqlserver:~$ sudo apt install -y freetds-dev libsybdb5
[sudo] password for joel: 
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
Se instalarán los siguientes paquetes adicionales:
…
```
```bash
joel@joelmysqlserver:~/pgloader$ make

./build/bin/pgloader

sudo cp build/bin/pgloader /usr/local/bin/pgloader
mkdir -p build
curl -o build/quicklisp.lisp http://beta.quicklisp.org/quicklisp.lisp
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 57144  100 57144    0     0   228k      0 --:--:-- --:--:-- --:--:--  228k
sbcl --noinform --no-sysinit --no-userinit --load build/quicklisp.lisp        
```
Este último paso nos hará esperar unos minutos hasta completarse.
Pero una vez finalice, vamos a asegurarnos de que la versión es la correcta con el siguiente comando:

```bash
joel@joelmysqlserver:~$ pgloader --version
pgloader version "3.6.d9ca38e"
compiled with SBCL 2.2.9.debian
```
Efectivamente, es la versión de nuestro amigo cibernético Dimitri. Gracias Dimitri.

----

## PARTE 1: Carga de la base de datos en la M.Servidor.PSQL (destino):

----

Entramos como postgres y creamos la base de datos dejándola vacía, sin tablas.

```bash
joel@joelpostgreserver:~$ sudo -i -u postgres
[sudo] password for joel: 
postgres@joelpostgreserver:~$ createdb employees
postgres@joelpostgreserver:~$ 
```

Y ahora vamos a crearle una contraseña al usuario postgres para poder establecer una conexión remota desde el servidor MySQL.

> [!NOTE]
> También se podría crear un usuario para establecer la conexión remota. En nuestro caso, vamos a seguir con el usuario por defecto de postgres.

```bash
postgres@joelpostgreserver:~$ psql
psql (18.1 (Ubuntu 18.1-1.pgdg24.04+2))
Digite «help» para obtener ayuda.
```
```bash
postgres=# ALTER ROLE postgres WITH PASSWORD 'joel';
ALTER ROLE
postgres=# 
```
Ahora deberíamos mirar en los dos archivos de configuración principales si tenemos la base de datos lista para las comunicaciones con MySQL.

Deberemos mirar en ** /etc/postgresql/18/main/postgresql.conf**. Y aquí deberíamos de tener en la línea de direcciones que escucha, la dirección IP del la M.Servidor.MySQL o un asterisco (todas las direcciones).

Y también en el otro archivo de configuración **/etc/postgresql/18/main/pg_hba.conf**. Y aquí deberemos de tener esta línea **host    all     all     192.168.50.4/32    scram-sha-256** o la que ya tenía de la práctica anterior **host    all             all             0.0.0.0/0               md5**.

Aplicamos los cambios reiniciando el servicio.

```bash
joel@joelpostgreserver:~$ sudo systemctl restart postgresql@18-main
```
```bash
joel@joelpostgreserver:~$ psql "host=192.168.60.5 port=5432 dbname=employees user=postgres password=joel" -c "SELECT 1;"
 ?column? 
----------
        1
(1 fila)
```

Como no nos deja autenticarnos con el usuario de MySQL por incompatibilidad, vamos a forzar a entrar con un método más compatible con pgloader, que consiste en forzarle a usar el sistema clásico de su contraseña.

```bash
mysql> CREATE USER 'pgloader'@'localhost' IDENTIFIED WITH mysql_native_password BY 'pgloader';
Query OK, 0 rows affected (0,01 sec)

mysql> GRANT ALL PRIVILEGES ON employees.* TO 'pgloader'@'localhost';
Query OK, 0 rows affected (0,01 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0,01 sec)
```

Pero antes vamos a forzar a MySQL a usar la contraseña que hemos creado pàra entrar por defecto, editando el archivo de configuración **/etc/mysql/mysql.conf.d/mysqld.cnf** y añadiendo la siguiente línea:

**default-authentication-plugin=mysql_native_password** y acto seguido reiniciamos mysql.

A continuación probamos con el comando de replicación.

```bash
joel@joelmysqlserver:~$ pgloader "mysql://pgloader:pgloader@localhost/employees" "postgresql://postgres:joel@192.168.60.5/employees"
2026-02-09T07:31:26.077028Z LOG pgloader version "3.6.d9ca38e"
2026-02-09T07:31:26.083030Z LOG Data errors in '/tmp/pgloader/'
2026-02-09T07:31:26.410142Z LOG Migrating from #<MYSQL-CONNECTION mysql://pgloader@localhost:3306/employees {1005ECBF33}>
2026-02-09T07:31:26.410142Z LOG Migrating into #<PGSQL-CONNECTION pgsql://postgres@192.168.60.5:5432/employees {10061C8203}>
2026-02-09T07:31:59.353858Z LOG report summary reset
             table name     errors       rows      bytes      total time
-----------------------  ---------  ---------  ---------  --------------
        fetch meta data          0         21                     0.344s
         Create Schemas          0          0                     0.020s
       Create SQL Types          0          1                     0.094s
          Create tables          0         12                     0.153s
         Set Table OIDs          0          6                     0.014s
-----------------------  ---------  ---------  ---------  --------------
     employees.salaries          0    2844047    94.2 MB         27.392s
       employees.titles          0     443308    16.9 MB          8.794s
    employees.employees          0     300024    13.2 MB          6.198s
  employees.departments          0          9     0.1 kB          1.197s
     employees.dept_emp          0     331603    10.7 MB          2.486s
 employees.dept_manager          0         24     0.8 kB          0.092s
-----------------------  ---------  ---------  ---------  --------------
COPY Threads Completion          0          4                    29.731s
         Create Indexes          0          9                     5.096s
 Index Build Completion          0          9                     1.175s
        Reset Sequences          0          0                     0.101s
           Primary Keys          0          6                     0.043s
    Create Foreign Keys          0          6                     0.845s
        Create Triggers          0          0                     0.005s
        Set Search Path          0          1                     0.014s
       Install Comments          0          0                     0.000s
-----------------------  ---------  ---------  ---------  --------------
      Total import time          ✓    3919015   134.9 MB         37.011s
```

Ahora vamos a hacer una comprobación para verificar que la migración de datos ha sido exitosa en el servidor de PostgreSQL.

```bash
joel@joelpostgreserver:~$ psql -h localhost -U postgres -d employees
Contraseña para usuario postgres: 
psql (18.1 (Ubuntu 18.1-1.pgdg24.04+2))
Conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, compresión: desactivado, ALPN: postgresql)
Digite «help» para obtener ayuda.

employees=# 

employees=# \dn
      Listado de esquemas
  Nombre   |       Dueño       
-----------+-------------------
 employees | postgres
 public    | pg_database_owner
(2 filas)
```

```bash
employees=# \dt employees.*;
              Listado de tablas
  Esquema  |    Nombre    | Tipo  |  Dueño   
-----------+--------------+-------+----------
 employees | departments  | tabla | postgres
 employees | dept_emp     | tabla | postgres
 employees | dept_manager | tabla | postgres
 employees | employees    | tabla | postgres
 employees | salaries     | tabla | postgres
 employees | titles       | tabla | postgres
(6 filas)
```
```bash
employees=# SELECT COUNT(*) FROM employees.employees;
 count  
--------
 300024
(1 fila)
```

---

 ## PARTE 2: Migración de datos con SymmetricDS (unidireccional de MySQL a PostgreSQL)

 ----
 
En este segundo punto vamos a establecer una migración de datos de MySQL a PostgreSQL. Es decir, crearemos una comunicación entre ambos servidores que hará que los cambios producidos en MySQL se reflejen en PostgreSQL, pero no al revés.

Para ello vamos a dejar bien definidos los datos de cada máquina:

---

> MySQL (master)

IP: 192.168.50.4

Nodo: mysql-master

Puerto SymmetricDS: 31415

> PostgreSQL (slave)

IP: 192.168.50.5

Nodo: pgsql-slave

Puerto SymmetricDS: 31416

---

Una vez bien definidos los puntos claves vamos a proceder con la configuración.

En primer lugar vamos a realizar la instalación del software en ambos servidores. Primero instalando unas dependencias necesarias para poder ejecutar el software y luego descargando y descomprimiendo SymmetricDS.

En MySQL:

```bash
joel@joelmysqlserver:~$ sudo apt update -y
sudo apt install -y openjdk-17-jre-headless unzip wget
Obj:1 http://es.archive.ubuntu.com/ubuntu noble InRelease                               
Des:2 https://apt.postgresql.org/pub/repos/apt noble-pgdg InRelease [107 kB]            
Des:3 http://es.archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]     
Des:4 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]      
Des:5 http://es.archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
````

```bash
joel@joelmysqlserver:~$ wget -O symmetric-server.zip https://sourceforge.net/projects/symmetricds/files/symmetricds/symmetricds-3.16/symmetric-server-3.16.9.zip/download
unzip symmetric-server.zip
mv symmetric-server-* symmetricds
--2026-02-09 08:17:27--  https://sourceforge.net/projects/symmetricds/files/symmetricds/symmetricds-3.16/symmetric-server-3.16.9.zip/download
Resolving sourceforge.net (sourceforge.net)... 104.18.12.149, 104.18.13.149, 2606:4700::6812:d95, ...
Connecting to sourceforge.net (sourceforge.net)|104.18.12.149|:443... connected.
```

Ahora vamos a la configuración del fichero de propiedades de **MySQL** que vamos a crear y que va a establecer el nodo principal, el que en esta segunda parte de la actividad va a mandar:

Pero primero, como hemos instalado en la /home, vamos a mover a la siguiente ruta por recomendación: 

```bash
joel@joelmysqlserver:~$ sudo mv ~/symmetricds /opt/
sudo chown -R joel:joel /opt/symmetricds
[sudo] password for joel: 
joel@joelmysqlserver:~$ cd /opt/symmetricds
```

Ahora creamos el siguiente directorio con tal de tenerlo todo mejor organizado:

```bash
joel@joelmysqlserver:/opt/symmetricds$ mkdir -p engines
joel@joelmysqlserver:/opt/symmetricds$ cd engines
joel@joelmysqlserver:/opt/symmetricds/engines$ nano mysql.properties
```

Y este va a ser el contenido del fichero.

```bash
engine.name=mysql
group.id=mysql
external.id=001

db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/employees?useSSL=false&allowPublicKeyRetrieval=true
db.user=pgloader
db.password=pgloader

registration.url=
sync.url=http://192.168.60.4:31415/sync/mysql

auto.registration=true
initial.load.create.first=true

http.port=31415
````

```bash
joel@joelmysqlserver:/opt/symmetricds$ bin/symadmin --engine mysql create-sym-tables
Log output will be written to /opt/symmetricds/logs/symmetric.log
[] - AbstractCommandLauncher - Command: {create-sym-tables}
[] - AbstractCommandLauncher - Option: name=engine, value={mysql}
```

Ahora arrancamos el software…

```bash
joel@joelmysqlserver:/opt/symmetricds$ bin/sym --engine mysql
Log output will be written to /opt/symmetricds/logs/symmetric.log
[startup] - AbstractCommandLauncher - Command: {}
[startup] - SymmetricUtils - 
   _____                              __       _       ____   _____
  / ___/ __  _____ __  ___ __  ___  _/ /_ ____(_)___  / __ | / ___/
  \__ \ / / / / _ `_ \/ _ `_ \/ _ \/_ __// __/ / __/ / / / / \__ \ 
 ___/ // /_/ / // // / // // /  __// /  / / / / /_  / /_/ / ___/ / 
/____/ \__  /_//_//_/_//_//_/\___/ \_/ /_/ /_/\__/ /_____/ /____/  
      /____/                                                        
+-----------------------------------------------------------------+
| Copyright (C) 2007-2026 JumpMind, Inc.                          |
|                                                                 |
| Licensed under the GNU General Public License version 3.        |
| This software comes with ABSOLUTELY NO WARRANTY.                |
| See http://www.gnu.org/licenses/gpl.html                        |
+-----------------------------------------------------------------+
```

Y comprobamos que el puerto es el que le hemos establecido:

```bash
joel@joelmysqlserver:~$ ss -tlnp | grep 31415
LISTEN 0      50           0.0.0.0:31415      0.0.0.0:*    users:(("java",pid=2406,fd=141))
```

Estas líneas son importantes para saber que la configuración en MySQL es correcta:

```bash
0000ms with the first run at 2026-02-09T11:23:24.193+0000
[mysql] - AppUtils - Skipping undefined JVM system property: host.name
[mysql] - AppUtils - Skipping undefined environment variable: HOSTNAME
[mysql] - AppUtils - Skipping undefined environment variable: COMPUTERNAME
[mysql] - AppUtils - Hostname from the hostname OS command=joelmysqlserver
[mysql] - ClusterService - This node picked a server id of joelmysqlserver
[mysql] - AbstractSymmetricEngine - SymmetricDS Node STARTED:
     nodeId=001
     groupId=mysql
     type=null
     subType=trigger-based
     name=mysql
     softwareVersion=3.16.9
     databaseName=MySQL
     databaseVersion=8.0
     driverName=MySQL Connector/J
     driverVersion=mysql-connector-j-8.4.0 (Revision: 1c3f5c149e0bfe31c7fbeb24e2d260cd890972c4)
     uptime=0 sec.
```
---

En PostgreSQL:

En este caso vamos a hacer absolutamente lo mismo, con la diferencia de que en el fichero de configuración vamos a cambiar el nombre del nodo, del puerto e indicar la IP del servidor de MySQL.

```bash
joel@joelpostgreserver:~$ sudo apt update -y
sudo apt install -y openjdk-17-jre-headless unzip wget
[sudo] password for joel: 
Obj:1 http://es.archive.ubuntu.com/ubuntu noble InRelease
Des:2 https://apt.postgresql.org/pub/repos/apt noble-pgdg InRelease [107 kB]            
Des:3 http://es.archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]              
Des:4 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]               
Des:5 http://es.archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
```

```bash
joel@joelpostgreserver:~$ wget -O symmetric-server.zip https://sourceforge.net/projects/symmetricds/files/symmetricds/symmetricds-3.16/symmetric-server-3.16.9.zip/download
unzip symmetric-server.zip
mv symmetric-server-* symmetricds
--2026-02-09 08:18:00--  https://sourceforge.net/projects/symmetricds/files/symmetricds/symmetricds-3.16/symmetric-server-3.16.9.zip/download
Resolving sourceforge.net (sourceforge.net)... 104.18.12.149, 104.18.13.149, 2606:4700::6812:d95, ...
Connecting to sourceforge.net (sourceforge.net)|104.18.12.149|:443... connected.
```

```bash
joel@joelpostgreserver:~$ sudo mv ~/symmetricds /opt/
sudo chown -R joel:joel /opt/symmetricds
[sudo] password for joel: 
joel@joelpostgreserver:~$ cd /opt/symmetricds
mkdir -p engines
nano engines/psql.properties
```

El contenido del fichero de configuración será el siguiente:

```bash
engine.name=psql
group.id=psql
external.id=002

db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://localhost:5432/employees
db.user=postgres
db.password=joel

registration.url=http://192.168.60.4:31415/sync/mysql
sync.url=http://0.0.0.0:31416/sync/psql

auto.registration=true
initial.load.create.first=false

http.port=31416
```

Creamos las tablas internas del nodo de psql.

```bash
joel@joelpostgreserver:/opt/symmetricds$ bin/symadmin --engine psql create-sym-tables
Log output will be written to /opt/symmetricds/logs/symmetric.log
[] - AbstractCommandLauncher - Command: {create-sym-tables}
[] - AbstractCommandLauncher - Option: name=engine, value={psql}
[] - SymmetricUtils - 
```

Y arrancamos…

```bash
joel@joelpostgreserver:/opt/symmetricds$ bin/sym
Log output will be written to /opt/symmetricds/logs/symmetric.log
[startup] - AbstractCommandLauncher - Command: {}
[startup] - SymmetricUtils - 
   _____                              __       _       ____   _____
  / ___/ __  _____ __  ___ __  ___  _/ /_ ____(_)___  / __ | / ___/
  \__ \ / / / / _ `_ \/ _ `_ \/ _ \/_ __// __/ / __/ / / / / \__ \ 
 ___/ // /_/ / // // / // // /  __// /  / / / / /_  / /_/ / ___/ / 
/____/ \__  /_//_//_/_//_//_/\___/ \_/ /_/ /_/\__/ /_____/ /____/  
      /____/                                                        
+-----------------------------------------------------------------+
| Copyright (C) 2007-2026 JumpMind, Inc.                          |
|                                                                 |
| Licensed under the GNU General Public License version 3.        |
| This software comes with ABSOLUTELY NO WARRANTY.                |
| See http://www.gnu.org/licenses/gpl.html                        |
+-----------------------------------------------------------------+
```

Y volviendo a las líneas importantes, nos deben salir estas en PostgreSQL:

```bash
[psql] - AppUtils - Skipping undefined environment variable: COMPUTERNAME
[psql] - AppUtils - Hostname from the hostname OS command=joelpostgreserver
[psql] - ClusterService - This node picked a server id of joelpostgreserver
[psql] - AbstractSymmetricEngine - SymmetricDS Node STARTED:
     nodeId=002
     groupId=psql
     type=null
     subType=trigger-based
     name=psql
     softwareVersion=3.16.9
     databaseName=PostgreSQL
     databaseVersion=18.1
     driverName=PostgreSQL JDBC Driver
     driverVersion=42.7.3
     uptime=0 sec.
[psql] - NodeCommunicationService - pull will use 10 threads
[psql] - DataGapFastDetector - Full gap analysis is running
[psql] - DataGapFastDetector - Querying data in gaps from database took 35 ms
[psql] - DataGapFastDetector - Full gap analysis is done after 37 ms
```

Ahora las dos máquinas están comunicadas por los nodos que hemos establecido. Es por tanto, la hora de verificar que la migración funciona y que es unidireccional, y por tanto los cambios se pueden reflejar de MySQL a PostgreSQL y no al revés.

Para ello, SymmetricDS requiere de tres elementos fundamentales:

---
> Canal: Define cómo se envían los datos.

> Router: Define el origen y destino de la replicación.

> Triggers: Definen qué tablas y operaciones se replican.

---

Pero antes debemos crear un canal con un router que apunte de MySQL a PostgreSQL, y luego unos triggers para la tabla **departaments**.

```bash
mysql> INSERT INTO sym_channel
    -> (channel_id, processing_order, max_batch_size, enabled)
    -> VALUES
    -> ('mysql_to_psql', 1, 1000, 1);
Query OK, 1 row affected (0,03 sec)
```

Ahora vamos con el router, que es quien indica explícitamente que los datos deben viajar desde el grupo mysql hacia el grupo psql.

```bash
mysql> INSERT INTO sym_router (
    ->   router_id,
    ->   source_node_group_id,
    ->   target_node_group_id,
    ->   router_type,
    ->   create_time,
    ->   last_update_time
    -> )
    -> VALUES (
    ->   'mysql_to_psql_router',
    ->   'mysql',
    ->   'psql',
    ->   'default',
    ->   NOW(),
    ->   NOW()
    -> );
Query OK, 1 row affected (0,03 sec)
```

Ahora comprobamos qué routers existen.

```bash
mysql> SELECT router_id, source_node_group_id, target_node_group_id
    -> FROM sym_router;
+----------------------+----------------------+----------------------+
| router_id            | source_node_group_id | target_node_group_id |
+----------------------+----------------------+----------------------+
| mysql to psql        | mysql                | psql                 |
| mysql_to_psql_router | mysql                | psql                 |
| psql to mysql        | psql                 | mysql                |
+----------------------+----------------------+----------------------+
3 rows in set (0,00 sec)
```

A continuación vamos con el trigger, que es quien define qué tabla se replica y por qué canal.

```bash
mysql> INSERT INTO sym_trigger
    -> (trigger_id, source_table_name, channel_id, last_update_time, create_time)
    -> VALUES
    -> ('departments_trigger', 'departments', 'mysql_to_psql', NOW(), NOW());
Query OK, 1 row affected (0,06 sec)
```

Y en este siguiente paso vamos a enlazar el trigger con el router que apunta de MySQL a PostgreSQL, haciendo que la replicación tenga lugar.

```bash
mysql> INSERT INTO sym_trigger_router
    -> (trigger_id, router_id, enabled, initial_load_order, ping_back_enabled, create_time, last_update_time)
    -> VALUES
    -> ('departments_trigger', 'mysql_to_psql_router', 1, 1, 0, NOW(), NOW());
Query OK, 1 row affected (0,04 sec)
```

Volvemos a la M.Servidor.MySQL y aplicamos los siguientes comandos para hacer las comprobaciones. Es decir, añadiremos con **INSERT** a la tabla departments unos registros, que se deberán de reflejar en la misma tabla pero de la M.Servidor.PostgreSQL.

```bash
mysql> USE employees;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
mysql> INSERT INTO departments (dept_no, dept_name) VALUES ('prue', 'SYM_TEST_OK');
Query OK, 1 row affected (0,01 sec)
```

Hacemos un **SELECT** para comprobar que está todo bien:

```bash
mysql> SELECT * FROM departments WHERE dept_no='prue';
+---------+-------------+
| dept_no | dept_name   |
+---------+-------------+
| prue    | SYM_TEST_OK |
+---------+-------------+
1 row in set (0,00 sec)
```

Y ahora si volvemos a la M.Servidor.PostgreSQL y hacemos el mismo **SELECT** allí, debería de aparecer los registros añadidos.

```bash
employees=# SELECT * FROM departments WHERE dept_no = 'prue';
 dept_no |  dept_name  
---------+-------------
 prue    | SYM_TEST_OK
(1 fila)
```

Ahora vamos a comprobar que efectivamente la comunicación es unidireccional y no bidireccional. Para ello, vamos a crear un nuevo registro en la tabla en PostgreSQL y estos cambios no deberían de reflejarse en la tabla de MySQL.

Es por eso que volvemos a PostgreSQL e insertamos los registros en la tabla **departments**.

```bash
employees=# INSERT INTO departments (dept_no, dept_name) VALUES ('pru3', 'PSQL_SHOULD_NOT_SYNC');
INSERT 0 1
```

```bash
employees=# SELECT * FROM departments WHERE dept_no='pru3';
 dept_no |      dept_name       
---------+----------------------
 pru3    | PSQL_SHOULD_NOT_SYNC
(1 fila)
```

Y ahora vamos a la base de datos de MySQL y comprobamos, viendo que la comunicación en el sentido contrario (PostgreSQL → MySQL) no se ha producido.

```bash
mysql> USE employees;
Database changed
mysql> SELECT * FROM departments WHERE dept_no='pru3';
Empty set (0,00 sec)
```

Y podemos terminar de verificar mirando si se han generado eventos de salida en ambos nodos.

En PostgreSQL como es normal, no hay nada relacionado.

```bash
employees=# SELECT batch_id, status, create_time, last_update_time FROM sym_outgoing_batch ORDER BY create_time DESC LIMIT 10;
batch_id | status | create_time           | last_update_time
---------+--------+-----------------------+------------------
109      | OK     | 2026-02-09 15:22:30   | 2026-02-09 15:22:39
```

Por otro lado, en MySQL no hay ningún evento de salida que se haya generado. Es decir, que hasta aquí hemos avanzado correctamente.

```bash
mysql> SELECT * FROM sym_outgoing_batch WHERE node_id='001' ORDER BY create_time DESC LIMIT 10;
Empty set (0,00 sec)
```

## PARTE 3: Migración de datos con SymmetricDS (bidireccional entre MySQL a PostgreSQL)

En la segunda parte la replicación funcionaba únicamente en el sentido de MySQL hacia PostgreSQL.

Sin embargo, en esta tercera parte vamos a modificar la configuración de SymmetricDS para que ambos nodos puedan enviar y recibir cambios. De esta manera podremos decir que la comunicación es bidireccional entre ambos servidores. 
Es decir, debemos hacer que el sentido de PostgreSQL hacia MySQL también funcione.

Para ello lo primero que vamos a hacer es la creación de un nuevo canal.

```bash
employees=# INSERT INTO sym_channel (channel_id, processing_order, max_batch_size, enabled) VALUES ('psql_to_mysql', 2, 1000, 1);
INSERT 0 1
```

Ahora vamos a crear el router que le indica a SymmetricDS que los cambios que se den en PostgreSQL deben enviarse a MySQL.

```bash
employees=# INSERT INTO sym_router (
  router_id,
  source_node_group_id,
  target_node_group_id,
  router_type,
  create_time,
  last_update_time
)
VALUES (
  'psql_to_mysql_router',
  'psql',
  'mysql',
  'default',
  NOW(),
  NOW()
);
INSERT 0 1
```

Podemos hacer una comprobación para ver si aparece el nuevo router apuntando en el sentido que hemos comentado.

```bash
employees=# SELECT router_id, source_node_group_id, target_node_group_id
FROM sym_router;
      router_id       | source_node_group_id | target_node_group_id 
----------------------+----------------------+----------------------
 mysql to psql        | mysql                | psql
 mysql_to_psql_router | mysql                | psql
 psql_to_mysql_router | psql                 | mysql
(3 filas)
```

Ahora crearemos un trigger para la tabla **departments**.

```bash
employees=# INSERT INTO sym_trigger
(trigger_id, source_table_name, channel_id, last_update_time, create_time)
VALUES
('departments_psql_trigger', 'departments', 'psql_to_mysql', NOW(), NOW());
INSERT 0 1
```

Y asociaremos dicho trigger al router que hemos creado antes.

```bash
employees=# INSERT INTO sym_trigger_router
(
  trigger_id,
  router_id,
  enabled,
  initial_load_order,
  ping_back_enabled,
  create_time,
  last_update_time
)
VALUES
(
  'departments_psql_trigger',
  'psql_to_mysql_router',
  1,
  1,
  0,
  NOW(),
  NOW()
);
INSERT 0 1
```

Ahora detenemos SymmetricDS en ambos servidores y volvemos a iniciar para que carguen con los cambios generados.

```bash
employees=# INSERT INTO departments (dept_no, dept_name) VALUES ('hola', 'BIDIRECCIONAL_OHYES');
INSERT 0 1
employees=# SELECT * FROM departments WHERE dept_no='hola';
 dept_no |      dept_name      
---------+---------------------
 hola    | BIDIRECCIONAL_OHYES
(1 fila)
```

Y ahora comprobamos si en MySQL se han replicado los registros.

```bash
mysql> SELECT * FROM departments WHERE dept_no='hola';
+---------+---------------------+
| dept_no | dept_name           |
+---------+---------------------+
| hola    | BIDIRECCIONAL_OHYES |
+---------+---------------------+
1 row in set (0,00 sec)
```

Además, podemos comprobar la captura de los batches recientes.

En el caso de PostgreSQL vemos que ha generado eventos de salida porque los triggers están activos, el router hace su trabajo de psql a mysql, y el nodo de PostgreSQL actúa como emisor.

```bash
employees=# SELECT batch_id, status, create_time, last_update_time
FROM sym_outgoing_batch
ORDER BY create_time DESC
LIMIT 5;
 batch_id | status |       create_time       |    last_update_time     
----------+--------+-------------------------+-------------------------
      134 | OK     | 2026-02-09 16:46:40.325 | 2026-02-09 16:46:45.221
      133 | OK     | 2026-02-09 16:44:59.371 | 2026-02-09 16:44:59.381
      132 | OK     | 2026-02-09 16:44:59.358 | 2026-02-09 16:45:05.516
      124 | OK     | 2026-02-09 16:37:40.115 | 2026-02-09 16:37:40.121
      123 | OK     | 2026-02-09 16:37:40.108 | 2026-02-09 16:37:49.01
(5 filas)
```

En MySQL también vemos eventos de salida con el status correcto, confirmando que también ha generado eventos de salida y por tanto, no ha roto la configuración previa del apartado dos, donde es MySQL quien actúa como emisor.

```bash
mysql> SELECT batch_id, status, create_time, last_update_time
    -> FROM sym_outgoing_batch
    -> ORDER BY create_time DESC
    -> LIMIT 5;
+----------+--------+---------------------+---------------------+
| batch_id | status | create_time         | last_update_time    |
+----------+--------+---------------------+---------------------+
|      143 | OK     | 2026-02-09 17:56:17 | 2026-02-09 17:56:17 |
|      142 | OK     | 2026-02-09 17:54:16 | 2026-02-09 17:55:56 |
|      136 | OK     | 2026-02-09 17:48:56 | 2026-02-09 17:48:56 |
|      135 | OK     | 2026-02-09 17:48:26 | 2026-02-09 17:48:41 |
|      134 | OK     | 2026-02-09 16:23:00 | 2026-02-09 16:23:00 |
+----------+--------+---------------------+---------------------+
5 rows in set (0,01 sec)
```
Y hasta aquí la práctica número 5.
