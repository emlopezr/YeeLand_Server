#!/bin/bash

# Configuracion
SCREEN_NAME="server"
SERVER_DIR="server"
SERVER_JAR="server.jar"
JAVA_OPTS="-Xms16384M -Xmx16384M --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -Dfml.readTimeout=90"

# Funcion para obtener la fecha y hora actuales en el formato deseado
timestamp() {
    date +"[%d-%m-%Y %H:%M:%S]"
}

# Funcion para verificar el estado del servidor
check_server_status() {
    # Verificar si el servidor esta escuchando en el puerto 25565
    nc -z localhost 25565
    if [ $? -eq 0 ]; then
        echo "$(timestamp) El servidor de Minecraft esta activo en el puerto 25565."
    else
        echo "$(timestamp) El servidor de Minecraft no estaba activo. Reiniciando..."
        restart_server
    fi
}

# Funcionn para reiniciar el servidor dentro de la screen
restart_server() {

    # Verificar si la sesion de screen existe
    screen -list | grep -q "\.${SCREEN_NAME}\s"
    if [ $? -eq 0 ]; then
        # Si la sesion de screen existe, cerrarla
        echo "$(timestamp) Cerrando la sesion de screen existente."
        screen -S $SCREEN_NAME -X quit
    else
        echo "$(timestamp) No se encontro ninguna sesion de screen existente."
    fi

    # Iniciar una nueva sesion de screen y ejecutar el servidor de Minecraft
    echo "$(timestamp) Iniciando una nueva sesion de screen para el servidor de Minecraft."
    cd $SERVER_DIR
    screen -dmS $SCREEN_NAME bash -c "java $JAVA_OPTS -jar $SERVER_JAR --nogui"

    # Verificar si la sesion de screen se creo correctamente
    screen -list | grep -q "\.${SCREEN_NAME}\s"
    if [ $? -eq 0 ]; then
        echo "$(timestamp) Se ha reiniciado el servidor de Minecraft correctamente."
    else
        echo "$(timestamp) Error: No se pudo crear la sesion de screen para el servidor de Minecraft."
    fi
}

# Ejecutar la funcion para verificar el estado del servidor
check_server_status
