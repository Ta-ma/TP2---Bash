#!/bin/bash  

#Ejercicio 1 -TP2 Primer Entrega
#Grupo: 6

#Gómez Markowicz, Federico - 38858109
#Kuczerawy, Damián - 37807869
#Mediotte, Facundo - 39436162
#Siculin, Luciano - 39213320
#Tamashiro, Santiago - 39749147

mostrar_ayuda(){
	echo "./Ejercicio1.sh <archivo>"
	echo "Donde:"
	echo "<archivo> -> es el archivo de texto plano que se quiere normalizar"
	echo "Ejemplo: ./Ejercicio1.sh arch.txt"
}

if [ $# != 1 ]; then
	echo "Error de llamada. Se debe recibir 1 solo parámetro"
	exit
fi
case $1 in
	-h|-\?|-help) 
		mostrar_ayuda
		exit;;
esac
if ! [ -f "$1" ]; then
	echo "Archivo no existe o no es un archivo regular."
	exit
fi
file -i "$1" | grep text/plain >> /dev/null

if [ $? != 0 ]
then
	echo "El archivo enviado como parámetro no es un archivo plano."
	exit
fi

cp "$1" "$1.bak"
ARCH1=/tmp/`basename "$1"`.$$
sed 's/[A-Z]*/\L&/g' "$1" > "$ARCH1" #Pone la primer letra de cada linea en mayúscula
sed -i 's/^./\u&/' "$ARCH1" # Pone las siguientes letras en minúscula
mv "$ARCH1" "$1"

# 1. La línea #!/bin/bash especifica con que intérprete se debe ejecutar el script, en este ejemplo se debe ejecutar con bash.

# 2. Se le da permisos de ejecucion al script mediante el comando chmod +x ejercicio1.sh

# 3. La variable $1 es una variable especial que retorna el primer parámetro recibido por la consola de ejecución,
#   la variable $# es una variable especial que devuelve la cantidad de parámetros enviados por la consola de ejecución.
#	Mientras que la variable $? devuelve el valor de retorno del último comando ejecutado, donde el valor 0 es bueno.

#	Existen más variables especiales que podemos utilizar para referenciar otros objetos o parámetros. Algunas de ellas son:
	
#	$0 -> nos devuelve el nombre del archivo ejecutable
#	$* -> linea completa de la llamada. Contiene todos los argumentos
#	$@ -> lista de todos los parámetros recibidos por la consola de ejecución (menos $0)
#	$$ -> nos retorna el PID o id del proceso (process ID)
#	$PWD -> directorio de trabajo actual del programa
# 	$BASH_VERSION -> versión de la instancia de bash que está ejecutando el script.

# 4. El objetivo general del Script es poner en mayuscula la primer letra de cada una de las líneas del archivo plano, y quitarle
#   el salto de línea concatenando todo en la primera línea del archivo.

# 5. Sed es un editor de texto orientado a flujo el cual acepta como entrada un archivo o la entrada estándar,
#	cada línea es procesada y el resultado es enviado a la salida estándar.
	
#	Se suele implementar la sintaxis: sed comandos_sed archivo
#	Los usos basicos que se destacan en sed son: borrar, imprimir y modificar lineas ya sea de un archivo plano o de la entrada estándar(stdin) 

# 6. Si ejecuto el script con un archivo con espacios en su nombre, da error debido a que toma el espacio como el fin de un parámetro
#   y la siguiente palabra la utiliza como un nuevo parámetro.

#	Para corregirlo, siempre que se utilice una variable que contiene un path dentro del script debe encerrarse en comillas.
# 	Ejemplo: "$1"