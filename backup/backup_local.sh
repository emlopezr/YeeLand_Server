#!/bin/bash

# Funcion para obtener la fecha y hora actuales en el formato deseado
timestamp() {
    date +"[%d-%m-%Y %H:%M:%S]"
}

# Fecha actual para el nombre del archivo
DATE=$(date +"%Y-%m-%d_%H-%M")

# Directorio a comprimir
DIR_TO_BACKUP="/home/ubuntu/server"

# Archivo comprimido
ZIP_FILE="/home/ubuntu/backups/yeeland_backup_$DATE.zip"

# Verificar si el directorio a comprimir existe
if [ ! -d "$DIR_TO_BACKUP" ]; then
  echo "$(timestamp) Error: el directorio $DIR_TO_BACKUP no existe."
  exit 1
fi

# Comprimir el directorio
zip -r $ZIP_FILE $DIR_TO_BACKUP
if [ $? -ne 0 ]; then
  echo "$(timestamp) Error al comprimir el directorio."
  exit 1
fi

echo "$(timestamp) Backup y realizado exitosamente."
