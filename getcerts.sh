#!/bin/bash

HETZNER_INI="/hetzner.ini"
EXTRA_ARGS="$@"

if [ ! -f "$HETZNER_INI" ]; then
  if [ -n "$HETZNER_INI" ]; then
      echo "dns_hetzner_api_token = $HETZNERTOKEN" > "$HETZNER_INI"           
  else
      echo "/hetzner.ini not found.  run docker with -e HETZNERTOKEN="
      exit 1
  fi
fi

if [ -n "$EMAIL" ]; then
    EMAILREG="--email $EMAIL"
else
    EMAILREG="--register-unsafely-without-email"
fi

source getDomainList

certbot certonly \
   --authenticator dns-hetzner \
   --dns-hetzner-credentials $HETZNER_INI \
   --agree-tos --non-interactive --expand \
   $EMAILREG \
   $DOMAIN_LIST \
   $EXTRA_ARGS

function find_and_copy_most_recent_file() {
    search_path="$1"
    search_filename="$2"
    destination_file="$3"
    most_recent_file=$(find "$search_path" -xtype f -name "$search_filename" -printf "%T@ %p\n" | sort -nr | head -n1 | awk '{print $2}')
    if [ -n "$most_recent_file" ]; then
        if [ ! -e "$destination_file" ] || [ "$most_recent_file" -nt "$destination_file" ]; then
            cp "$most_recent_file" "$destination_file"
            echo "$most_recent_file File copied successfully."
        else
            echo "The destination file $destination_file is already up-to-date."
        fi
    else
        echo "No files matching the search filename were found."
    fi
}

find_and_copy_most_recent_file "/etc/letsencrypt/live/" "fullchain.pem" "/etc/letsencrypt/ssl.cert"
find_and_copy_most_recent_file "/etc/letsencrypt/live/" "privkey.pem" "/etc/letsencrypt/ssl.key"

   
# Check if nginx is running
if pgrep nginx > /dev/null 2>&1; then
    echo "nginx is running, reloading..."
    nginx -s reload
fi
