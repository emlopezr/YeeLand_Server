# YeeLand Server Scripts 🖥️

Shell scripts utilitarios para el servidor de Minecraft YeeLand hospedado en Oracle Cloud. Estos scripts son accionados por el crontab de Ubuntu, el archivo de configuración de este se encuentra en `/crontab/sudo_crontab.sh`

- Hacer un backup completo del servidor en `.zip` y subirlo a un servicio en la nube
- Cada pocos minutos verificar si el servidor está corriendo, en caso de que no, levanta el servidor en un `screen`.
