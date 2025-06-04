#!/bin/sh

set -a

if [ -f /var/www/html/.env ]; then
  grep -E '^[A-Za-z_][A-Za-z0-9_]*=.*$' /var/www/html/.env > /tmp/bitrix_env.tmp
  . /tmp/bitrix_env.tmp
  rm /tmp/bitrix_env.tmp
fi

set +a

exec /usr/local/bin/php -f /var/www/html/bitrix/modules/main/tools/cron_events.php