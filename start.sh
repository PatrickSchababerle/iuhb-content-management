#!/bin/bash
# Skript zur automatischen Aktivierung der Drupal-Module nach Installation

# Warten, bis die Datenbank verfügbar ist
echo "Warte auf Datenbankverbindung..."
until mysql -h db -u drupal -pdrupalpass -e "SELECT 1" >/dev/null 2>&1; do
  echo "Datenbank noch nicht verfügbar - warte 5 Sekunden..."
  sleep 5
done
echo "Datenbankverbindung hergestellt."

# Prüfen, ob Drupal bereits installiert ist
if [ -f /var/www/html/sites/default/settings.php ] && [ -d /var/www/html/sites/default/files ]; then
  cd /var/www/html
  echo "Drupal-Installation gefunden. Aktiviere Module..."
  ./vendor/bin/drush en -y admin_toolbar admin_toolbar_tools pathauto metatag simple_sitemap seckit honeypot webform
  ./vendor/bin/drush cache:rebuild
  echo "Module aktiviert und Cache geleert."
else
  echo "Drupal scheint noch nicht installiert zu sein. Module werden nach der Installation aktiviert."
fi

# Apache im Vordergrund starten
echo "Starte Apache-Webserver..."
exec apache2-foreground