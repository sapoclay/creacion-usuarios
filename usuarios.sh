#!/bin/bash

# Script useradd que permita realizar las siguientes operaciones y vaya comproabando (acceso y lectura de archivos utilizados) la correcta creación de usuarios que tendrán que ser añadidos por el usuario.
# 1. Crea una cuenta de usuario pepe. Muestra cual es su user id, su group id, muestra su carpeta personal, su shell. Además muestra las líneas de los archivo passwd y shadow para ver el usuario que has creado
# 2. Asigna contraseña al usuario pepe. Comprueba que en el archivo shadow aparece la contraseña cifrada. (intentar descifrarla con john the ripper)
# 3. Crea al usuario manolito por defecto asignandole (durante la creación) una contraseña de usuario
# 4. Crea un usuario llamado Raul, complementame personalizado: shell, directorio personal de trabajo, user id personalizado y group id personalizado.
# 5. Crea el usuario juan con el directorio personal en /opt : comprueba que se ha creado ahí el direcotrio personal.
# 6. Crea el usuario Julia  (con las caracterísitcas que quieras) pero que se utilice varios grupos. pruedes consultar el listado de grupos en el archivo group.  comprueba los grupos a los que pertenece Julia.
# 7. Crea al usuario pepita y ponle una fecha de caducidad a su cuenta (usuarios temporales)
# 8. Crea al usuario noelia y ponel una contraseña que caduque
# 9. crea al usuario pinpinela y que su shell sea otro diferente al que viene por defecto

# Función para imprimir un separador visual
imprimir_separador() {
    echo "---------------------------------------"
}

# 1. Función para crear usuario interactivo con contraseña cifrada en SHA-512
crear_usuario_interactivo() {
    read -p "Escribe el nombre del usuario: " nombre_usuario
    sudo useradd -m $nombre_usuario
    imprimir_separador
    echo "Información del usuario $nombre_usuario:"
    id $nombre_usuario
    echo "Carpeta personal: $(eval echo ~$nombre_usuario)"
    echo "Shell: $(getent passwd $nombre_usuario | cut -d: -f7)"
    echo "Línea en /etc/passwd:"
    grep "^$nombre_usuario:" /etc/passwd
    echo "Línea en /etc/shadow:"
    grep "^$nombre_usuario:" /etc/shadow
    imprimir_separador
    # 2. Solicitar y cifrar la nueva contraseña en SHA-512
    read -s -p "Escribe la nueva contraseña para $nombre_usuario: " password
    hashed_password=$(openssl passwd -6 "$password")
    echo ""
    sudo usermod --password $hashed_password $nombre_usuario
    separador
    echo "Contraseña cifrada en SHA-512 en /etc/shadow:"
    grep "^$nombre_usuario:" /etc/shadow
    imprimir_separador
}

# 3. Función para crear usuario con contraseña interactivo
crear_usuario_con_contrasena_interactivo() {
 
 
    read -p "Escribe el nombre del usuario: " nombre_usuario
    # -s esconde lo que se escribe -p permite mostrar el mensaje antes de que se introduzca por teclado
    read -s -p "Escribe la contraseña para $nombre_usuario: " password
    echo
    #openssl passwd -6 se utiliza para generar un hash de contraseña utilizando el algoritmo de cifrado SHA-512. El número "6" especifica el tipo de cifrado que se utilizará
    #$password toma el valor escrito por el usuario
    hashed_password=$(openssl passwd -6 "$password")
    #-m le indica a useradd que se debe crear automáticamente el directorio de inicio
    #-p $hashed_password especifica la contraseña cifrada en formato de hash que se asignará al usuario.
    sudo useradd -m -p $hashed_password $nombre_usuario
    imprimir_separador
    echo "Contraseña cifrada en SHA-512 en /etc/shadow:"
    # Busca el nombre de usuario en /etc/shadow
    grep "^$nombre_usuario:" /etc/shadow
    imprimir_separador
    id $nombre_usuario
}

# 4. y 9. Función para crear usuario con shell personalizado interactivo
crear_usuario_con_shell_personalizado_interactivo() {

    read -p "Escribe el nombre del usuario: " nombre_usuario
    read -p "Escribe el shell para $nombre_usuario (por ejemplo, /bin/bash): " shell
    read -p "Escribe el directorio personal para $nombre_usuario (por ejemplo, /home/$nombre_usuario): " directorio_personal
    read -p "Escribe el User ID (UID) personalizado para $nombre_usuario: " uid
    read -p "Escribe el Group ID (GID) personalizado para $nombre_usuario: " gid

    sudo useradd -m -s $shell -d $directorio_personal -u $uid -g $gid $nombre_usuario
    
    imprimir_separador
    echo "Información del usuario $nombre_usuario:"
    id $nombre_usuario
    echo "Shell: $(getent passwd $nombre_usuario | cut -d: -f7)"
    echo "Carpeta personal: $(eval echo ~$nombre_usuario)"
    echo "User ID: $(id -u $nombre_usuario)"
    echo "Group ID: $(id -g $nombre_usuario)"
    echo "Línea en /etc/passwd:"
    grep "^$nombre_usuario:" /etc/passwd
    echo "Línea en /etc/shadow:"
    grep "^$nombre_usuario:" /etc/shadow
    imprimir_separador
}

# 5. Función para crear usuario con home personalizado
crear_usuario_home_personalizado(){

	read -p "Escribe el nombre cuarto usuario que quieres crear: " usuario
	read -p "Escribe la ruta de su directorio HOME" home
	sudo useradd -m -d /$home/$usuario $usuario
	echo "Usuario creado correctamente"
	imprimir_separador
	echo "Comprobación de directorio personal del usuario $usuario:"
	ls -ld /$home/$usuario
	imprimir_separador
}

# 6. Función para crear usuario en grupos múltiples interactivo
crear_usuario_en_grupos_multiples_interactivo() {

    read -p "Escribe el nombre del usuario: " nombre_usuario
    read -p "Escribe los nombres de los grupos (separados por comas): " lista_grupos
    sudo useradd -m -G $lista_grupos $nombre_usuario
    imprimir_separador
    echo "Grupos a los que pertenece $nombre_usuario:"
    groups $nombre_usuario
    imprimir_separador
}

# 7. Función para crear usuario con fecha de caducidad interactivo
crear_usuario_con_caducidad_interactivo() {

    read -p "Escribe el nombre del usuario: " nombre_usuario
    read -p "Escribe la fecha de caducidad (formato YYYY-MM-DD): " fecha_caducidad
    sudo useradd -m -e $fecha_caducidad $nombre_usuario
    imprimir_separador
    sudo chage --list nombre_usuario
}

# 8. Función para crear usuario con contraseña y fecha de caducidad interactivo
crear_usuario_con_contrasena_y_caducidad_interactivo() {

    read -p "Escribe el nombre del usuario: " nombre_usuario
    read -s -p "Escribe la contraseña para $nombre_usuario: " password
    echo
    hashed_password=$(openssl passwd -6 "$password")
    read -p "Escribe la fecha de caducidad (formato YYYY-MM-DD): " fecha_caducidad
    sudo useradd -m -e $fecha_caducidad -p $hashed_password $nombre_usuario
    imprimir_separador
    echo "Usuario $nombre_usuario creado con contraseña y fecha de caducidad."
    echo "Contraseña cifrada en SHA-256 en /etc/shadow:"
    grep "^$nombre_usuario:" /etc/shadow
    imprimir_separador
    id $nombre_usuario
}


# Menú de opciones
while true; do
    echo "Selecciona una opción:"
    echo "1. Crear usuario"
    echo "2. Crear usuario con contraseña"
    echo "3. Crear usuario con fecha de caducidad en su cuenta"
    echo "4. Crear usuario con fecha de caducidad en su contraseña"
    echo "5. Crear usuario con shell personalizado"
    echo "6. Crear usuario en grupos múltiples"
    echo "7. Crear usuario con home personalizado"
    echo "8. Salir"
    read -p "Opción: " eleccion

    case $eleccion in
        1)
            clear
            crear_usuario_interactivo
            ;;
        2)
            clear
            crear_usuario_con_contrasena_interactivo
            ;;
        3)
            clear
            crear_usuario_con_caducidad_interactivo
            ;;
        4)
            clear
	    crear_usuario_con_contrasena_y_caducidad_interactivo
	    ;;
        5)
            clear
            crear_usuario_con_shell_personalizado_interactivo
            ;;
        6)
            clear
            crear_usuario_en_grupos_multiples_interactivo
            ;;
        7)
            clear
            crear_usuario_home_personalizado
            ;;
        8)
            echo ""
            echo "Saliendo del programa..."
            exit 0
            ;;
        *)
            echo "Opción no válida. Por favor, selecciona una opción válida."
            ;;
    esac
done
