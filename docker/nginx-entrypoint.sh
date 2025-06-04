#!/bin/sh
set -e

echo "DEBUG: Содержимое site_available до создания симлинков:"
ls -l /etc/nginx/bx/site_available

echo "DEBUG: Содержимое site_enabled до очистки:"
ls -l /etc/nginx/bx/site_enabled || true

rm -f /etc/nginx/bx/site_enabled/*.conf

for f in /etc/nginx/bx/site_available/*.conf; do
  [ -e "$f" ] || continue
  echo "DEBUG: Создаю симлинк для $f"
  ln -sf "$f" "/etc/nginx/bx/site_enabled/$(basename "$f")"
done

echo "DEBUG: Содержимое site_enabled после создания симлинков:"
ls -l /etc/nginx/bx/site_enabled

exec nginx -g 'daemon off;'