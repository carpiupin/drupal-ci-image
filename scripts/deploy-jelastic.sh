#!/bin/bash
#
# deploy-jelastic.sh: Executes all steps to upgrade drupal site
# 
#set -x

echo ""
echo "Switching to project docroot."
cd /var/www/
echo ""
echo "Pulling down latest code."
git pull origin master
echo ""
echo "Clearing drush cache"
drush cc drush
echo ""
echo "Run database updates."
drush updb -y
echo ""
echo "Reverting features modules."
drush fra -y
echo ""
echo "Clearing caches."
echo ""
drush cc all
echo ""
echo "Deployment complete."