# ACTIVIDAD 2 - Sistemas Cliente - Servidor con PostgreSQL

---

Para la realización de esta segunda práctica con PostgreSQL, vamos a reutilizar las dos máquinas de la primera actividad; tanto cliente como servidor.

En dichas máquinas tenemos ya instalado PostgreSQL en versión cliente y en versión servidor respectivamente e identificadas con un nombre que las diferencia claramente.

---

## Primera parte: Servidor

---

Lo primero que se nos demanda en esta primera parte es que conectemos con el servidor y hagamos lo necesario para cargar en él, el archivo **.tar** del link que se nos proporciona: https://github.com/mvm-classroom/mvm-recursos/raw/main/cicles/ASIX/ASGBD/Recursos/dvdrental.tar

Para ello, abriremos la terminal en nuestro servidor y una vez copiada la URL, usaremos el comando:
```bash
isard@jaguilera-server:~$ wget -O /tmp/dvdrental.tar https://github.com/mvm-classroom/mvm-recursos/raw/main/cicles/ASIX/ASGBD/Recursos/dvdrental.tar
--2025-11-11 13:37:22--  https://github.com/mvm-classroom/mvm-recursos/raw/main/cicles/ASIX/ASGBD/Recursos/dvdrental.tar
Resolving github.com (github.com)... 140.82.121.4
Connecting to github.com (github.com)|140.82.121.4|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://raw.githubusercontent.com/mvm-classroom/mvm-recursos/main/cicles/ASIX/ASGBD/Recursos/dvdrental.tar [following]
--2025-11-11 13:37:23--  https://raw.githubusercontent.com/mvm-classroom/mvm-recursos/main/cicles/ASIX/ASGBD/Recursos/dvdrental.tar
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.111.133, 185.199.108.133, 185.199.109.133, ...
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|185.199.111.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2835456 (2,7M) [application/octet-stream]
Saving to: ‘/tmp/dvdrental.tar’

/tmp/dvdrental.tar      100%[==============================>]   2,70M  --.-KB/s    in 0,03s   

2025-11-11 13:37:23 (91,2 MB/s) - ‘/tmp/dvdrental.tar’ saved [2835456/2835456]
```


> [!NOTE]
> Por defecto, wget descarga los datos en el directorio desde el que se ejecuta el comando. Pero en este caso, con la **-O** vamos a indicarle nosotros el directorio en el que queremos que se descargue el fichero **.tar** del enlace. Y vamos a indicar el directorio **/tmp** porque como sólo queremos el archivo para cargar la base de datos en PostgreSQL, así al acabar la sesión, desaparecerán del directorio.

---

## Segunda parte: Cliente

---

### Cliente Local

---

Ahora vamos a pasar a identificarnos con el usuario **postgres** usando:
```bash
isard@jaguilera-server:~$ sudo -i -u postgres
postgres@jaguilera-server:~$ postgres
Command 'postgres' not found, did you mean:
  command 'postgrey' from deb postgrey (1.37-2)
Try: apt install <deb name>
postgres@jaguilera-server:~$ 
```
Y vamos a crear una base de datos, que estará vacía de inicio, pero en la que volcaremos el archivo **.tar** que hemos descargado antes.
```bash
postgres@jaguilera-server:~$ createdb dvdrental
postgres@jaguilera-server:~$
```
Nos aseguramos de que se ha creado correctamente:
```bash
postgres@jaguilera-server:~$ psql -l
                                                                       Listado de base de datos
     Nombre     |    Dueño     | Codificación | Proveedor de locale |   Collate   |    Ctype    | Configuración regional | Reglas ICU: |          Privilegios          
----------------+--------------+--------------+---------------------+-------------+-------------+------------------------+-------------+-------------------------------
 dvdrental      | postgres     | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | 
 mvm_asgbd_joel | cliente_joel | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | =Tc/cliente_joel             +
                |              |              |                     |             |             |                        |             | cliente_joel=CTc/cliente_joel
 postgres       | postgres     | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | 
 template0      | postgres     | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | =c/postgres                  +
                |              |              |                     |             |             |                        |             | postgres=CTc/postgres
 template1      | postgres     | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | =c/postgres                  +
                |              |              |                     |             |             |                        |             | postgres=CTc/postgres
 tienda_prueba  | cliente_joel | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | =Tc/cliente_joel             +
                |              |              |                     |             |             |                        |             | cliente_joel=CTc/cliente_joel
(6 filas)
```
Y si es así, añadiremos el contenido del archivo **.tar** en la base de datos vacía que acabamos de crear.
```bash
postgres@jaguilera-server:~$ pg_restore -d dvdrental /tmp/dvdrental.tar
postgres@jaguilera-server:~$ 
````
> [!TIP]
> Si da error podemos usar:
```bash
pg_restore -U postgres -d dvdrental /tmp/dvdrental.tar
````
Una vez creada y cargados los datos, procederemos a ver que algunos de los datos que guardan las tablas con un **SELECT** de lo más simple. Pero para ello primero debemos acceder a la base de datos.
```bash
postgres@jaguilera-server:~$ psql -d dvdrental
psql (18.0 (Ubuntu 18.0-1.pgdg24.04+3))
Digite «help» para obtener ayuda.

dvdrental=# 

dvdrental=# SELECT * FROM actor LIMIT 5;
 actor_id | first_name |  last_name   |      last_update       
----------+------------+--------------+------------------------
        1 | Penelope   | Guiness      | 2013-05-26 14:47:57.62
        2 | Nick       | Wahlberg     | 2013-05-26 14:47:57.62
        3 | Ed         | Chase        | 2013-05-26 14:47:57.62
        4 | Jennifer   | Davis        | 2013-05-26 14:47:57.62
        5 | Johnny     | Lollobrigida | 2013-05-26 14:47:57.62
(5 filas)
```
---

### Cliente remoto - Localhost

---

A continuación lo que vamos a hacer es aprovechar la misma consola **psql** que estábamos usando en el punto anterior pero en este caso para hacer una conexión remota. Es decir, vamos a conectarnos desde nuestra máquina servidor al servicio pero simulando como si nos estuviéramos conectando desde otra máquina. 

Para ello vamos a usar el comando:
```bash
isard@jaguilera-server:~$ psql -h localhost -U postgres
psql: error: falló la conexión al servidor en «localhost» (127.0.0.1), puerto 5432: Connection refused
    ¿Está el servidor en ejecución en ese host y aceptando conexiones TCP/IP?
isard@jaguilera-server:~$ 
```
> [!NOTE]
> El parámetro **-h** lo usamos para establecer la conexión (en este caso como el host local, aunque lo normal al hacer una conexión remota fuera indicar la dirección IP del Servidor).

> [!NOTE]
> El parámetro **-U** lo empleamos para indicar el usuario con el que queremos conectar (en la actividad anterior conectábamos con el usuario que creamos para la M. Cliente).

En nuestro caso nos aparece un error de conexión, porque para la actividad anterior editamos el archivo de configuración de PostgreSQL, y en la línea de **listen_addresses =** marcamos la IP de nuestra M.Servidor, por lo que sólo escucha a esa dirección. Por lo tanto, para evitar el error y poder acceder también como localhost, deberemos editarlo de nuevo, y en esa misma línea añadir **localhost**.
```bash
# - Connection Settings -

listen_addresses = '192.168.1.30, localhost'            # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)
port = 5432                             # (change requires restart)
max_connections = 100                   # (change requires restart)
#reserved_connections = 0               # (change requires restart)
#superuser_reserved_connections = 3     # (change requires restart)
unix_socket_directories = '/var/run/postgresql' # comma-separated list of directories
                                        # (change requires restart)
#unix_socket_group = ''                 # (change requires restart)
#unix_socket_permissions = 0777         # begin with 0 to use octal notation
                                        # (change requires restart)
#bonjour = off                          # advertise server via Bonjour
                                        # (change requires restart)
```
Añadida la nueva dirección, reiniciamos el servicio.
```bash
isard@jaguilera-server:~$ sudo systemctl restart postgresql
```
Y probamos de nuevo la conexión.
```bash
isard@jaguilera-server:~$ psql -h localhost -U postgres
Contraseña para usuario postgres: 
psql (18.0 (Ubuntu 18.0-1.pgdg24.04+3))
Conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, compresión: desactivado, ALPN: postgresql)
Digite «help» para obtener ayuda.

postgres=# 
Ahora que estamos dentro, vamos a asegurarnos de que podemos consultar la base de datos “dvdrental” haciendo algún SELECT de lo más simple.
Primero listamos nuestras bases de datos.
postgres=# \list
                                                                       Listado de base de datos
     Nombre     |    Dueño     | Codificación | Proveedor de locale |   Collate   |    Ctype    | Configuración regional | Reglas ICU: |          Privilegios          
----------------+--------------+--------------+---------------------+-------------+-------------+------------------------+-------------+-------------------------------
 dvdrental      | postgres     | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | 
 mvm_asgbd_joel | cliente_joel | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | =Tc/cliente_joel             +
                |              |              |                     |             |             |                        |             | cliente_joel=CTc/cliente_joel
 postgres       | postgres     | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | 
 template0      | postgres     | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | =c/postgres                  +
                |              |              |                     |             |             |                        |             | postgres=CTc/postgres
 template1      | postgres     | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | =c/postgres                  +
                |              |              |                     |             |             |                        |             | postgres=CTc/postgres
 tienda_prueba  | cliente_joel | UTF8         | libc                | es_ES.UTF-8 | es_ES.UTF-8 |                        |             | =Tc/cliente_joel             +
                |              |              |                     |             |             |                        |             | cliente_joel=CTc/cliente_joel
(6 filas)
```
Ahora entramos en la base de datos de **dvdrental**.
```bash
postgres=# \c dvdrental
Conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, compresión: desactivado, ALPN: postgresql)
Ahora está conectado a la base de datos «dvdrental» con el usuario «postgres».
Describimos las tablas de la base de datos.
dvdrental=# \dt
             Listado de tablas
 Esquema |    Nombre     | Tipo  |  Dueño   
---------+---------------+-------+----------
 public  | actor         | tabla | postgres
 public  | address       | tabla | postgres
 public  | category      | tabla | postgres
 public  | city          | tabla | postgres
 public  | country       | tabla | postgres
 public  | customer      | tabla | postgres
 public  | film          | tabla | postgres
 public  | film_actor    | tabla | postgres
 public  | film_category | tabla | postgres
 public  | inventory     | tabla | postgres
 public  | language      | tabla | postgres
 public  | payment       | tabla | postgres
 public  | rental        | tabla | postgres
 public  | staff         | tabla | postgres
 public  | store         | tabla | postgres
(15 filas)
```
Y hacemos la consulta.
```bash
dvdrental=# SELECT * FROM actor limit 8;
 actor_id | first_name |  last_name   |      last_update       
----------+------------+--------------+------------------------
        1 | Penelope   | Guiness      | 2013-05-26 14:47:57.62
        2 | Nick       | Wahlberg     | 2013-05-26 14:47:57.62
        3 | Ed         | Chase        | 2013-05-26 14:47:57.62
        4 | Jennifer   | Davis        | 2013-05-26 14:47:57.62
        5 | Johnny     | Lollobrigida | 2013-05-26 14:47:57.62
        6 | Bette      | Nicholson    | 2013-05-26 14:47:57.62
        7 | Grace      | Mostel       | 2013-05-26 14:47:57.62
        8 | Matthew    | Johansson    | 2013-05-26 14:47:57.62
(8 filas)
```

---

### Cliente remoto - Remote host

---

En este caso vamos a conectar desde la M.Cliente a la M.Servidor de manera remota y con el mismo usuario postgres.

Como reutilizaremos la máquina del ejercicio anterior, ya tenemos instalado en ella PostgreSQL en su versión cliente, así que accederemos a la terminal y pondremos el comando:
```bash
alumne@jaguilera:~$ psql -h 192.168.1.30 -U postgres
Password for user postgres: 
psql (18.0 (Ubuntu 18.0-1.pgdg22.04+3))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off, ALPN: postgresql)
Type "help" for help.
```
Ahora que estamos dentro, entramos de nuevo en la base de datos **dvdrental** y hacemos un **SELECT** para mostrar algunos registros y certificar que podemos verlos.
```bash
postgres=# \c dvdrental
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off, ALPN: postgresql)
You are now connected to database "dvdrental" as user "postgres".
dvdrental=# SELECT * FROM city LIMIT 8;
 city_id |        city        | country_id |     last_update     
---------+--------------------+------------+---------------------
       1 | A Corua (La Corua) |         87 | 2006-02-15 09:45:25
       2 | Abha               |         82 | 2006-02-15 09:45:25
       3 | Abu Dhabi          |        101 | 2006-02-15 09:45:25
       4 | Acua               |         60 | 2006-02-15 09:45:25
       5 | Adana              |         97 | 2006-02-15 09:45:25
       6 | Addis Abeba        |         31 | 2006-02-15 09:45:25
       7 | Aden               |        107 | 2006-02-15 09:45:25
       8 | Adoni              |         44 | 2006-02-15 09:45:25
(8 rows)
```

---

## Tercera parte: Cliente (pgAdmin4)

---

En esta tercera parte de la actividad vamos a instalar en la M.Servidor el software pgAdmin4. Ésta es la herramienta oficial de administración gráfica de PostgreSQL, por lo que con ella podremos conectarnos de manera remota al servidor.

Para hacer la instalación, en la terminal usaremos los comandos para actualizar el sistema.
```bash
isard@jaguilera-server:~$ sudo apt update && upgrade
```
Acto seguido debemos importar la clave del repositorio oficial que verificará que los paquetes que nos hemos descargado no hayan sido modificados.
```bash
isard@jaguilera-server:~$ curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
```

Ahora que lo hemos verificado, vamos a crear un archivo **.list** que contendrá la URL oficial del repositorio de pgAdmin4, lo que permitirá que el sistema pueda descargar e instalar el paquete directamente desde los servidores de PostgreSQL.
```bash
isard@jaguilera-server:~$ sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
Obj:1 http://security.ubuntu.com/ubuntu noble-security InRelease
Obj:2 https://apt.postgresql.org/pub/repos/apt noble-pgdg InRelease          
Obj:3 http://de.archive.ubuntu.com/ubuntu noble InRelease                    
Obj:4 http://de.archive.ubuntu.com/ubuntu noble-updates InRelease
Des:5 https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/noble pgadmin4 InRelease [4.217 B]
Obj:6 http://de.archive.ubuntu.com/ubuntu noble-backports InRelease
Des:7 https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/noble pgadmin4/main amd64 Packages [5.358 B]
Des:8 https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/noble pgadmin4/main all Packages [3.094 B]
Descargados 12,7 kB en 1s (13,9 kB/s)
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
Se pueden actualizar 26 paquetes. Ejecute «apt list --upgradable» para verlos.
```
Ahora actualizaremos los repositorios para que el sistema reconozca el nuevo origen de paquetes con la URL oficial de pgAdmin.
```bash
isard@jaguilera-server:~$ sudo apt update
Obj:1 http://de.archive.ubuntu.com/ubuntu noble InRelease
Obj:2 https://apt.postgresql.org/pub/repos/apt noble-pgdg InRelease                                                              
Obj:3 http://de.archive.ubuntu.com/ubuntu noble-updates InRelease                                                                
Obj:4 http://de.archive.ubuntu.com/ubuntu noble-backports InRelease                                                              
Obj:5 http://security.ubuntu.com/ubuntu noble-security InRelease              
Obj:6 https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/noble pgadmin4 InRelease
Leyendo lista de paquetes... Hecho                  
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
Se pueden actualizar 26 paquetes. Ejecute «apt list --upgradable» para verlos.
```
Y por último, acabaremos de instalar pgAdmin4 en modo web para el entorno no gráfico de nuestra M.Servidor. De esta manera podremos acceder desde cualquier navegador, y como podemos conectarnos por SSH a nuestra M.Servidor con nuestra M.Cliente, podremos acceder al modo gráfico a través del navegador.
```bash
isard@jaguilera-server:~$ sudo apt install -y pgadmin4-web
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
El paquete indicado a continuación se instaló de forma automática y ya no es necesario.
  python3-debian
…
```
Esto instala los archivos del servidor web, los de configuración y un script de configuración inicial que ahora iniciaremos.
Durante la instalación nos pedirá un correo electrónico [jaguilera@institutmvm.cat] y una contraseña de más de 6 caracteres [jaguilera] que nos servirá como usuario de acceso. 
```bash
isard@jaguilera-server:~$ sudo /usr/pgadmin4/bin/setup-web.sh
Setting up pgAdmin 4 in web mode on a Debian based platform...
Creating configuration database...
/usr/pgadmin4/venv/lib/python3.12/site-packages/passlib/pwd.py:16: UserWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html. The pkg_resources package is slated for removal as early as 2025-11-30. Refrain from using this package or pin to Setuptools<81.
  import pkg_resources
NOTE: Configuring authentication for SERVER mode.

Enter the email address and password to use for the initial pgAdmin user account:

Email address: jaguilera@institutmvm.cat
Password: 
Retype password:
Password must be at least 6 characters. Please try again.
Password: 
Retype password:
pgAdmin 4 - Application Initialisation
======================================

Creating storage and log directories...
We can now configure the Apache Web server for you. This involves enabling the wsgi module and configuring the pgAdmin 4 application to mount at /pgadmin4. Do you wish to continue (y/n)? y
The Apache web server is running and must be restarted for the pgAdmin 4 installation to complete. Continue (y/n)? y
Apache successfully restarted. You can now start using pgAdmin 4 in web mode at http://127.0.0.1/pgadmin4
```
Una vez completado habremos configurado el entorno web, creado un usuario administrador y registrado pgAdmin4 como servicio web. Y ahora que ya lo tenemos instalado abriremos desde el navegador e iniciaremos sesión con el correo y contraseña que hemos indicado en la configuración inicial:

**http://192.168.1.30/pgadmin4**

Una vez aquí, deberemos registrar el servidor de PostgreSQL a pgAdmin para poder administrarlo desde la interfaz gráfica.

Debermos hacer clic en **Agregar un Nuevo Servidor**.

![Captura1](./imágenes/1.png)

E indicar un nombre para identificarlo, la dirección IP del servidor y un usuario con contraseña. En este caso, nos decantarermos por usar el usuario **postgres** porque ya existe por defecto, tiene todos los permisos necesarios y está habilitado para conexiones locales y remotas. A fin de no complicarnos, es la mejor opción. De la misma manera, la contraseña también será **postgres** para no olvidarnos.

![Captura2](./imágenes/2.png)
![Captura3](./imágenes/3.png)

Y ahora comprobaremos que funciona mostrando gráficamente algunos de los datos de alguna de las tablas.
> [!NOTE]
> Para que se muestren los registros en la parte derecha, deberemos hacer clic derecho sobre la tabla que queramos y de nuevo clic en **Ver/Editar Datos**.

![Captura4](./imágenes/4.png)

---

## Cuarta parte: Cliente (DBeaver)

---

En esta cuarta parte vamos a instalar el software DBeaver, un cliente universal para bases de datos que nos va a permitir conectar y administrar PostgreSQL, entre muchos otros motores como MySQL o MariaDB desde una interfaz gráfica. En este caso vamos a instalar la Community Edition en modo escritorio, que será suficiente, y mediante el repositorio oficial de DBeaver porque disponemos de entorno gráfico y porque de esta manera nos garantizamos que el paquete es seguro, se puede actualizar automáticamente junto con el sistema y evitamos errores de compatibilidad con versiones manuales.

De igual manera que hemos hecho con el servidor en el punto anterior, aquí también vamos a actualizar el sistema previo a los siguientes comandos.
```bash
alumne@jaguilera:~$ sudo apt update
```
Dicho esto, vamos a añadir la clave del repositorio de DBeaver para que verifique la firma de los paquetes que se descargan del sitio oficial.
```bash
alumne@jaguilera:~$ wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/dbeaver.gpg
--2025-11-12 01:04:53--  https://dbeaver.io/debs/dbeaver.gpg.key
S'està resolent dbeaver.io (dbeaver.io)… 209.38.51.239, 2604:a880:800:14:0:1:958:c000
S'està connectant a dbeaver.io (dbeaver.io)|209.38.51.239|:443… conectat.
HTTP: s'ha enviat la petició, s'està esperant una resposta… 200 OK
Mida: 3120 (3,0K) [application/octet-stream]
S'està desant a: ‘STDOUT’

-                                                  100%[================================================================================================================>]   3,05K  --.-KB/s    in 0s      

2025-11-12 01:04:53 (684 MB/s) - escrit a la sortida estàndard [3120/3120]
```
Ahora añadimos el repositorio oficial creando el archivo **.list** para luego poder hacer la instalación.
```bash
alumne@jaguilera:~$ echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
deb [signed-by=/usr/share/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /

Actualizamos los repositorios e instalamos DBeaver.
```
```bash
alumne@jaguilera:~$ sudo apt update
sudo apt install -y dbeaver-ce
Obj:1 http://security.ubuntu.com/ubuntu jammy-security InRelease
Obj:2 http://apt.postgresql.org/pub/repos/apt jammy-pgdg InRelease                                              
Ign:3 https://ppa.launchpadcontent.net/otto-kesselgulasch/gimp/ubuntu jammy InRelease                                                                         
Err:4 https://ppa.launchpadcontent.net/otto-kesselgulasch/gimp/ubuntu jammy Release                                                                           
  404  Not Found [IP: 185.125.190.80 443]
Bai:5 https://dbeaver.io/debs/dbeaver-ce  InRelease [2.086 B]                                
Bai:6 https://dbeaver.io/debs/dbeaver-ce  Packages [460 B]                        
Obj:7 http://de.archive.ubuntu.com/ubuntu jammy InRelease
Obj:8 http://de.archive.ubuntu.com/ubuntu jammy-updates InRelease
Obj:9 http://de.archive.ubuntu.com/ubuntu jammy-backports InRelease
S'està llegint la llista de paquets… Fet
E: El dipòsit «https://ppa.launchpadcontent.net/otto-kesselgulasch/gimp/ubuntu jammy Release» ja no té un fitxer Release.
N: No es pot actualitzar des d'un dipòsit com aquest de forma segura i per tant està desactivat per defecte.
N: Consulteu la pàgina de manual apt-secure(8) per obtenir detalls sobre la creació de dipòsits i la configuració d'usuaris.
N: S'omet l'ús del fitxer configurat «main/binary-i386/Packages» ja que el dipòsit «http://apt.postgresql.org/pub/repos/apt jammy-pgdg InRelease» no admet l'arquitectura «i386»
S'està llegint la llista de paquets… Fet 
S'està construint l'arbre de dependències… Fet
S'està llegint la informació de l'estat… Fet  
S'instal·laran els paquets NOUS següents:
  dbeaver-ce
0 actualitzats, 1 nous a instal·lar, 0 a suprimir i 23 no actualitzats.
S'ha d'obtenir 126 MB d'arxius.
Després d'aquesta operació s'utilitzaran 212 MB d'espai en disc addicional.
Bai:1 https://dbeaver.io/debs/dbeaver-ce  dbeaver-ce 25.2.4 [126 MB]
S'ha baixat 126 MB en 24s (5.358 kB/s)                                                                                                                                                                     
S'està seleccionant el paquet dbeaver-ce prèviament no seleccionat.
(S'està llegint la base de dades… hi ha 228507 fitxers i directoris instal·lats actualment.)
S'està preparant per a desempaquetar …/dbeaver-ce_25.2.4_amd64.deb…
S'està desempaquetant dbeaver-ce (25.2.4)…
S'està configurant dbeaver-ce (25.2.4)…
S'estan processant els activadors per a desktop-file-utils (0.26-1ubuntu3)…
S'estan processant els activadors per a gnome-menus (3.36.0-1ubuntu3)…
S'estan processant els activadors per a mailcap (3.70+nmu1ubuntu1)…
```
Ahora que ya está instalado y que nuestra M.Cliente posee entorno gráfico, vamos a nuestras aplicaciones y lo abrimos, o bien mediante terminal llamando con:
```bash
dbeaver
```
A continuación crearemos la conexión con nuestro servidor PostgreSQL.
Primero debemos presionar **Shift + Ctrl + N** y seleccionar **PostgreSQL**.

![Captura5](./imágenes/5.png)

A continuación rellenaremos los siguientes campos, indicando en el nombre de **host** la IP de nuestro servidor, **postgres** como la base de datos genérica y marcando la casilla de **mostrar todas las bases de datos** y **postgres** como usuario y contraseña, de la misma manera que hemos hecho anteriormente con pgAdmin4.

![Captura6](./imágenes/6.png)

Ahora finalizaremos la configuración para establecer conexión. Haremos clic en el nombre de nuestra base de datos con la IP correspondiente y descargaremos los archivos.

![Captura7](./imágenes/7.png)

Por último, comprobaremos que funciona correctamente con alguna consulta a la base de datos **dvdrental**.

> [!NOTE]
>  Para que se muestren los registros en la parte derecha, deberemos hacer clic derecho sobre la tabla que queramos y de nuevo clic en **View Table**.

![Captura8](./imágenes/8.png)

---

# Quinta parte: Preguntas

---

### 1. ¿PostgreSQL es un SGBD centralizado o cliente/servidor?

---

Partiendo de la base de lo que es un sistema cliente/servidor, en el que un servidor central ofrece un servicio y uno o varios clientes se conectan a él para usar dicho servicio, podemos decir que PostgreSQL actúa de ésta manera, por lo que es un sistema de base de datos cliente/servidor.

En este caso el servidor (en nuestro caso jaguilera-server en la dirección 192.168.1.30), donde se instala PostgreSQL-server, y escucha peticiones (por defecto a través del puerto 5432). Por otro lado, los clientes son los usuarios que se conectan al servidor para usar las bases de datos, ya sea a través de la terminal con psql local o remoto, o a través de aplicaciones con entorno gráfico como las que hemos instalado.

---

### 2. ¿Se trata de un sistema de 2 o 3 capas?

---

PostgreSQL podríamos considerarlo como un sistema de 3 capas:
- Capa del cliente o de presentación: Es la que interactúa con el usuario ya que se le muestra la información y es donde se reflejan las propias acciones. Por ejemplo, podría ser la aplicación de DBeaver o un mismo cliente por terminal con psql.
- Capa del servidor o de base de datos: Es la que actúa como almacenamiento de los datos  y quien recibe las consultas SQL y gestiona los datos para devolver los resultados. En este caso, sería PostgreSQL.
- Capa SQL o de lenguaje de consulta: Es la que emplea SQL como el intermediario o traductor entre las otras dos capas. Es decir, es el medio a través del cual el cliente se comunica con el servidor de la base de datos.

---

## Enlaces de interés

---

https://docs.oracle.com/es-ww/iaas/Content/postgresql/import-export-migrate.htm 
https://www.dbvis.com/thetable/restoring-a-postgresql-backup-with-pg_restore-examples-tips-and-tricks/#:~:text=pg_restore%20is%20a%20command%2Dline,the%20time%20of%20the%20dump 
https://www.pgadmin.org/download/pgadmin-4-apt/ 
https://www.digitalocean.com/community/tutorials/how-to-install-configure-pgadmin4-server-mode-es
https://medium.com/yavar/install-and-configure-postgresql-and-pgadmin-on-ubuntu-20-04-22-04-52c52c249b9e 
https://www.ochobitshacenunbyte.com/2019/03/27/como-instalar-dbeaver-en-ubuntu-18-04/ 
https://www.youtube.com/watch?v=y-0d2kJBR_I
https://insightsoftware.com/es/blog/5-benefits-of-a-3-tier-architecture/ 
https://www.ibm.com/es-es/think/topics/three-tier-architecture 
