#! /bin/bash
cd frontend
cp src/custom/components/footer/footer.component.ts.sample src/custom/components/footer/footer.component.ts
cp src/custom/components/footer/footer.component.html.sample src/custom/components/footer/footer.component.html
cp src/custom/components/introduction/introduction.component.ts.sample src/custom/components/introduction/introduction.component.ts
cp src/custom/components/introduction/introduction.component.html.sample src/custom/components/introduction/introduction.component.html

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install v10.15.3
nvm use

echo "Installation des paquets Npm"
#npm ci --only=prod

npm install /GeoNature/external_modules/dashboard/frontend
npm install /GeoNature/external_modules/import/frontend

npm install  /GeoNature/external_modules/exports/frontend
npm install  /GeoNature/external_modules/monitorings/frontend

npm install .


echo "Build du frontend..."

npm rebuild node-sass --force
npm run docker_start

