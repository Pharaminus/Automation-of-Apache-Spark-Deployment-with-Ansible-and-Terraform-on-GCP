# 🚀 Cluster Apache Spark sur Google Cloud Platform - Automatisation complète

> Déploiement automatisé d'un cluster Apache Spark distribué sur GCP avec HDFS, utilisant Terraform et Ansible.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple.svg)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.9+-red.svg)](https://www.ansible.com/)
[![Spark](https://img.shields.io/badge/Apache%20Spark-3.5.0-orange.svg)](https://spark.apache.org/)
[![Hadoop](https://img.shields.io/badge/Hadoop-3.3.6-yellow.svg)](https://hadoop.apache.org/)

---

## 📋 Table des matières

1. [Vue d'ensemble](#-vue-densemble)
2. [Architecture](#-architecture)
3. [Technologies utilisées](#-technologies-utilisées)
4. [Prérequis](#-prérequis)
5. [Installation pas à pas](#-installation-pas-à-pas)
6. [Utilisation](#-utilisation)
7. [Application WordCount](#-application-wordcount)
8. [Benchmarking](#-benchmarking)
9. [Maintenance et opérations](#-maintenance-et-opérations)
10. [Dépannage](#-dépannage)
11. [Architecture avancée](#-architecture-avancée)
12. [Contribuer](#-contribuer)
13. [Licence](#-licence)

---

## 🎯 Vue d'ensemble

Ce projet fournit une solution **clé en main** pour déployer un cluster Apache Spark de production sur Google Cloud Platform (GCP). Il combine l'Infrastructure as Code (IaC) avec Terraform et la gestion de configuration avec Ansible pour automatiser complètement le provisionnement et la configuration.

### Objectifs du projet

- ✅ **Automatisation complète** : Déploiement en une seule commande
- ✅ **Reproductibilité** : Infrastructure versionnable et reproductible
- ✅ **Production-ready** : Configuration optimisée pour la production
- ✅ **Évolutivité** : Ajout facile de nouveaux workers
- ✅ **Observabilité** : Interfaces Web pour monitoring
- ✅ **Stockage distribué** : HDFS intégré pour la persistance des données

### Cas d'usage

- **Big Data Analytics** : Traitement de volumes massifs de données
- **Machine Learning** : Entraînement de modèles distribués avec MLlib
- **ETL** : Extract, Transform, Load de données à grande échelle
- **Stream Processing** : Traitement de données en temps réel
- **Data Science** : Analyse exploratoire sur données volumineuses

---

## 🏗️ Architecture

### Architecture globale

```
┌─────────────────────────────────────────────────────────────────┐
│                    Google Cloud Platform (GCP)                   │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                      VPC Network (10.0.0.0/16)              │ │
│  │                                                              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │   Master     │  │   Worker 1   │  │   Worker 2   │     │ │
│  │  │  10.0.0.5    │  │  10.0.0.2    │  │  10.0.0.4    │     │ │
│  │  │              │  │              │  │              │     │ │
│  │  │ Spark Master │  │ Spark Worker │  │ Spark Worker │     │ │
│  │  │ HDFS NameNode│  │ HDFS DataNode│  │ HDFS DataNode│     │ │
│  │  │              │  │              │  │              │     │ │
│  │  │ e2-standard-4│  │ e2-standard-2│  │ e2-standard-2│     │ │
│  │  │ 4 vCPUs/16GB │  │ 2 vCPUs/8GB  │  │ 2 vCPUs/8GB  │     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  │                                                              │ │
│  │  ┌──────────────┐                                           │ │
│  │  │  Edge Node   │  (Point d'entrée pour les jobs)          │ │
│  │  │  10.0.0.3    │                                           │ │
│  │  │              │                                           │ │
│  │  │ Spark Client │                                           │ │
│  │  │ e2-medium    │                                           │ │
│  │  │ 2 vCPUs/4GB  │                                           │ │
│  │  └──────────────┘                                           │ │
│  │                                                              │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  Accès externe via IPs publiques + Firewall Rules               │
└─────────────────────────────────────────────────────────────────┘
```

### Composants du cluster

#### 1. **Spark Master** (Nœud principal)
- **Rôle** : Orchestration du cluster Spark
- **Services** :
  - Spark Master (port 7077)
  - Spark Web UI (port 8080)
  - HDFS NameNode (port 9000, 9870)
- **Machine** : e2-standard-4 (4 vCPUs, 16 GB RAM)
- **Stockage** : 50 GB SSD

#### 2. **Spark Workers** (Nœuds de calcul) × 2
- **Rôle** : Exécution des tâches Spark
- **Services** :
  - Spark Worker (port 8081)
  - HDFS DataNode (port 9866, 9864)
- **Machine** : e2-standard-2 (2 vCPUs, 8 GB RAM)
- **Stockage** : 50 GB SSD

#### 3. **Edge Node** (Nœud client)
- **Rôle** : Point d'entrée pour soumettre des jobs
- **Services** :
  - Spark Client
  - HDFS Client
- **Machine** : e2-medium (2 vCPUs, 4 GB RAM)
- **Stockage** : 30 GB SSD

### Architecture réseau

```
Internet
    │
    ├─── Firewall Rules
    │    ├─ SSH (22) : Accès admin
    │    ├─ Spark Master UI (8080) : Monitoring
    │    ├─ Spark Worker UI (8081) : Monitoring
    │    └─ HDFS NameNode UI (9870) : Monitoring
    │
    └─── VPC 10.0.0.0/16
         │
         ├─ Subnet: spark-subnet (10.0.0.0/24)
         │  └─ Communication interne entre nœuds
         │
         └─ NAT Gateway (pour accès sortant)
```

### Architecture Spark

```
┌────────────────────────────────────────────────────────┐
│                    Spark Application                    │
│                                                          │
│  ┌──────────────┐                                       │
│  │   Driver     │  (Gestion du job, DAG, scheduling)   │
│  └──────┬───────┘                                       │
│         │                                                │
│         │ spark://master:7077                           │
│         │                                                │
│  ┌──────▼────────────────────────────────────┐         │
│  │         Spark Cluster Manager             │         │
│  │           (Standalone Mode)                │         │
│  └──────┬────────────────────────────────────┘         │
│         │                                                │
│    ┌────┴────┐                                          │
│    │         │                                          │
│  ┌─▼──┐   ┌─▼──┐                                       │
│  │ Ex │   │ Ex │  (Executors - Exécution des tasks)   │
│  │ W1 │   │ W2 │                                       │
│  └────┘   └────┘                                       │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Architecture HDFS

```
┌──────────────────────────────────────────────────────────┐
│                    HDFS Architecture                      │
│                                                            │
│  ┌───────────────────┐                                    │
│  │    NameNode       │  (Métadonnées, namespace)         │
│  │   Master Node     │                                    │
│  └─────────┬─────────┘                                    │
│            │                                               │
│            │ Heartbeat & Block Reports                    │
│            │                                               │
│    ┌───────┴──────┐                                       │
│    │              │                                       │
│  ┌─▼──────┐   ┌──▼─────┐                                │
│  │DataNode│   │DataNode│  (Stockage des blocs de données)│
│  │Worker 1│   │Worker 2│                                 │
│  │        │   │        │                                 │
│  │ Blocs: │   │ Blocs: │                                 │
│  │ [B1,B3]│   │ [B2,B4]│  (Réplication: 2)               │
│  └────────┘   └────────┘                                 │
│                                                            │
│  Données distribuées et répliquées pour haute disponibilité│
└──────────────────────────────────────────────────────────┘
```

### Flux de données

```
1. Soumission du job
   User → Edge Node → spark-submit → Spark Master

2. Allocation des ressources
   Spark Master → Workers (création des Executors)

3. Lecture des données
   Executors → HDFS DataNodes (lecture parallèle des blocs)

4. Traitement
   Executors → Transformations/Actions sur les RDDs/DataFrames

5. Écriture des résultats
   Executors → HDFS DataNodes (écriture parallèle)

6. Retour au client
   Spark Master → Edge Node (résultats agrégés)
```

---

## 🔧 Technologies utilisées

### Infrastructure

| Technologie | Version | Rôle |
|------------|---------|------|
| **Terraform** | 1.0+ | Infrastructure as Code (provisionnement GCP) |
| **Ansible** | 2.9+ | Configuration management (installation et config) |
| **Google Cloud Platform** | - | Cloud provider (compute, network, storage) |

### Big Data Stack

| Technologie | Version | Rôle |
|------------|---------|------|
| **Apache Spark** | 3.5.0 | Framework de traitement distribué |
| **Apache Hadoop** | 3.3.6 | Système de fichiers distribué (HDFS) |
| **Scala** | 2.12.18 | Langage pour applications Spark |
| **SBT** | 1.9+ | Build tool pour Scala |

### Système

| Technologie | Version | Rôle |
|------------|---------|------|
| **Ubuntu** | 22.04 LTS | Système d'exploitation |
| **OpenJDK** | 11 | Runtime Java pour Spark/Hadoop |
| **systemd** | - | Gestion des services |

---

## 📦 Prérequis

### Sur votre machine locale

#### 1. Terraform (≥ 1.0)

**Installation sur Linux/macOS :**
```bash
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version
```

**Installation sur Windows :**
```powershell
choco install terraform
```

#### 2. Ansible (≥ 2.9)

**Installation sur Linux :**
```bash
sudo apt update
sudo apt install -y ansible
ansible --version
```

**Installation sur macOS :**
```bash
brew install ansible
```

#### 3. Google Cloud SDK

**Installation :**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

**Vérification :**
```bash
gcloud --version
```

#### 4. Autres outils

```bash
# Git
sudo apt install -y git

# SSH
sudo apt install -y openssh-client

# Python 3
sudo apt install -y python3 python3-pip

# jq (pour parsing JSON)
sudo apt install -y jq
```

### Compte Google Cloud Platform

#### 1. Créer un projet GCP

1. Aller sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créer un nouveau projet (ex: `spark-automation`)
3. Noter le Project ID (ex: `spark-automation-1767083359`)

#### 2. Activer les APIs nécessaires

```bash
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
```

#### 3. Créer un Service Account

```bash
# Créer le service account
gcloud iam service-accounts create terraform-sa \
    --display-name="Terraform Service Account"

# Donner les permissions nécessaires
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor"

# Générer la clé JSON
gcloud iam service-accounts keys create ~/gcp-key.json \
    --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

**⚠️ Important** : Sauvegarder le fichier `~/gcp-key.json` de manière sécurisée !

#### 4. Configurer les quotas GCP

Vérifier que vous avez les quotas suffisants :
- **CPUs** : Au moins 12 vCPUs (4+2+2+2+2)
- **IPs externes** : Au moins 4
- **Disques persistants** : Au moins 220 GB

---

## 🚀 Installation pas à pas

### Étape 1 : Cloner le projet

```bash
git clone <votre-repo>
cd spark-gcp-automation
```

### Étape 2 : Configuration initiale

#### 2.1 Configurer Terraform

```bash
cd terraform/environments/dev
```

Créer le fichier `terraform.tfvars` :

```hcl
# terraform.tfvars
project_id = "votre-project-id-gcp"
region     = "us-central1"
zone       = "us-central1-a"

# Optionnel : personnaliser les machines
master_machine_type = "e2-standard-4"
worker_machine_type = "e2-standard-2"
worker_count        = 2
```

#### 2.2 Initialiser Terraform

```bash
terraform init
```

**Sortie attendue :**
```
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

#### 2.3 Générer la clé SSH

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/spark-cluster -N "" -C "spark-admin"
```

### Étape 3 : Déploiement de l'infrastructure

#### 3.1 Planifier le déploiement

```bash
terraform plan
```

**Vérifier** :
- ✅ Nombre de ressources à créer
- ✅ Types de machines
- ✅ Configuration réseau

#### 3.2 Appliquer le déploiement

```bash
terraform apply
```

Taper `yes` pour confirmer.

**Durée estimée** : 3-5 minutes

**Sortie attendue :**
```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

master_ip = "35.239.9.113"
worker_ips = [
  "136.115.114.65",
  "34.123.84.20",
]
edge_public_ip = "34.59.1.236"
spark_ui_url = "http://35.239.9.113:8080"
```

**📝 Noter** : Conserver les IPs affichées !

#### 3.3 Vérifier l'infrastructure

```bash
# Lister les VMs créées
gcloud compute instances list

# Tester la connectivité SSH
ssh -i ~/.ssh/spark-cluster spark-admin@<MASTER_IP>
exit
```

### Étape 4 : Configuration avec Ansible

#### 4.1 Préparer l'inventaire

```bash
cd ../../../ansible
```

Vérifier que l'inventaire a été généré automatiquement :

```bash
cat inventory/hosts.ini
```

**Contenu attendu :**
```ini
[spark_master]
35.239.9.113 ansible_user=spark-admin ansible_ssh_private_key_file=~/.ssh/spark-cluster

[spark_workers]
136.115.114.65 ansible_user=spark-admin ansible_ssh_private_key_file=~/.ssh/spark-cluster
34.123.84.20 ansible_user=spark-admin ansible_ssh_private_key_file=~/.ssh/spark-cluster

[spark_edge]
34.59.1.236 ansible_user=spark-admin ansible_ssh_private_key_file=~/.ssh/spark-cluster

[spark_cluster:children]
spark_master
spark_workers
spark_edge
```

#### 4.2 Tester la connectivité Ansible

```bash
ansible all -m ping
```

**Sortie attendue :**
```
35.239.9.113 | SUCCESS => {"changed": false, "ping": "pong"}
136.115.114.65 | SUCCESS => {"changed": false, "ping": "pong"}
34.123.84.20 | SUCCESS => {"changed": false, "ping": "pong"}
34.59.1.236 | SUCCESS => {"changed": false, "ping": "pong"}
```

**⚠️ Si échec** : Attendre 1-2 minutes que les VMs finissent leur initialisation.

#### 4.3 Déployer Spark

```bash
ansible-playbook playbooks/deploy-spark.yml -v
```

**Durée estimée** : 10-15 minutes

**Ce qui est installé** :
1. ✅ Java OpenJDK 11
2. ✅ Apache Spark 3.5.0
3. ✅ Configuration des utilisateurs et groupes
4. ✅ Services systemd (spark-master, spark-worker)
5. ✅ Configuration réseau interne
6. ✅ Démarrage automatique des services

**Sortie attendue (fin) :**
```
PLAY RECAP *******************************************
35.239.9.113    : ok=25   changed=15   unreachable=0   failed=0
136.115.114.65  : ok=22   changed=14   unreachable=0   failed=0
34.123.84.20    : ok=22   changed=14   unreachable=0   failed=0
34.59.1.236     : ok=18   changed=12   unreachable=0   failed=0

Cluster Spark déployé !
Master UI: http://35.239.9.113:8080
```

#### 4.4 Vérifier Spark

**Ouvrir dans le navigateur** : `http://<MASTER_IP>:8080`

**Vérifier** :
- ✅ Workers : 2 actifs
- ✅ Cores : 4 total (2 par worker)
- ✅ Memory : 8 GB total (4 GB par worker)

### Étape 5 : Déployer HDFS

#### 5.1 Lancer le déploiement HDFS

```bash
ansible-playbook playbooks/deploy-hdfs.yml -v
```

**Durée estimée** : 15-20 minutes

**Ce qui est installé** :
1. ✅ Hadoop 3.3.6
2. ✅ Configuration HDFS (NameNode + DataNodes)
3. ✅ Formatage du NameNode
4. ✅ Configuration SSH entre nœuds
5. ✅ Services systemd (hdfs-namenode, hdfs-datanode)
6. ✅ Création des répertoires utilisateurs dans HDFS

**Sortie attendue (fin) :**
```
TASK [Message de succès] *************************************
ok: [35.239.9.113] =>
  msg:
  - =====================================
  - HDFS déployé avec succès !
  - =====================================
  - NameNode UI: http://10.0.0.5:9870
  - HDFS URI: hdfs://10.0.0.5:9000
  - =====================================

PLAY RECAP *************************************************
35.239.9.113    : ok=9    changed=4    unreachable=0    failed=0
136.115.114.65  : ok=3    changed=1    unreachable=0    failed=0
34.123.84.20    : ok=3    changed=1    unreachable=0    failed=0
```

#### 5.2 Vérifier HDFS

**SSH vers le master :**
```bash
ssh -i ~/.ssh/spark-cluster spark-admin@<MASTER_IP>
sudo su - hadoop
source /etc/profile.d/hadoop.sh

# Vérifier le rapport HDFS
hdfs dfsadmin -report
```

**Sortie attendue :**
```
Configured Capacity: 103670202368 (96.55 GB)
Present Capacity: 90261950464 (84.06 GB)
DFS Remaining: 90261901312 (84.06 GB)
DFS Used: 49152 (48 KB)
DFS Used%: 0.00%
...
Live datanodes (2):
...
```

**Vérifier l'UI** : `http://<MASTER_IP>:9870`

✅ Vous devriez voir :
- 2 DataNodes actifs
- ~96 GB de capacité
- 0% utilisé

### Étape 6 : Déployer l'application WordCount

#### 6.1 Compiler le projet

```bash
cd ../wordcount
./build.sh
```

**Sortie attendue :**
```
==========================================
Compilation WordCount
==========================================
[info] Compilation en cours...
[success] Total time: 12 s
✓ Compilation réussie
JAR: target/scala-2.12/wordcount.jar
-rw-rw-r-- 1 user user 5.3M wordcount.jar
```

#### 6.2 Déployer sur le cluster

```bash
./deploy-to-cluster.sh
```

**Ce script va** :
1. Récupérer l'IP du nœud Edge depuis Terraform
2. Créer le répertoire sur l'Edge
3. Copier le JAR compilé
4. Copier les données de test

**Sortie attendue :**
```
==========================================
Déploiement WordCount sur le cluster
==========================================
Edge IP: 34.59.1.236
Master IP: 35.239.9.113
✓ Déploiement terminé

Pour exécuter:
  ssh -i ~/.ssh/spark-cluster spark-admin@34.59.1.236
  cd /home/spark-admin/wordcount
  /opt/spark/bin/spark-submit \
    --class WordCount \
    --master spark://35.239.9.113:7077 \
    --num-executors 2 \
    --executor-memory 2G \
    wordcount.jar sample.txt output
```

#### 6.3 Uploader les données dans HDFS

```bash
./upload-to-hdfs.sh
```

**Ce script va** :
1. Copier les fichiers vers le master
2. Créer les répertoires dans HDFS
3. Uploader `sample.txt` et `benchmark_input.txt`

**Sortie attendue :**
```
==========================================
Upload des données vers HDFS
==========================================
Master IP: 35.239.9.113

Fichiers dans HDFS:
-rw-r--r--   2 hadoop supergroup      12M benchmark_input.txt
-rw-r--r--   2 hadoop supergroup    1.3K sample.txt

✓ Données uploadées vers HDFS
```

### Étape 7 : Tester l'installation

#### 7.1 Test simple sur HDFS

```bash
ssh -i ~/.ssh/spark-cluster spark-admin@<EDGE_IP>
cd /home/spark-admin/wordcount

# Lancer un job simple
/opt/spark/bin/spark-submit \
  --class WordCount \
  --master spark://10.0.0.5:7077 \
  --num-executors 2 \
  --executor-memory 1G \
  --executor-cores 1 \
  wordcount.jar \
  hdfs://10.0.0.5:9000/user/spark-admin/wordcount/input/sample.txt \
  hdfs://10.0.0.5:9000/user/spark-admin/wordcount/output/test-$(date +%s)
```

**Sortie attendue :**
```
=== WordCount Starting ===
Input: hdfs://10.0.0.5:9000/user/spark-admin/wordcount/input/sample.txt
Output: hdfs://10.0.0.5:9000/user/spark-admin/wordcount/output/test-1767344567
Executors: 2
Total lines: 20
Unique words: 15

=== Top 20 Most Frequent Words ===
spark                :      5
cluster              :      3
data                 :      2
...

=== WordCount Completed ===
Execution time: 8.45 seconds
```

#### 7.2 Vérifier les résultats dans HDFS

```bash
# Lister les résultats
hdfs dfs -ls hdfs://10.0.0.5:9000/user/spark-admin/wordcount/output/

# Lire les résultats
hdfs dfs -cat hdfs://10.0.0.5:9000/user/spark-admin/wordcount/output/test-*/part-* | head -20
```

---

## 💻 Utilisation

### Soumettre un job Spark

#### Format général

```bash
spark-submit \
  --class <MainClass> \
  --master <spark-master-url> \
  --deploy-mode <client|cluster> \
  --num-executors <nombre> \
  --executor-memory <RAM> \
  --executor-cores <cores> \
  --driver-memory <RAM> \
  <chemin-jar> \
  <arguments>
```

#### Exemple concret

```bash
/opt/spark/bin/spark-submit \
  --class WordCount \
  --master spark://10.0.0.5:7077 \
  --deploy-mode client \
  --num-executors 2 \
  --executor-memory 2G \
  --executor-cores 1 \
  --driver-memory 512M \
  wordcount.jar \
  hdfs://10.0.0.5:9000/user/spark-admin/input/data.txt \
  hdfs://10.0.0.5:9000/user/spark-admin/output/result
```

### Gestion HDFS

#### Commandes courantes

```bash
# Lister les fichiers
hdfs dfs -ls /user/spark-admin/

# Créer un répertoire
hdfs dfs -mkdir -p /user/spark-admin/data

# Uploader un fichier
hdfs dfs -put local-file.txt /user/spark-admin/data/

# Télécharger un fichier
hdfs dfs -get /user/spark-admin/data/file.txt ./

# Lire un fichier
hdfs dfs -cat /user/spark-admin/data/file.txt

# Supprimer un fichier
hdfs dfs -rm /user/spark-admin/data/file.txt

# Supprimer un répertoire
hdfs dfs -rm -r /user/spark-admin/data/

# Voir l'espace disque
hdfs dfs -df -h

# Voir l'utilisation
hdfs dfs -du -h /user/spark-admin/
```

#### Gestion des permissions

```bash
# Changer le propriétaire
hdfs dfs -chown user:group /path/to/file

# Changer les permissions
hdfs dfs -chmod 755 /path/to/file

# Changer récursivement
hdfs dfs -chmod -R 755 /path/to/directory
```

### Monitoring

#### Interfaces Web

| Service | URL | Description |
|---------|-----|-------------|
| **Spark Master UI** | `http://<MASTER_IP>:8080` | État du cluster, workers, applications |
| **Spark Worker UI** | `http://<WORKER_IP>:8081` | Détails d'un worker spécifique |
| **HDFS NameNode UI** | `http://<MASTER_IP>:9870` | État HDFS, DataNodes, blocs |
| **Application UI** | `http://<DRIVER_IP>:4040` | Détails d'une application en cours |

#### Commandes de monitoring

```bash
# État du cluster Spark
curl http://<MASTER_IP>:8080/json/ | jq .

# Rapport HDFS
hdfs dfsadmin -report

# État des services
ssh spark-admin@<MASTER_IP> 'sudo systemctl status spark-master'
ssh spark-admin@<WORKER_IP> 'sudo systemctl status spark-worker'
ssh spark-admin@<MASTER_IP> 'sudo systemctl status hdfs-namenode'
ssh spark-admin@<WORKER_IP> 'sudo systemctl status hdfs-datanode'
```

---

## 📊 Application WordCount

### Description

WordCount est une application Spark qui :
1. Lit un fichier texte depuis HDFS
2. Découpe en mots
3. Compte les occurrences de chaque mot
4. Trie par fréquence décroissante
5. Sauvegarde les résultats dans HDFS

### Architecture de l'application

```scala
// Lecture
textFile = sc.textFile("hdfs://...")

// Transformation
words = textFile.flatMap(line => line.split("\\W+"))
wordCounts = words.map(word => (word, 1))
                  .reduceByKey(_ + _)
                  .sortBy(_._2, ascending = false)

// Action
wordCounts.saveAsTextFile("hdfs://...")
```

### Code source

Le code complet se trouve dans [wordcount/src/main/scala/WordCount.scala](wordcount/src/main/scala/WordCount.scala).

### Utilisation

```bash
# Se connecter à l'Edge
ssh -i ~/.ssh/spark-cluster spark-admin@<EDGE_IP>
cd /home/spark-admin/wordcount

# Exécuter
/opt/spark/bin/spark-submit \
  --class WordCount \
  --master spark://10.0.0.5:7077 \
  --num-executors 2 \
  --executor-memory 1G \
  wordcount.jar \
  hdfs://10.0.0.5:9000/user/spark-admin/wordcount/input/sample.txt \
  hdfs://10.0.0.5:9000/user/spark-admin/wordcount/output/result-$(date +%s)
```

---

## 🔬 Benchmarking

### Script de benchmark

Le projet inclut un script de benchmark automatique qui teste différentes configurations :

```bash
cd /home/spark-admin/wordcount
./benchmark-hdfs.sh
```

### Configurations testées

| Config | Executors | RAM/Executor | Cores/Executor | Parallelism |
|--------|-----------|--------------|----------------|-------------|
| **Config 1** | 1 | 1G | 1 | 2 |
| **Config 2** | 2 | 1G | 1 | 4 |
| **Config 3** | 2 | 2G | 1 | 4 |

### Métriques collectées

- ⏱️ **Durée d'exécution** : Temps total du job
- 📊 **Top 10 mots** : Mots les plus fréquents
- 💾 **Taille de sortie** : Espace utilisé dans HDFS
- 📈 **Parallélisme** : Nombre de tâches parallèles

### Exemple de résultats

```
==========================================
Benchmark WordCount HDFS - Fri Jan 02 09:30:00 UTC 2026
==========================================
HDFS: hdfs://10.0.0.5:9000
Spark Master: spark://10.0.0.5:7077
==========================================

--- Config: 1 executor(s), 1G RAM, 1 cores ---
Durée: 45s
Top 10 mots:
(the,15234)
(and,12456)
(spark,8901)
...

--- Config: 2 executor(s), 1G RAM, 1 cores ---
Durée: 28s
Top 10 mots:
(the,15234)
(and,12456)
(spark,8901)
...

--- Config: 2 executor(s), 2G RAM, 1 cores ---
Durée: 25s
Top 10 mots:
(the,15234)
(and,12456)
(spark,8901)
...

RÉSUMÉ DES PERFORMANCES:
Durée: 45s
Durée: 28s
Durée: 25s
```

### Analyse des performances

**Observations** :
- ✅ **Parallélisme améliore les performances** : 2 executors = ~38% plus rapide
- ✅ **RAM supplémentaire apporte un gain marginal** : 2G vs 1G = ~10% plus rapide
- ✅ **Scalabilité linéaire** : Doubler les ressources ≈ diviser le temps par 2

---

## 🛠️ Maintenance et opérations

### Redémarrer les services

#### Spark

```bash
# Master
ssh spark-admin@<MASTER_IP> 'sudo systemctl restart spark-master'

# Workers
ssh spark-admin@<WORKER_IP> 'sudo systemctl restart spark-worker'
```

#### HDFS

```bash
# NameNode
ssh spark-admin@<MASTER_IP> 'sudo systemctl restart hdfs-namenode'

# DataNodes
ssh spark-admin@<WORKER_IP> 'sudo systemctl restart hdfs-datanode'
```

### Ajouter un worker

#### 1. Modifier Terraform

```hcl
# terraform.tfvars
worker_count = 3  # Au lieu de 2
```

#### 2. Appliquer les changements

```bash
cd terraform/environments/dev
terraform apply
```

#### 3. Configurer le nouveau worker

```bash
cd ../../../ansible

# Mettre à jour l'inventaire (le nouveau worker devrait apparaître)
ansible-playbook playbooks/deploy-spark.yml --limit=<NEW_WORKER_IP>
ansible-playbook playbooks/deploy-hdfs.yml --limit=<NEW_WORKER_IP>
```

### Sauvegarder les données HDFS

```bash
# Créer un snapshot
ssh spark-admin@<MASTER_IP>
sudo su - hadoop
hdfs dfsadmin -safemode enter
hdfs dfsadmin -saveNamespace

# Sauvegarder les métadonnées
tar -czf namenode-backup-$(date +%Y%m%d).tar.gz /data/hadoop/hdfs/namenode/

# Sortir du safe mode
hdfs dfsadmin -safemode leave
```

### Mise à jour de Spark

#### 1. Modifier la version

```yaml
# ansible/roles/spark-master/defaults/main.yml
spark_version: "3.5.1"  # Nouvelle version
```

#### 2. Redéployer

```bash
ansible-playbook playbooks/deploy-spark.yml
```

### Logs

#### Localisation des logs

```
Spark Master:  /opt/spark/logs/
Spark Worker:  /opt/spark/logs/
HDFS NameNode: /var/log/hadoop/
HDFS DataNode: /var/log/hadoop/
```

#### Consulter les logs

```bash
# Logs Spark Master
ssh spark-admin@<MASTER_IP> 'tail -f /opt/spark/logs/spark-*-master*.out'

# Logs HDFS NameNode
ssh spark-admin@<MASTER_IP> 'tail -f /var/log/hadoop/hadoop-*-namenode*.log'

# Logs via systemd
ssh spark-admin@<MASTER_IP> 'sudo journalctl -u spark-master -f'
```

---

## 🔍 Dépannage

### Problème : Workers ne se connectent pas au Master

**Symptôme** : 0 workers dans l'UI Spark (port 8080)

**Solution** :
```bash
# Vérifier que le master écoute
ssh spark-admin@<MASTER_IP> 'netstat -tlnp | grep 7077'

# Vérifier les logs du worker
ssh spark-admin@<WORKER_IP> 'tail -50 /opt/spark/logs/spark-*-worker*.out'

# Redémarrer le worker
ssh spark-admin@<WORKER_IP> 'sudo systemctl restart spark-worker'
```

### Problème : DataNodes ne se connectent pas au NameNode

**Symptôme** : 0 DataNodes dans l'UI HDFS (port 9870)

**Solution** :
```bash
# Vérifier que le NameNode écoute
ssh spark-admin@<MASTER_IP> 'sudo netstat -tlnp | grep 9000'

# Vérifier la configuration
ssh spark-admin@<WORKER_IP> 'cat /opt/hadoop/etc/hadoop/core-site.xml | grep fs.defaultFS'

# Vérifier les logs
ssh spark-admin@<WORKER_IP> 'tail -100 /var/log/hadoop/hadoop-*-datanode*.log'

# Redémarrer le DataNode
ssh spark-admin@<WORKER_IP> 'sudo systemctl restart hdfs-datanode'
```

### Problème : Job Spark échoue avec "FileNotFoundException"

**Symptôme** : `File hdfs://... does not exist`

**Solution** :
```bash
# Vérifier que le fichier existe dans HDFS
ssh spark-admin@<MASTER_IP>
sudo su - hadoop
hdfs dfs -ls /user/spark-admin/wordcount/input/

# Si absent, uploader le fichier
hdfs dfs -put local-file.txt /user/spark-admin/wordcount/input/
```

### Problème : "Initial job has not accepted any resources"

**Symptôme** : Job Spark ne démarre pas, attend indéfiniment

**Cause** : Pas assez de ressources disponibles

**Solution** :
```bash
# Vérifier les ressources disponibles
# UI Spark : http://<MASTER_IP>:8080

# Réduire les ressources demandées
spark-submit \
  --num-executors 1 \    # Au lieu de 2
  --executor-memory 1G \ # Au lieu de 2G
  --executor-cores 1 \   # Au lieu de 2
  ...
```

### Problème : HDFS en "Safe Mode"

**Symptôme** : `Name node is in safe mode`

**Solution** :
```bash
ssh spark-admin@<MASTER_IP>
sudo su - hadoop

# Vérifier le statut
hdfs dfsadmin -safemode get

# Forcer la sortie (si sûr)
hdfs dfsadmin -safemode leave
```

### Problème : Terraform apply échoue

**Symptôme** : `Error creating instance: quota exceeded`

**Solution** :
```bash
# Vérifier les quotas
gcloud compute project-info describe --project=YOUR_PROJECT_ID

# Demander une augmentation de quota via GCP Console
# Ou réduire les ressources demandées dans terraform.tfvars
```

### Problème : Ansible ping échoue

**Symptôme** : `UNREACHABLE! => {"changed": false, "msg": "Failed to connect"}`

**Solution** :
```bash
# Vérifier que les VMs sont démarrées
gcloud compute instances list

# Vérifier la clé SSH
ls -la ~/.ssh/spark-cluster*

# Tester SSH manuellement
ssh -i ~/.ssh/spark-cluster spark-admin@<MASTER_IP>

# Vérifier les règles firewall
gcloud compute firewall-rules list
```

---

## 🏛️ Architecture avancée

### Optimisations possibles

#### 1. Ajouter un Load Balancer

```hcl
# terraform/modules/network/main.tf
resource "google_compute_forwarding_rule" "spark_lb" {
  name       = "spark-lb"
  target     = google_compute_target_pool.spark_pool.self_link
  port_range = "7077"
}

resource "google_compute_target_pool" "spark_pool" {
  name = "spark-pool"
  instances = [
    for instance in google_compute_instance.spark_workers : instance.self_link
  ]
}
```

#### 2. Utiliser Preemptible VMs (coût réduit)

```hcl
# terraform/modules/compute/main.tf
resource "google_compute_instance" "spark_workers" {
  ...
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}
```

#### 3. Ajouter un autoscaler

```hcl
resource "google_compute_autoscaler" "workers" {
  name   = "spark-workers-autoscaler"
  target = google_compute_instance_group_manager.workers.self_link

  autoscaling_policy {
    min_replicas = 2
    max_replicas = 10
    cpu_utilization {
      target = 0.8
    }
  }
}
```

#### 4. Utiliser Cloud Storage au lieu de HDFS

```scala
// WordCount avec GCS
val input = "gs://my-bucket/input/data.txt"
val output = "gs://my-bucket/output/result"

spark.read.textFile(input)
  .flatMap(_.split("\\W+"))
  .groupBy("value")
  .count()
  .write.parquet(output)
```

### Haute disponibilité

#### NameNode HA avec Zookeeper

```yaml
# ansible/roles/hdfs/defaults/main.yml
hdfs_ha_enabled: true
namenode_ha_hosts:
  - master-1
  - master-2
zookeeper_hosts:
  - master-1:2181
  - master-2:2181
  - master-3:2181
```

#### Spark Master HA

```yaml
# ansible/roles/spark-master/defaults/main.yml
spark_ha_enabled: true
spark_master_recovery: ZOOKEEPER
spark_zookeeper_url: "master-1:2181,master-2:2181,master-3:2181"
```

### Sécurité

#### Activer Kerberos

```yaml
# ansible/roles/common/tasks/main.yml
- name: Configurer Kerberos
  apt:
    name:
      - krb5-user
      - krb5-config
    state: present
```

#### Chiffrer les communications

```yaml
# ansible/roles/spark-master/defaults/main.yml
spark_ssl_enabled: true
spark_ssl_keystore: /path/to/keystore.jks
spark_ssl_truststore: /path/to/truststore.jks
```

#### Authentification Spark

```yaml
spark_authentication_enabled: true
spark_secret: "{{ vault_spark_secret }}"
```

---

## 🤝 Contribuer

Les contributions sont les bienvenues !

### Comment contribuer

1. **Fork** le projet
2. Créer une **branche** (`git checkout -b feature/AmazingFeature`)
3. **Commiter** vos changements (`git commit -m 'Add AmazingFeature'`)
4. **Pousser** vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une **Pull Request**

### Guidelines

- Suivre le style de code existant
- Ajouter des tests si applicable
- Mettre à jour la documentation
- S'assurer que tous les tests passent

---

## 📚 Ressources

### Documentation officielle

- [Apache Spark](https://spark.apache.org/docs/latest/)
- [Apache Hadoop](https://hadoop.apache.org/docs/stable/)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Google Cloud Platform](https://cloud.google.com/docs)

### Tutoriels

- [Spark Programming Guide](https://spark.apache.org/docs/latest/rdd-programming-guide.html)
- [HDFS Architecture](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Communauté

- [Stack Overflow - Apache Spark](https://stackoverflow.com/questions/tagged/apache-spark)
- [Spark User Mailing List](https://spark.apache.org/community.html)

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👨‍💻 Auteurs

- **Balekamen babatack landry** - *Travail initial* - [(https://github.com/Pharaminus)](https://github.com/Pharaminus)

---

## 🙏 Remerciements

- L'équipe Apache Spark pour ce framework incroyable
- La communauté Terraform pour les modules GCP
- La communauté Ansible pour les rôles et playbooks

---

## 📞 Support

Pour toute question ou problème :

1. Consulter la section [Dépannage](#-dépannage)
2. Vérifier les [Issues GitHub](https://github.com/votre-repo/issues)
3. Ouvrir une nouvelle issue si le problème persiste

---

**Bon déploiement ! 🚀**