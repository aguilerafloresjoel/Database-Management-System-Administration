[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/_l7mEXZI)
# ACTIVIDAD 1 - POSTGRESQL 18

---
## INSTALACIÓN DE POSTGRESQL 18
---

En primer lugar vamos a cambiar el nombre predeterminado del host de la M.Servidor por uno que nos identifique con el siguiente comando:
```bash
isard@ubuntu-server:~$ sudo hostnamectl set-hostname jaguilera-server
```
Para poder ver el cambio de nombre deberemos reiniciar el servidor con:
```bash
isard@ubuntu-server:~$ reboot
```

### REPOSITORIOS 
---

Gracias a los comandos de la página oficial de Postgresql https://www.postgresql.org/download/linux/ubuntu/ vamos a instalar los repositorios necesarios de manera manual para asegurarnos de que son los últimos hasta la fecha.

Primero importamos la clave que firma el repositorio con:
```bash
isard@jaguilera-server:~$ sudo apt install curl ca-certificates
```
```bash
isard@jaguilera-server:~$ sudo install -d /usr/share/postgresql-common/pgdg
```
```bash
isard@jaguilera-server:~$ sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
```

Continuamos creando el archivo de configuración del repositorio con:
```bash
isard@jaguilera-server:~$ . /etc/os-release
```
```bash
isard@jaguilera-server:~$ sudo sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
```
Ahora actualizamos la lista de paquetes con:
```bash
isard@jaguilera-server:~$ sudo apt update
```
---

### INSTALACIÓN EN M.SERVIDOR
----

Y cumplidos los pasos anteriores ahora sí que podemos proceder a hacer la instalación de PostgreSQL con la versión que nosotros queramos.
En nuestro caso, dado que estamos haciendo la instalación en un servidor y queremos que tenga esa función, haremos uso del comando:
```bash
isard@jaguilera-server:~$ sudo apt install postgresql-18
```


> [!TIP]
> Acabada la instalación, siempre es recomendable para evitar errores inesperados, comprobar que la instalación ha sido exitosa y que el servicio está activado:

Lo haremos con el comando:
```bash
isard@jaguilera-server:~$ sudo systemctl status postgresql
```
Y si todo es correcto, deberá aparecernos este texto de vuelta, con las palabras clave en color verde.
```bash
isard@jaguilera-server:~$ sudo systemctl status postgresql
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/usr/lib/systemd/system/postgresql.service; enabled; preset: enable>
     Active: active (exited) since Mon 2025-10-20 15:02:47 UTC; 18min ago
    Process: 918 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
   Main PID: 918 (code=exited, status=0/SUCCESS)
        CPU: 4ms

oct 20 15:02:47 jaguilera-server systemd[1]: Starting postgresql.service - PostgreSQL RD>
oct 20 15:02:47 jaguilera-server systemd[1]: Finished postgresql.service - PostgreSQL RD>
lines 1-9/9 (END)
```
Ahora si queremos acceder al servicio, haremos uso del comando:
```bash
isard@jaguilera-server:~$ sudo -i -u postgres
```
Y esto nos dará acceso como usuario postgres. Una vez en este usuario, podremos arrancar el servicio con el comando:
```bash
ipostgres@jaguilera-server:~$ psql
psql (18.0 (Ubuntu 18.0-1.pgdg24.04+3))
Digite «help» para obtener ayuda.

postgres=# 
```

---
# CONECTAR AL SERVICIO POSTGRESQL 18 DESDE UNA MÁQUINA CLIENTE
---

Para poder conectar desde una máquina cliente al servicio de Postgresql 18 de nuestro servidor, lo primero que deberemos hacer es establecer tanto a nuestro cliente como a nuestro servidor una IP fija para que no vaya variando por DHCP y las configuraciones que vayamos a hacer, sólo nos sirvan para esa misma sesión en la que hacemos las configuraciones.

> [!IMPORTANT]
> Pero estos pasos, nos los vamos a saltar y vamos a suponer que ya se saben hacer. Eso sí, estableceremos en nuestro caso que las IP’s son las siguientes:
>
> M. Servidor → 192.168.1.30 |
> M. Cliente → 192.168.1.31

---
## PASOS EN LA M.CLIENTE
---

Hechos estos pasos previos, vamos a la M.Cliente y vamos a actualizar los repositorios con el comando:
```bash
isard@jaguilera-server:~$ sudo apt update && upgrade
```
> [!TIP]
> El uso de este comando siempre es recomendable antes de proceder a la instalación de algún paquete, servicio, etc.
En nuestro caso, para no tener que depender del uso de SSH conectando con nuestra M.Servidor, vamos a instalar el servicio en nuestra M.Cliente y posteriormente desde los archivos de configuración de la M.Servidor, le daremos acceso.

Dicho esto, vamos a instalar el servicio de manera automática con los siguientes comandos:
```bash
alumne@jaguilera:~$ sudo apt install -y postgresql-common
```
```bash
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
```
Nos solicitará la contraseña para proceder y aparecerán distintas líneas mientras se descargan los repositorios.
```bash
[sudo] contrasenya per a alumne:
S'està llegint la llista de paquets… Fet
S'està construint l'arbre de dependències… Fet
S'està llegint la informació de l'estat… Fet  
El paquets següents s'han instal·lat automàticament i ja no són necessaris:
  linux-headers-5.19.0-32-generic linux-hwe-5.19-headers-5.19.0-32
  linux-image-5.19.0-32-generic linux-modules-5.19.0-32-generic
  linux-modules-extra-5.19.0-32-generic
Empreu «sudo apt autoremove» per a suprimir-los.
S'instal·laran els següents paquets extres:
  libcommon-sense-perl libjson-perl libjson-xs-perl libtypes-serialiser-perl
  postgresql-client-common
S'instal·laran els paquets NOUS següents:
  libcommon-sense-perl libjson-perl libjson-xs-perl libtypes-serialiser-perl
  postgresql-client-common postgresql-common
0 actualitzats, 6 nous a instal·lar, 0 a suprimir i 0 no actualitzats.
S'ha d'obtenir 400 kB d'arxius.
Després d'aquesta operació s'utilitzaran 1.438 kB d'espai en disc addicional.
Bai:1 http://de.archive.ubuntu.com/ubuntu jammy/main amd64 libcommon-sense-perl amd64 3.75-2build1 [21,1 kB]
Bai:2 http://de.archive.ubuntu.com/ubuntu jammy/main amd64 libjson-perl all 4.04000-1 [81,8 kB]
```
…

En este punto, dejarán de aparecer líneas y deberemos presionar la tecla “ENTER” para acabar.
```bash
Press Enter to continue, or Ctrl-C to abort.

Writing /etc/apt/sources.list.d/pgdg.list ...
Importing repository signing key ...
Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
OK

Running apt-get update ...
Bai:1 http://apt.postgresql.org/pub/repos/apt jammy-pgdg InRelease [107 kB]
Obj:2 http://de.archive.ubuntu.com/ubuntu jammy InRelease                 	 
Obj:3 http://de.archive.ubuntu.com/ubuntu jammy-updates InRelease         	 
Obj:4 http://de.archive.ubuntu.com/ubuntu jammy-backports InRelease       	 
Obj:5 http://security.ubuntu.com/ubuntu jammy-security InRelease          	 
Bai:6 http://apt.postgresql.org/pub/repos/apt jammy-pgdg/main amd64 Packages [395 kB]
S'ha baixat 502 kB en 1s (532 kB/s)
S'està llegint la llista de paquets… Fet
N: S'omet l'ús del fitxer configurat «main/binary-i386/Packages» ja que el dipòsit «http://apt.postgresql.org/pub/repos/apt jammy-pgdg InRelease» no admet l'arquitectura «i386»

You can now start installing packages from apt.postgresql.org.

Have a look at https://wiki.postgresql.org/wiki/Apt for more information;
most notably the FAQ at https://wiki.postgresql.org/wiki/Apt/FAQ
alumne@jaguilera:~$
```
Con esto, hebremos actualizado los repositorios y todos los archivos de configuración y con el siguiente comando haremos la instalación de Postgresql 18, pero en este caso, la versión cliente:
```bash
alumne@jaguilera:~$ sudo apt install postgresql-client-18
S'està llegint la llista de paquets… Fet
S'està construint l'arbre de dependències… Fet
S'està llegint la informació de l'estat… Fet  
El paquets següents s'han instal·lat automàticament i ja no són necessaris:
  linux-headers-5.19.0-32-generic linux-hwe-5.19-headers-5.19.0-32
  linux-image-5.19.0-32-generic linux-modules-5.19.0-32-generic
  linux-modules-extra-5.19.0-32-generic
Empreu «sudo apt autoremove» per a suprimir-los.
S'instal·laran els següents paquets extres:
  libpq5
Paquets suggerits:
  libpq-oauth postgresql-18 postgresql-doc-18
S'instal·laran els paquets NOUS següents:
  libpq5 postgresql-client-18
0 actualitzats, 2 nous a instal·lar, 0 a suprimir i 2 no actualitzats.
S'ha d'obtenir 2.335 kB d'arxius.
Després d'aquesta operació s'utilitzaran 11,6 MB d'espai en disc addicional.
```
Aquí de nuevo dejarán de aparecer líneas hasta que indiquemos que sí queremos continuar. 
```bash
Voleu continuar? [S/n] s
Bai:1 http://apt.postgresql.org/pub/repos/apt jammy-pgdg/main amd64 libpq5 amd64 18.0-1.pgdg22.04+3 [249 kB]
Bai:2 http://apt.postgresql.org/pub/repos/apt jammy-pgdg/main amd64 postgresql-client-18 amd64 18.0-1.pgdg22.04+3 [2.086 kB]
S'ha baixat 2.335 kB en 0s (33,6 MB/s)     	 
S'està seleccionant el paquet libpq5:amd64 prèviament no seleccionat.
(S'està llegint la base de dades… hi ha 256537 fitxers i directoris instal·lats
actualment.)
S'està preparant per a desempaquetar …/libpq5_18.0-1.pgdg22.04+3_amd64.deb…
S'està desempaquetant libpq5:amd64 (18.0-1.pgdg22.04+3)…
S'està seleccionant el paquet postgresql-client-18 prèviament no seleccionat.
S'està preparant per a desempaquetar …/postgresql-client-18_18.0-1.pgdg22.04+3_a
md64.deb…
S'està desempaquetant postgresql-client-18 (18.0-1.pgdg22.04+3)…
S'està configurant libpq5:amd64 (18.0-1.pgdg22.04+3)…
S'està configurant postgresql-client-18 (18.0-1.pgdg22.04+3)…
update-alternatives: s'està emprant /usr/share/postgresql/18/man/man1/psql.1.gz
per a proveir /usr/share/man/man1/psql.1.gz (psql.1.gz) en mode automàtic
S'estan processant els activadors per a postgresql-common (238)…
Building PostgreSQL dictionaries from installed myspell/hunspell packages...
  ca
  ca_es-valencia
  en_au
  en_ca
  en_gb
  en_us
  en_za
  es_es
Removing obsolete dictionary files:
S'estan processant els activadors per a libc-bin (2.35-0ubuntu3.11)…
alumne@jaguilera:~$
```
Y cuando dejen de aparecer líneas, será signo de que la instalación se ha completado.

No obstante, deberemos comprobar que el servicio está activo con el comando anterior:
```bash
alumne@jaguilera:~$ sudo systemctl status postgresql
[sudo] contrasenya per a alumne: 
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: ena>
     Active: active (exited) since Mon 2025-10-20 17:02:52 CEST; 54min ago
   Main PID: 571 (code=exited, status=0/SUCCESS)
        CPU: 1ms

oct 20 17:02:52 jaguilera systemd[1]: Starting PostgreSQL RDBMS...
oct 20 17:02:52 jaguilera systemd[1]: Finished PostgreSQL RDBMS.
lines 1-8/8 (END)
```

---
## PASOS EN LA M.SERVIDOR
---

Ahora pasamos a la M.Servidor de nuevo, pues será aquí donde debamos modificar algunos archivos de configuración para permitirle a la M.Cliente la conexión remota a nuestras bases de datos. De esta manera, un trabajador (M.Cliente) podría trabajar en la base de datos de su empresa (M.Servidor) desde su casa.

Dicho esto, a continuación nos dirigiremos desde la terminal al archivo de configuración general **/etc/postgresql/18/main/postgresql.conf** y estableceremos la escucha remota descomentando si está comentada esta línea, y escribiendo la IP fija que previamente le hemos establecido a nuestra M.Servidor **(192.168.1.30)**.
> [!NOTE]
>En este caso, en esa misma línea, podríamos escribir un * en lugar de la IP y establecería una escucha remota a cualquier IP.

Así encontramos el archivo sin modificaciones en las líneas que nos importan:
```bash
#------------------------------------------------------------------------------
# CONNECTIONS AND AUTHENTICATION
#------------------------------------------------------------------------------

# - Connection Settings -

#listen_addresses = 'localhost'         # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)
port = 5432                             # (change requires restart)
max_connections = 100                   # (change requires restart)
```

Y así es como dejamos el archivo tras la edición:

```bash
#------------------------------------------------------------------------------
# CONNECTIONS AND AUTHENTICATION
#------------------------------------------------------------------------------

# - Connection Settings -

listen_addresses = '192.168.1.30'       # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)
port = 5432                             # (change requires restart)
max_connections = 100                   # (change requires restart)
```

Guardaremos y reiniciaremos el servicio con:
```bash
isard@jaguilera-server:~$ sudo systemctl restart postgresql@18-main
```
A continuación nos iremos al archivo de configuración de autenticación remota **/etc/postgresql/18/main/pg_hba.conf** y tendremos que añadir lo siguiente...

Así nos encontramos el archivo en las líneas que nos importan, sin la edición que vamos a ejecutar:

```bash
# TYPE  DATABASE        USER            ADDRESS                 METHOD

```

Y así después de la edición:

```bash
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             192.168.1.30/32         md5  
```

> [!NOTE]
> Aquí, igual que antes, si en lugar de poner la IP de solo nuestra máquina cliente, pusiéramos 0.0.0.0/24, le estaríamos dando acceso a todas las IP’s.

Una vez modificado, guardaremos la edición del archivo y reiniciaremos el servicio con:
```bash
isard@jaguilera-server:~$ sudo systemctl restart postgresql@18-main
```
A continuación vamos a crear un usuario y una base de datos para el cliente. Para ello, cambiaremos al usuario postgres con **sudo -i -u postgres** y seguido de **psql** para iniciar el servicio. 
```bash
isard@jaguilera-server:~$ sudo -i -u postgres
postgres@jaguilera-server:~$ psql
psql (18.0 (Ubuntu 18.0-1.pgdg24.04+3))
Digite «help» para obtener ayuda.
```

Una vez dentro del servicio de Postgresql 18, crearemos un usuario y contraseña con el que podremos entrar desde cualquier máquina que tenga acceso:
```bash
postgres=# CREATE USER cliente_joel WITH PASSWORD 'joel';
CREATE ROLE
```

Realizado el paso anterior, vamos con la creación de una base de datos de prueba:

```bash
postgres=# CREATE DATABASE mvm_asgbd_joel OWNER cliente_joel;
CREATE DATABASE
```

Y ahora le daremos todo tipo de permisos al usuario que hemos creado para la base de datos que también hemos creado: 

>[!WARNING]
> En este caso le damos todos los permisos porque es una prueba, pero de normal, en función del puesto de la persona, se le debería de asignar un rol u otro y eso conlleva tener más o menos permisos para ejecutar en la base de datos.
```bash
postgres=# GRANT ALL PRIVILEGES ON DATABASE mvm_asgbd_joel TO cliente_joel;
GRANT
GRANT
```

Acto seguido, pasaremos a la creación de una tabla para la base de datos, aunque para ello primero deberemos acceder así:
```bash
postgres-# \c mvm_asgbd_joel
Ahora está conectado a la base de datos «mvm_asgbd_joel» con el usuario «postgres».
mvm_asgbd_joel-# 
```
Ahora que ya estamos dentro, con el siguiente comando crearemos la tabla con el nombre que le digamos:
```sql
mvm_asgbd_joel=# CREATE TABLE mascotas (
    id INTEGER PRIMARY KEY,
    numero_chip INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    descripcion TEXT
);
CREATE TABLE
```
La tabla ha sido creada con éxito y ahora vamos a insertar una serie de registros para llenar un poco esa tabla:
```sql
mvm_asgbd_joel=# INSERT INTO mascotas (id, numero_chip, nombre, especie, descripcion) VALUES
(1, 1001, 'Luna', 'Gato', 'Gato gris de 3 años, muy juguetón'),
(2, 1002, 'Max', 'Perro', 'Perro labrador de 5 años, amigable'),
(3, 1003, 'Mía', 'Gato', 'Gato blanco de 2 años, tranquilo'),
(4, 1004, 'Rocky', 'Perro', 'Perro pastor alemán de 4 años, activo'),
(5, 1005, 'Nala', 'Gato', 'Gato atigrado de 1 año, curioso');
INSERT 0 5
```
Podemos ver esos registros con:
```sql
mvm_asgbd_joel=# SELECT * FROM mascotas;
 id | numero_chip | nombre | especie |              descripcion              
----+-------------+--------+---------+---------------------------------------
  1 |        1001 | Miau   | Gato    | Gato gris de 3 años, araña mucho
  2 |        1002 | Max    | Perro   | Perro labrador de 5 años, amigable
  3 |        1003 | Garfield    | Gato    | Gato blanco de 2 años, tranquilo
  4 |        1004 | Rocky  | Perro   | Perro pastor alemán de 8 años, activo
  5 |        1005 | Botas   | Gato    | Gato atigrado de 1 año, curioso
(5 filas)
```
Y modificar la tabla con estos comandos:
```sql
mvm_asgbd_joel=# UPDATE mascotas SET descripcion = 'Gato gris de 3 años, cariñoso' WHERE id = 1;
UPDATE 1
mvm_asgbd_joel=# UPDATE mascotas SET nombre = 'Guau' WHERE id = 4;
UPDATE 1
```
O borrar con este otro:
```sql
mvm_asgbd_joel=# DELETE FROM mascotas WHERE id = 5;
DELETE 1
```
Y para ver los cambios que se han producido en la tabla tras esta modificaciones podemos volver a usar:
```sql
mvm_asgbd_joel=# SELECT * FROM mascotas;
 id | numero_chip | nombre | especie |              descripcion              
----+-------------+--------+---------+---------------------------------------
  2 |        1002 | Max    | Perro   | Perro labrador de 5 años, amigable
  3 |        1003 | Garfield    | Gato    | Gato blanco de 2 años, tranquilo
  1 |        1001 | Miau   | Gato    | Gato gris de 3 años, cariñoso
  4 |        1004 | Guau   | Perro   | Perro pastor alemán de 8 años, activo
(4 filas)
```

Ahora, antes de verificar si el cliente puede acceder a la base de datos que acabamos de crear, vamos a asegurarnos de que el firewall no nos dará ningún problema, habilitando el puerto por defecto que es el *5432* con:

```bash
isard@jaguilera-server:~$ sudo ufw allow from 192.168.1.31 to any port 5432 proto tcp
Skipping adding existing rule
isard@jaguilera-server:~$ sudo ufw reload
Firewall not enabled (skipping reload)
isard@jaguilera-server:~$ sudo ufw status
Status: inactive
```
En nuestro caso está desactivado, y aunque esto podría suponer un riesgo para nuestra M.Servidor, dado que es una prueba, lo dejaremos así.

---
## COMPROBACIÓN DE ACCESO DESDE EL CLIENTE
---

Ahora que hemos instalado el servicio en la M.Servidor, en la M.Cliente, que hemos modificado los archivos de configuración en la M.Servidor para darle acceso a la M.Cliente, que hemos creado un usuario y una contraseña y una base de datos con algunos registros… Podemos probar de acceder a dicha base de datos de manera remota desde la M.Cliente:
```bash
alumne@jaguilera:~$ psql -h 192.168.1.30 -p 5432 -U cliente_joel -d mvm_asgbd_joel
Password for user cliente_joel: 
psql (18.0 (Ubuntu 18.0-1.pgdg22.04+3))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off, ALPN: postgresql)
Type "help" for help.

mvm_asgbd_joel=> 
```
Y ahora sí que sí, podemos decir que lo hemos logrado.

---
## ENLACES DE INTERÉS Y CONSULTA
---

https://www.youtube.com/watch?v=HKfhKnmIFLU 
https://dev.to/topeogunleye/how-to-install-postgresql-18-on-ubuntu-2404-1doc
https://www.postgresql.org/download/linux/ubuntu/
https://www.hostinger.com/es/tutoriales/instalar-postgresql-ubuntu#6_Crea_una_base_de_datos_en_PostgreSQL
https://voidnull.es/habilitar-acceso-remoto-en-postgresql/
