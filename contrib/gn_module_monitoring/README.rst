Module GeoNature de suivis génériques
#####################################

Module générique de gestion des données de protocoles de type suivis
********************************************************************

Ce module permet de gérer de façon générique des données de protocoles "simples" articulés en 3 niveaux :
des sites (nom, type, localisation) dans lesquels on fait des visites (dates, observateurs)
dans lesquelles on peut faire des observations (espèces).

Ces 3 niveaux peuvent être complétés des données spécifiques à chaque protocole, qui sont stockées dynamiquement dans la base de données sous forme de jsonb.

.. image:: docs/images/apercu.png
    :alt: Liste des sites du protocole de test
    :width: 800

Le module permet de générer des sous-modules (stockés dans la table ``gn_commons.t_modules``) pour chaque protocole de suivi. Ils s'appuient sur les champs fixes des 3 tables ``gn_monitoring.t_base_sites``, ``gn_monitoring.t_base_visits`` et ``gn_monitoring.t_observations`` qui peuvent chacunes être étendues avec des champs spécifiques et dynamiques stockés dans des champs de type ``JSONB``.

Les champs spécifiques de chaque sous-module sont définis dans des fichiers de configuration au format json.

Pour chaque sous-module, correspondant à un protocole spécifique de suivi, il est ainsi possible d'ajouter dynamiquement des champs de différent type (liste, nomenclature, booléen, date, radio, observateurs, texte, taxonomie...). Ceux-ci peuvent être obligatoires ou non, affichés ou non et avoir des valeurs par défaut. Les listes d'observateurs et d'espèces peuvent aussi être définies au niveau de chaque sous-module, en fonction du contexte du protocole de suivi.

Des fonctions SQL ainsi qu'une vue définie pour chaque protocole permettent d'alimenter automatiquement la synthèse de GeoNature à partir des données saisies dans chaque sous-module.

.. image:: docs/images/2020-06-MCD-monitoring.jpg
    :alt: MCD du schema gn_monitoring

Sommaire
********

* `Installation`_
* `Gestion de la synthèse <docs/synthese.rst>`_
* `Documentation technique <docs/documentation_technique.rst>`_
* `Création d'un sous-module <docs/sous_module.rst>`_
* `Mise à jour du module <docs/MAJ.rst>`_
* `Liste des commandes <docs/commandes.rst>`_
* `Permissions`_

Installation
************

Pré-requis
==========

- Avoir GeoNature installé à la version 2.5.2 ou plus.

Récupération du dépôt
=====================

Pour récupérer le code source du module, vous pouvez le télécharger ou le cloner.

Téléchargement
--------------

::

  get https://github.com/PnX-SI/gn_module_monitoring/archive/X.Y.Z.zip
  unzip X.Y.Z.zip


Avec ``X``, ``Y``, ``Z`` correspondant à la version souhaitée.

Clonage du dépôt
----------------

::

    git clone https://github.com/PnX-SI/gn_module_monitoring.git


Installation du module
======================

Activer le venv de GeoNature
----------------------------

::

  cd <path_to_geonature>
  source backend/venv/bin/activate


Lancer la commande d'installation d'un module GeoNature
-------------------------------------------------------

::

  geonature install_gn_module <path_to_module_monitoring> monitorings

*Cela lance un rebuild du frontend que vous pouvez éviter (et faire ultérieurement) en faisant :*

::

  geonature install_gn_module <path_to_module_monitoring> monitorings --build=false


Installation d'un sous-module
=============================

Récupérer le code d'un sous-module de suivi
-------------------------------------------

Par exemple le sous-module ``test`` présent dans le repertoire ``contrib/test`` du module de suivi.

Activer le venv de GeoNature
----------------------------

::

  cd <path_to_geonature>
  source backend/venv/bin/activate


Vérifier que la variable ``FLASK_APP`` est bien définie
-------------------------------------------------------

Afin de pouvoir lancer la commande ``flask`` depuis n'importe quel répertoire

- comme ``geonature`` est désormais un module python(depuis la 2.7), la commande suivante suffit:

::
  export FLASK_APP=geonature


Lancer la commande d'installation du sous-module
------------------------------------------------

::

  flask monitorings install <chemin_absolu_vers_le_sous_module>

- Par défaut la commande d'installation extrait le code du module depuis le chemin.
- Par exemple ``<chemin_absolu_vers_le_module_de_suivi>/contrib/test/`` donnera la valeur ``test`` à ``module_code``.
- Le caractère ``/`` à la fin de ``<chemin_absolu_vers_le_sous_module>`` est optionnel.

Si la commande précise que le module est déjà installé (test sur le ``module_code``) on peut préciser une valeur différente pour ``module_code`` avec la commande :

::

  flask monitorings install <chemin_absolu_vers_le_sous_module> <module_code>


Enfin si on choisit d'installer plusieurs sous-modules, pour aller plus vite on peut faire

::

  flask monitorings install <chemin_absolu_vers_le_sous_module> --build=false


Cela évite de reconstruire le frontend à chaque fois.
Une fois tous les modules installés on peut faire (afin d'avoir les images dans le menu des sous-modules).

::

  geonature frontend_build


Configurer le sous-module
=========================

Dans le menu de droite de GeoNature, cliquer sur le module ``Monitoring``
-------------------------------------------------------------------------

Le sous-module installé précedemment doit s'afficher dans la liste des sous-modules.

Cliquez sur le sous-module
--------------------------

Vous êtes désormais sur la page du sous-module. Un message apparaît pour vous indiquer de configurer le module.

Cliquez sur le bouton ``Éditer``
--------------------------------

Le formulaire d'édition du module s'affiche et vous pouvez choisir les variable suivantes :

- Jeux de données *(obligatoire)* :

  - Un module peut concerner plusieurs jeux de données, le choix sera ensuite proposé au niveau de chaque visite.

- Liste des observateurs *(obligatoire)*:

  - La liste d'observateurs définit l'ensemble de observateurs possible pour le module (et de descripteurs de site).
  - Cette liste peut être définie dans l'application ``UsersHub``.

- Liste des taxons *(obligatoire selon le module)* :

  - Cette liste définit l'ensemble des taxons concernés par ce module. Elle est gérée dans l'application ``TaxHub``.

- Activer la synthèse *(non obligatoire, désactivée par défaut)* ?

  - Si on décide d'intégrer les données du sous-module dans la synthèse de GeoNature.

- Affichage des taxons *(obligatoire)* ?

  - Définit comment sont affichés les taxons dans le module :

    - ``lb_nom`` : Nom latin,
    - ``nom_vern,lb_nom`` : Nom vernaculaire par defaut s'il existe, sinon nom latin.

- Afficher dans le menu ? *(non obligatoire, non affiché par défaut)* :

  - On peut décider que le sous-module soit accessible directement depuis le menu de droite de GeoNature.
  - ``active_frontend``

- Options spécifiques du sous-module :

  - Un sous-module peut présenter des options qui lui sont propres et définies dans les paramètres spécifiques du sous-module.

Exemples de sous-modules
========================

D'autres exemples de sous-modules sont disponibles sur le dépôt https://github.com/PnCevennes/protocoles_suivi :

* Protocole de suivi des oedicnèmes,
* Protocole de suivi des mâles chanteurs de l'espèce chevêche d'Athena;
* Protocole Suivi Temporel des Oiseaux de Montagne (STOM)


Permissions
************

Les permissions ne sont implémentées que partiellement, la notion de portée (mes données, les données de mon organisme, toutes les données) n'est pas prise en compte. Si un utilisateur à le droit de réaliser une action sur un type d'objet, il peut le faire sur l'ensemble des données.

La gestion des permissions pour les rôles (utilisateur ou groupe) se réalise au niveau de l'interface d'administration des permissions de GeoNature.

Il est possible de spéficier les permissions pour chaque type d'objet (groupes de sites, sites, visites et observations). 

Si aucune permission n'est associé à l'objet, les permissions auront comme valeurs celles associées au module qui lui même hérite des permissions du supermodule Monitoring qui lui même hérite de GéoNature.



Par défaut, dès qu'un utilisateur à un droit suppérieur à 0 pour une action (c-a-d aucune portée) il peut réaliser cette action. Il est possible de surcharger les paramètres au niveau des fichiers de configuration des objets du module. (cf configuration des sous-modules).

