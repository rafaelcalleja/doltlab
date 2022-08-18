
#!/bin/bash

set -e

export HOST_IP

check_env() {
  if [[ -z "$HOST_IP" || -z "$POSTGRES_PASSWORD" || -z "$DOLTHUBAPI_PASSWORD" ]]; then
    echo "Must supply HOST_IP, POSTGRES_PASSWORD, and DOLTHUBAPI_PASSWORD"
    exit 1
  fi
  if [[ -z "$EMAIL_HOST" || -z "$EMAIL_PORT" || -z "$NO_REPLY_EMAIL" ]]; then
    echo "Must supply EMAIL_HOST, EMAIL_PORT, and NO_REPLY_EMAIL"
    exit 1
  fi

  check_email_auth_method
}

check_email_auth_method() {
  if [ -z "$EMAIL_AUTH_METHOD" ]; then
    export EMAIL_AUTH_METHOD=plain
  fi

  if [ "$EMAIL_AUTH_METHOD" == "plain" ] || [ "$EMAIL_AUTH_METHOD" == "login" ]
  then
    check_plain_login_auth_env
  elif [ "$EMAIL_AUTH_METHOD" == "oauthbearer" ]
  then
    check_oauthbearer_auth_env
  fi
}

check_plain_login_auth_env() {
  if [[ -z "$EMAIL_USERNAME" || -z "$EMAIL_PASSWORD" ]]; then
    echo "Must supply EMAIL_USERNAME and EMAIL_PASSWORD"
    exit 1
  fi
}

check_oauthbearer_auth_env() {
  if [[ -z "$EMAIL_USERNAME" || -z "$EMAIL_OAUTH_TOKEN" ]]; then
    echo "Must supply EMAIL_USERNAME and EMAIL_OAUTH_TOKEN"
    exit 1
  fi
}

create_token_keys() {
  chmod +x ./gentokenenckey
  ./gentokenenckey > iter_token.keys
}

create_envoy_config() {
  cat envoy.tmpl | envsubst \$HOST_IP > envoy.yaml
}

update_images() {
  docker-compose pull
}

start_services() {
  POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  DOLTHUBAPI_PASSWORD="$DOLTHUBAPI_PASSWORD" \
  POSTGRES_USER=dolthubadmin \
  docker-compose up -d
}

send_usage_metrics() {
  chmod +x send_doltlab_deployed_event
  ./send_doltlab_deployed_event --version v0.5.7
}

set_env() {
  set_default_user_env
  set_email_smtp_env
}

set_default_user_env() {
  if [ -z "$DEFAULT_USER" ]; then
    echo "Setting DEFAULT_USER=admin"
    export DEFAULT_USER=admin
  fi
  if [ -z "$DEFAULT_USER_PASSWORD" ]; then
    echo "Setting DEFAULT_USER_PASSWORD=DoltLab1234"
    export DEFAULT_USER_PASSWORD=DoltLab1234
  fi
  if [ -z "$DEFAULT_USER_EMAIL" ]; then
    echo "Setting DEFAULT_EMAIL=$NO_REPLY_EMAIL"
    export DEFAULT_USER_EMAIL="$NO_REPLY_EMAIL"
  fi
}

set_email_smtp_env() {
  if [ -z "$EMAIL_CLIENT_HOSTNAME" ]; then
    echo "Setting EMAIL_CLIENT_HOSTNAME=localhost"
    export EMAIL_CLIENT_HOSTNAME=localhost
  fi
}

_main() {
    check_env
    set_env
    create_token_keys
    create_envoy_config
    send_usage_metrics
    update_images
    start_services
    echo "DoltLab Documentation is available at https://docs.dolthub.com/guides/doltlab"
}

_main

