
local config = require("lapis.config")
local os = require('os')

config("development", {
  port = 8080,
  code_cache = "off",
  mysql = {
	host = os.getenv("MYSQL_HOST"),
	user = os.getenv("MYSQL_USER"),
	password =  os.getenv("MYSQL_PASSWORD"),
	database =  os.getenv("MYSQL_DB"),
	port = os.getenv("MYSQL_PORT")
	
  }
})


