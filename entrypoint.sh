#! /bin/sh
echo "Nom de la base de données entrypoint"
echo $db_name

my_domain=$(echo $my_url | sed -r 's|^.*\/\/(.*)$|\1|')
my_domain=$(echo $my_domain | sed s'/.$//')

my_url=$my_url
proxy_http=
proxy_https=
BASE_DIR=$PWD

cd $BASE_DIR
#Flask

if [ ! -d 'var' ]
then
  mkdir var
fi

if [ ! -d 'var/log' ]
then
  mkdir var/log
  chmod -R 775 var/log/
fi




echo "Création du fichier de configuration  et préparation du fichier de configuration..."


echo "SQLALCHEMY_DATABASE_URI = 'postgresql://$user_pg:$user_pg_pass@$db_host:$db_port/$db_name'" > config/geonature_config.toml
echo "URL_APPLICATION = 'http://${HOST}:4200'" >> config/geonature_config.toml
echo "API_ENDPOINT = '${my_url}geonature/api'" >> config/geonature_config.toml
echo "API_TAXHUB = '${my_url}taxhub/api'" >> config/geonature_config.toml
echo "APPLICATION_ROOT = '/geonature/api'" >> config/geonature_config.toml
echo "DEFAULT_LANGUAGE = '${default_language}'" >> config/geonature_config.toml
echo "LOCAL_SRID = '${srid_local}'" config/geonature_config.toml
echo "SECRET_KEY = '${SECRET_KEY}'" >> config/geonature_config.toml

cat config/geonature_config.toml.docker >> config/geonature_config.toml

cd backend

echo "Installation du backend geonature..."
echo $BASE_DIR
echo $PWD
pip install --editable "${BASE_DIR}"  # geonature ne support pas encore autre chose que editable




echo "Création du fichier de log des erreurs GeoNature"
# Cela évite sa création par Supervisor avec des droits root
# Voir : https://github.com/Supervisor/supervisor/issues/123
touch "${BASE_DIR}/var/log/gn_errors.log"

DIR=$(readlink -e "${0%/*}")

#echo "Création de la rotation des logs à l'aide de Logrotate"
#sudo cp "${assets_install_dir}/log_rotate" "/etc/logrotate.d/geonature"
#sudo -s sed -i "s%{{APP_PATH}}%${BASE_DIR}%" "/etc/logrotate.d/geonature"
#sudo -s sed -i "s%{{USER}}%${USER:=$(/usr/bin/id -run)}%" "/etc/logrotate.d/geonature"
#sudo -s sed -i "s%{{GROUP}}%${USER}%" "/etc/logrotate.d/geonature"
#sudo logrotate -f "/etc/logrotate.conf"

# Get usershub's migrations
wget "https://github.com/PnX-SI/UsersHub/archive/refs/tags/${usershub_release}.zip"
unzip "${usershub_release}.zip"
cp -r "UsersHub-${usershub_release}/app/migrations"  /GeoNature/tmp
rm "${usershub_release}.zip"
rm -r "UsersHub-${usershub_release}"
if [ "$INSTALL_DB" = true ];
then
  cd $BASE_DIR/install/
  chmod +x add_extensions.sh
  ./add_extensions.sh
  cd $BASE_DIR
fi
echo "Migration de la base de donées Alembic"
geonature db upgrade geonature@head -x data-directory=tmp/ -x local-srid=$srid_local
if [ "$INSTALL_DB" = true ];
echo "installing inital data"
  then
  cd $BASE_DIR/install/
  chmod +x install_initial_data.sh
  ./install_initial_data.sh
  sed -i "s/$INSTALL_DB/false/g" $BASE_DIR/.env.local
fi
cd $BASE_DIR
echo "Lancement de l'application api backend..."
geonature generate_frontend_config --build=false
# Préparation du frontend

# Lien symbolique vers le dossier static du backend (pour le backoffice)
ln -sf "${BASE_DIR}/frontend/node_modules" "${BASE_DIR}/backend/static"

cd "${BASE_DIR}/frontend"

# Creation du dossier des assets externes
mkdir -p "src/external_assets"


# Copy the custom components
echo "Création des fichiers de customisation du frontend..."
if [ ! -f src/assets/custom.css ]; then
  cp -n src/assets/custom.sample.css src/assets/custom.css
fi


# Generate the tsconfig.json
geonature generate_frontend_tsconfig #Docker vérifier ce que ça fait ça
# Generate the src/tsconfig.app.json
geonature generate_frontend_tsconfig_app
# Generate the modules routing file by templating
geonature generate_frontend_modules_route

# Retour à la racine de GeoNature
cd "${BASE_DIR}"
if [ "$INSTALL_OCCTAX" = true ];
  then
 geonature install_gn_module "${BASE_DIR}/contrib/occtax" /occtax --build=false
fi
if [ "$INSTALL_OCCHAB" = true ];
  then
    geonature install_gn_module "${BASE_DIR}/contrib/gn_module_occhab" /occhab --build=false
fi
if [ "$INSTALL_VALIDATION" = true ];
  then
    geonature install_gn_module "${BASE_DIR}/contrib/gn_module_validation" /validation --build=false
fi
if [ "$INSTALL_IMPORT" = true ];
  then
    geonature install_gn_module "${BASE_DIR}/contrib/gn_module_import" /import --build=false
fi
if [ "$INSTALL_EXPORT" = true ];
  then
    geonature install_gn_module "${BASE_DIR}/contrib/gn_module_export" /export --build=false
fi
if [ "$INSTALL_DASHBOARD" = true ];
  then
    geonature install_gn_module "${BASE_DIR}/contrib/gn_module_dashboard" /dashboard --build=false
fi
if [ "$INSTALL_MONITORING" = true ];
  then
    geonature install_gn_module "${BASE_DIR}/contrib/gn_module_monitoring" /monitorings --build=false
fi

exec gunicorn "geonature:create_app()"  -w 4  -b 0.0.0.0:80  #-n "${app_name}" #https://testdriven.io/blog/dockerizing-flask-with-postgres-gunicorn-and-nginx/

