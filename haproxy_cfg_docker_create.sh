#!/bin/bash

# container_name	dns_match	www_redirect	https_enabled	backend_name
CONTAINERS=$(cat <<EOF
example_conatiner	example.com	0	1	example_backend
EOF
)

# path_pattern	target_backend	backend_name_to_use
PATH_RULES=$(cat <<FRL
^/public	example_frontend	example_backend
FRL
)


FILE_HEADER=$(cat <<HED
global
  log /dev/log    local0 debug
  log /dev/log    local1 notice
  chroot /var/lib/haproxy
  stats socket /run/haproxy/admin.sock mode 660 level admin
  stats timeout 30s
  user haproxy
  group haproxy
  daemon
  # Default SSL material locations
  ca-base /etc/ssl/certs
  crt-base /etc/ssl/private
  # Default ciphers to use on SSL-enabled listening sockets.
  # For more information, see ciphers(1SSL). This list is from:
  #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
  ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS
  ssl-default-bind-options no-sslv3

defaults
  log 0.0.0.0 local0 debug
  log-format %H\ %H\ %ci:%cp\ [%t]\ %ft\ %b/%s\ %Tq/%Tw/%Tc/%Tr/%Tt\ %ST\ %B\ %CC\ %CS\ %tsc\ %ac/%fc/%bc/%sc/%rc\ %sq/%bq\ %hr\ %hs\ %{+Q}r
  mode    http
  option  httplog
  option  forwardfor
  option  dontlognull
  timeout connect 20000
  timeout client  50000
  timeout server  50000
  errorfile 400 /etc/haproxy/errors/400.http
  errorfile 403 /etc/haproxy/errors/403.http
  errorfile 408 /etc/haproxy/errors/408.http
  errorfile 500 /etc/haproxy/errors/500.http
  errorfile 502 /etc/haproxy/errors/502.http
  errorfile 503 /etc/haproxy/errors/503.http
  errorfile 504 /etc/haproxy/errors/504.http


frontend http-in
  bind *:80
  bind 0.0.0.0:443 ssl crt /etc/ssl/example1.com.pem crt /etc/ssl/example2.com.pem
  capture request header Host len 128

HED
);

declare -A BACKEND_CONTAINERS;
declare -a ACL;
declare -a REDIRECTS;
declare -a USE_BACKEND;


while read -r line; do
	PATH_PATTERN=$(echo $line | awk '{print $1}')
	TARGET_BACKEND=$(echo $line | awk '{print $2}')
	BACKEND_TO_USE=$(echo $line | awk '{print $3}')

	if [ "${PATH_PATTERN}x" != "x" ]; then
		NEW_ACL_NAME=$(echo -n "${PATH_PATTERN} ${TARGET_BACKEND} ${BACKEND_TO_USE}" | md5sum | awk '{print $1}')_acl
		ACL+=("  acl ${NEW_ACL_NAME} path_reg -i ${PATH_PATTERN}")
		USE_BACKEND+=("  use_backend ${BACKEND_TO_USE} if ${TARGET_BACKEND}_acl ${NEW_ACL_NAME}")

	fi
	
done <<< "${PATH_RULES}"

while read -r line; do
	CONTAINER_NAME=$(echo $line | awk '{print $1}')
	DOMAIN_NAME=$(echo $line | awk '{print $2}')
	WWW_REDIRECT=$(echo $line | awk '{print $3}')
	HTTPS_REDIRECT=$(echo $line | awk '{print $4}')
	BACKEND_NAME=$(echo $line | awk '{print $5}')
	#CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)

	if [ "${BACKEND_CONTAINERS[${BACKEND_NAME}]}x" = "x" ]; then
		#
		# ACL
		#
		ACL+=("  acl ${BACKEND_NAME}_acl hdr_end(host) -i ${DOMAIN_NAME}")


		#
		# REDIRECTS
		#
		if [ $WWW_REDIRECT -eq 1 ]; then
			SCHEME="http"
			if [ $HTTPS_REDIRECT -eq 1 ]; then
				SCHEME="https"
			fi
			REDIRECTS+=("  redirect prefix ${SCHEME}://www.${DOMAIN_NAME} code 301 if { hdr(host) -i ${DOMAIN_NAME} }")
		fi

		if [ $HTTPS_REDIRECT -eq 1 ]; then
			REDIRECTS+=("  redirect scheme https code 301 if !{ ssl_fc } { hdr_end(host) -i ${DOMAIN_NAME} }")
		else
			REDIRECTS+=("  redirect scheme http code 301 if { ssl_fc } { hdr_end(host) -i ${DOMAIN_NAME} }")
		fi


		#
		# USE BACKENDS
		#
		USE_BACKEND+=("  use_backend ${BACKEND_NAME} if ${BACKEND_NAME}_acl")

	fi

	BACKEND_CONTAINERS[$BACKEND_NAME]+="${CONTAINER_NAME} ";

done <<< "$CONTAINERS"




OUTPUT_FILE="/etc/haproxy/haproxy.cfg"

echo "${FILE_HEADER}" > $OUTPUT_FILE

echo "
  #
  # ACL
  #" >> $OUTPUT_FILE

for line in "${ACL[@]}"; do
	echo "${line}" >> $OUTPUT_FILE
done


echo "
  #
  # REDIRECTS
  #" >> $OUTPUT_FILE
for line in "${REDIRECTS[@]}"; do
	echo "${line}" >> $OUTPUT_FILE
done


echo "
  #
  # USE BACKENDS
  #" >> $OUTPUT_FILE
for line in "${USE_BACKEND[@]}"; do
	echo "${line}" >> $OUTPUT_FILE
done


echo "
  #
  # BACKENDS
  #" >> $OUTPUT_FILE
for BACKEND_NAME in "${!BACKEND_CONTAINERS[@]}"; do
        CONTAINER_NAMES="${BACKEND_CONTAINERS[${BACKEND_NAME}]}"

	echo   >> $OUTPUT_FILE
	echo "backend ${BACKEND_NAME}" >> $OUTPUT_FILE
	echo "  compression algo gzip" >> $OUTPUT_FILE
	echo "  compression type text/html text/plain text/css application/javascript" >> $OUTPUT_FILE

	for CONTAINER_NAME in $CONTAINER_NAMES; do
        	CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
		echo "  server srv1 ${CONTAINER_IP}:80" >> $OUTPUT_FILE
	done

done

/etc/init.d/haproxy reload

