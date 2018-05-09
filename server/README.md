# Server
This is the API server in Kemal (http://kemalcr.com) in Crystal (https://crystal-lang.org)

Envrionmental variables:  
- PG_URL: the database url like: postgres://username:password@localhost:5432/alexi_development
- ALEXI_ROOT: the root directory for Alexi models
- ALEXI_PORT: the port number
- EMAIL_USERNAME: the smtp server username
- EMAIL_PASSWORD: the smtp server password
- SEND_EMAIL_DIR: the python email script directory
- SERVER_URL: the server url like: https://glodet.nebraska.edu

## Installation
1. install Crystal https://crystal-lang.org/docs/installation/
2. `shards install`

## Usage
API Server `crystal src/server.cr`.

## Build for deployment
`shards build`

## Serve client
Make a symbolic link called `public` to your client `dist` folder `ln -s your_dist public`

