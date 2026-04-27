# Momento - Workforce Management App

Momento est une solution complète de gestion de la main-d'œuvre, comprenant une application mobile Flutter moderne et un backend Laravel robuste. Elle permet le suivi précis des présences, la gestion des tâches et la planification des horaires.

## 🚀 Fonctionnalités Clés

### 👤 Pour les Employés
- **Pointage Multi-Modal** : Entrée/Sortie via QR Code, NFC, Géolocalisation ou Manuel.
- **Tableau de Bord Personnel** : Visualisation des heures travaillées aujourd'hui et progression des objectifs.
- **Gestion des Tâches** : Consultation et mise à jour des tâches assignées.
- **Planning** : Vue claire sur les horaires de travail de la semaine.
- **Profil** : Gestion des informations personnelles et déconnexion sécurisée.

### 🛡️ Pour les Administrateurs
- **Dashboard Admin** : Statistiques globales en temps réel (Employés présents vs absents).
- **Surveillance du Personnel** : Liste complète des employés avec indicateurs de présence en direct.
- **Historique Détaillé** : Consultation de l'historique complet des pointages pour n'importe quel employé.

---

## 🛠️ Stack Technique

### Frontend (Mobile)
- **Framework** : [Flutter](https://flutter.dev/)
- **Gestion d'État** : Riverpod
- **Client HTTP** : Dio
- **Stockage Sécurisé** : Flutter Secure Storage (pour les jetons JWT)
- **Animations** : Design Premium avec Glassmorphism et Dégradés.

### Backend (Serveur)
- **Framework** : [Laravel 11](https://laravel.com/)
- **Authentification** : Laravel Sanctum (Jetons Bearer)
- **Base de Données** : SQLite (pour une configuration simplifiée)
- **Gestion de Dates** : Carbon

---

## 🌐 Connectivité & Ngrok

Pour permettre à l'application mobile (sur téléphone physique ou émulateur) de communiquer avec le serveur Laravel tournant localement, nous utilisons **Ngrok**.

**Pourquoi Ngrok ?**
- Il crée un tunnel sécurisé (HTTPS) entre votre machine locale et Internet.
- Il permet de contourner les problèmes de configuration réseau complexes et d'IP locales changeantes.

**Configuration :**
1. Démarrez le serveur Laravel : `php artisan serve` (sur le port 8000).
2. Exposez-le via Ngrok : `ngrok http 8000`.
3. Copiez l'URL HTTPS générée par Ngrok (ex: `https://abcd-123.ngrok-free.app`) dans le fichier `lib/Services/api_service.dart` de l'application Flutter.

---

## 📦 Installation & Lancement

### 1. Backend
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed
php artisan serve
```

### 2. Frontend
```bash
cd frontend
flutter pub get
# Modifiez l'URL de l'API dans lib/Services/api_service.dart
flutter run
```

---

## 🔑 Identifiants de Test

| Rôle | Email | Mot de passe |
| :--- | :--- | :--- |
| **Administrateur** | `admin@pointage.com` | `admin123` |
| **Employé** | `employee@pointage.com` | `emp123` |

---

Développé avec ❤️ pour une gestion du personnel simplifiée et efficace.
