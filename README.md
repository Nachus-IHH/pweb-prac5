repo:
https://github.com/Nachus-IHH/pweb-prac5

El proyecto se divide en 3 partes

- servicioweb: es donde se tiene el back, lo **importante** aqui es clsservicios (clase con metodos que ejecuta el backend) y connection (conexion a la bd ya sea de forma local/.env o en qa/prod que usa vars de entorno a nivel maquina)
- sitioweb: frontend
- db: scripts de la database, aqui lo he hecho mal por que todo parte de V1__initial_schema.sql y si se tienen que modificar tablas se crean nuevos archivos como alter tables y demas, solo que en este caso excepcional de que la mayoria estaba en mayusculas -> minusculas opte por esto de V2__initial_schema.sql, no se que tan bien sea esto y si haya mejores formas para esto, estos tipos de archivos ahora los hago por que ando viendo Flyway que es para versionado y migracion de bases de datos, como git pero en lugar de code para db
