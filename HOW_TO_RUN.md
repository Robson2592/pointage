# Guide de Lancement du Projet

Ce guide explique comment configurer et lancer les deux parties de l'application.

## 1. Backend (Laravel)

Le backend gère l'API et la base de données PostgreSQL.

**Prérequis :** PHP 8.2+, Composer, PostgreSQL.

1.  **Installation des dépendances :**
    ```bash
    cd backend
    composer install
    ```
2.  **Configuration de l'environnement :**
    - Copiez le fichier `.env.example` vers `.env`.
    - Configurez vos accès PostgreSQL dans le fichier `.env` :
      ```text
      DB_CONNECTION=pgsql
      DB_HOST=127.0.0.1
      DB_PORT=5432
      DB_DATABASE=nom_de_votre_base
      DB_USERNAME=votre_utilisateur
      DB_PASSWORD=votre_mot_de_pass
      ```
3.  **Génération de la clé d'application :**
    ```bash
    php artisan key:generate
    ```
4.  **Migration de la base de données :**
    ```bash
    php artisan migrate
    ```
5.  **Lancement du serveur :**
    ```bash
    php artisan serve
    ```

## 2. Frontend (Flutter)

Le frontend est l'application mobile développée avec Riverpod.

**Prérequis :** Flutter SDK installed.

1.  **Récupération des packages :**
    ```bash
    cd frontend
    flutter pub get
    ```
2.  **Lancement de l'application :**
    - Assurez-vous d'avoir un simulateur ou un appareil connecté.
    ```bash
    flutter run
    ```

---

### Note Importante
Si vous travaillez sur un émulateur Android, l'URL de l'API dans `frontend/lib/Services/api_service.dart` doit être changée de `localhost` vers `10.0.2.2`.
```dart
// frontend/lib/Services/api_service.dart
baseUrl: 'http://10.0.2.2:8000/api',
```
