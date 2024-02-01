#!bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script requires root privileges. Please run as root or using sudo."
    exit 1
fi


# Check if 'gin' command exists in the system if 'yes' don't continue
if command -v gin &> /dev/null; then
    echo "Error: The 'gin' command is already present on the system."
    echo "Exiting the script. Because it looks like it will interfere with your package called 'gin'."
    exit 1
fi


tool="gin"
opt="/opt/gin"
sbin="/sbin"

chmod +x gin
chmod 777 gin

chmod +x gin.sh
chmod 777 gin.sh

mkdir "$opt"
chmod 777 "$opt"

cp -r gin "$sbin"
cp -r gin.sh "$opt"

echo "Installation complete!!"
