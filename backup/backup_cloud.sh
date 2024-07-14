#!/bin/bash

# Parametros
CURR_DATE=$(date +"%Y_%m_%d_%H-%M")

DIR_TO_BACKUP="/home/ubuntu/server"
ZIP_FILE="/home/ubuntu/backups/yeeland_backup_$CURR_DATE.zip"

CLOUD_SERVICE="mega"
CLOUD_DIR="Backups"

# Usar configuracion de rclone del usuario ubuntu
RCLONE_CONFIG_PATH="/home/ubuntu/.config/rclone/rclone.conf"
export RCLONE_CONFIG=$RCLONE_CONFIG_PATH

# Funcion para obtener la fecha y hora actuales en el formato deseado
timestamp() {
    date +"[%d-%m-%Y %H:%M:%S]"
}

# Verificar si el directorio a comprimir existe
check_directory() {
    if [ ! -d "$DIR_TO_BACKUP" ]; then
        echo "$(timestamp) Error: el directorio $DIR_TO_BACKUP no existe"
        exit 1
    fi
}

# Comprimir el directorio
compress_directory() {
    zip -r $ZIP_FILE $DIR_TO_BACKUP > /dev/null # Refdirigir salida para que no salga en el log
    if [ $? -ne 0 ]; then
        echo "$(timestamp) Error al comprimir el directorio"
        exit 1
    fi
}

# Verificar si rclone esta configurado correctamente
check_remote() {
    if ! rclone listremotes | grep -q "^$CLOUD_SERVICE:"; then
        echo "$(timestamp) Error: rclone no tiene configurada la remota '$CLOUD_SERVICE'"
        exit 1
    fi
}

# Subir el archivo al servicio de almacenamiento en la nube
upload_to_cloud() {
    rclone copy $ZIP_FILE $CLOUD_SERVICE:$CLOUD_DIR/
    if [ $? -ne 0 ]; then
        echo "$(timestamp) Error al subir el archivo a $CLOUD_SERVICE"
        exit 1
    fi
}

# Eliminar el archivo comprimido localmente
delete_local_zip() {
    rm $ZIP_FILE
    if [ $? -ne 0 ]; then
        echo "$(timestamp) Error al eliminar el archivo comprimido localmente"
        exit 1
    fi
}

# Mantener solo los ultimos 3 backups
cleanup_old_backups() {
    BACKUP_DIR="$CLOUD_SERVICE:$CLOUD_DIR"
    BACKUPS=$(rclone lsf $BACKUP_DIR | grep backup | sort)
    BACKUP_COUNT=$(echo "$BACKUPS" | wc -l)

    if [ $BACKUP_COUNT -gt 3 ]; then
        OLDEST_BACKUP=$(echo "$BACKUPS" | head -n 1)
        rclone delete "$BACKUP_DIR/$OLDEST_BACKUP"

        if [ $? -ne 0 ]; then
            echo "$(timestamp) Error al eliminar el backup más antiguo en $CLOUD_SERVICE"
            exit 1
        fi
    fi

    # Vaciar la papelera
    rclone cleanup $CLOUD_SERVICE:
    if [ $? -ne 0 ]; then
        echo "$(timestamp) Error al vaciar la papelera en $CLOUD_SERVICE"
        exit 1
    fi
}

# Ejecucion del script
check_directory
compress_directory
check_remote
upload_to_cloud
delete_local_zip
cleanup_old_backups
echo "$(timestamp) Backup y subida completados exitosamente"
