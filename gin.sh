#!/bin/bash

function invalid()
{
    echo "[invalid arguments]: To see how the tool works, see >> https://github.com/reprogamaco/gin"
}



if [ -z "$1" ]; then
    invalid
    exit 1
elif [ "$1" = "create" ] && [ -n "$2" ]; then
    PROJECT_NAME="$2"
elif [ "$1" = "run" ]; then
    if [ -e "go.mod" ]; then
        go run main.go
        exit 0
    fi
    echo "Run this command inside the home directory of your project!"
    exit 1
elif [ "$1" = "uninstall" ]; then

    rm -rf /sbin/gin
    rm -rf /opt/gin

    echo "Uninstall complete!!"
    exit 0
else
    invalid
    exit 1
fi



# Create project directory
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# Create main.go file
touch main.go

mkdir config

mkdir config/development
echo "server:
  port: 8080
  log_level: debug
  database:
    host: localhost
    port: 3306
    name: root
    user: root
    password: \"\"

" >> config/development/config.yaml

mkdir config/production
echo "server:
  port: 80
  log_level: info
  database:
    host: prod_db_host
    port: 3306
    name: prod_database
    user: prod_user
    password: prod_password

" >> config/production/config.yaml



# Create directories for routes, middleware, templates, and static files
mkdir routes
touch routes/routes.go

mkdir middleware
touch middleware/middleware.go

mkdir templates
touch templates/index.html

mkdir static
mkdir static/css
mkdir static/js


echo "* {
    min-width: 0;
}" >> static/css/style.css

# Populate main.go with a basic Gin application
echo -e "package main

import (
    \"fmt\"
	\"github.com/gin-gonic/gin\"
    \"github.com/spf13/viper\"
	\"$PROJECT_NAME/routes\"
    \"os\"
)

func main() {
    // Determine the environment (default to development)
	env := os.Getenv(\"GIN_ENV\")
	if env == \"\" {
		env = \"development\"
	}


    // Set Gin mode based on the environment
	if env == \"production\" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Load configuration from YAML file
	configPath := fmt.Sprintf(\"config/%s/config.yaml\", env)
	viper.SetConfigFile(configPath)

	if err := viper.ReadInConfig(); err != nil {
		panic(fmt.Errorf(\"Fatal error config file: %s \", err))
	}

	// Print the loaded configuration (for demonstration purposes)
	fmt.Println(\"Loaded Configuration:\")
	fmt.Println(\"Server Port:\", viper.GetInt(\"server.port\"))
	fmt.Println(\"Log Level:\", viper.GetString(\"server.log_level\"))
	fmt.Println(\"Database Host:\", viper.GetString(\"server.database.host\"))
	fmt.Println(\"Database Name:\", viper.GetString(\"server.database.name\"))
	fmt.Println(\"Database User:\", viper.GetString(\"server.database.user\"))
	fmt.Println(\"Database Password:\", viper.GetString(\"server.database.password\"))


	router := gin.Default()


	// Configure template engine
	router.LoadHTMLGlob(\"templates/*\")

	// Configure static files
	router.Static(\"/static\", \"./static\")  // This serves files under /static from the local ./static directory


	// Load routes
	routes.SetupRoutes(router)

	// Get the port from the environment or use a default value (e.g., 8080)
	port := os.Getenv(\"PORT\")
	if port == \"\" {
		port = \"8080\"
	}

	// Run the server
	router.Run(\":\" + port)
}
" > main.go


# Populate routes.go with a basic route setup
echo "package routes


import (
	\"fmt\"
	\"github.com/gin-gonic/gin\"
)

// SetupRoutes initializes all routes for the application
func SetupRoutes(router *gin.Engine) {
	router.GET(\"/\", func(c *gin.Context) {
		fmt.Println(\"Handling / route\")  // logging
		c.HTML(200, \"index.html\", nil)
	})
}
" > routes/routes.go

# Generate HTML file with a cool UI
echo -e "<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>$PROJECT_NAME - Your Project</title>
    <link rel=\"stylesheet\" href=\"/static/css/style.css\">
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f0f0f0;
            color: #333;
            text-align: center;
            padding: 50px;
            font-size: xx-large !important;
        }
        h1 {
            color: #009688;
        }
        p {
            font-size: 18px;
            margin-bottom: 20px;
        }
        .cool-button {
            background-color: #009688;
            color: #fff;
            padding: 10px 20px;
            font-size: 16px;
            border: none;
            cursor: pointer;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <h1>Welcome to ${PROJECT_NAME}!</h1>
    <p>This is your cool Project. Customize it as per your needs.</p>
    <button class=\"cool-button\">Click me!</button>
</body>
</html>
" > templates/index.html


go mod init $PROJECT_NAME

echo -e "getting the github.com/gin-gonic/gin.. (usually takes 1 minutes)"
go get github.com/gin-gonic/gin
echo -e "getting github.com/spf13/viper.. (usually takes 2 minutes)"
go get github.com/spf13/viper

# sleep for 3 seconds for completion of background processes
sleep 3

# Display success message
echo -e "$PROJECT_NAME structure created successfully!"
