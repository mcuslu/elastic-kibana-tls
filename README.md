# elastic-kibana-tls
Elasticsearch + Kibana Setup with TLS support on Ubuntu 22.04

What this script does:
Installs and starts Elasticsearch 8.x and Kibana 8.x
Uses self-signed TLS certificates automatically generated by Elasticsearch
Configures Kibana to securely connect to Elasticsearch over HTTPS
Prints the elastic user password for login

Where are the TLS certificates?
Elasticsearch automatically generates TLS certificates during the first installation.
The default CA certificate is located at:
**/etc/elasticsearch/certs/http_ca.crt**
Kibana uses this CA certificate to establish a secure (HTTPS) connection with Elasticsearch. 
This is configured using the elasticsearch.ssl.certificateAuthorities setting in kibana.yml.
If you want to serve Kibana over HTTPS with your own certificate (e.g., Let's Encrypt or self-signed), 
uncomment these lines in the script:

server.ssl.enabled: true
server.ssl.certificate: "/etc/kibana/certs/kibana.crt"
server.ssl.key: "/etc/kibana/certs/kibana.key"

