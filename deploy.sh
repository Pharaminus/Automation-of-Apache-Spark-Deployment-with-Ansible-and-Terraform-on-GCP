#!/bin/bash
# Déploiement complet du cluster

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Déploiement Cluster Spark sur GCP"
echo "=========================================="

# Vérification prérequis
echo "Vérification des prérequis..."
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform non installé${NC}"; exit 1; }
command -v ansible >/dev/null 2>&1 || { echo -e "${RED}Ansible non installé${NC}"; exit 1; }
command -v gcloud >/dev/null 2>&1 || { echo -e "${RED}gcloud non installé${NC}"; exit 1; }

echo -e "${GREEN}✓ Tous les outils installés${NC}"

# Vérifier les credentials
if [ ! -f ~/gcp-key.json ]; then
    echo -e "${RED}Fichier ~/gcp-key.json introuvable${NC}"
    echo "Créez d'abord votre service account et téléchargez la clé"
    exit 1
fi

# Vérifier la clé SSH
if [ ! -f ~/.ssh/spark-cluster ]; then
    echo -e "${YELLOW}Génération de la clé SSH...${NC}"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/spark-cluster -N "" -C "spark-admin"
fi

echo -e "${GREEN}✓ Credentials OK${NC}"

# Phase 1: Terraform
echo ""
echo "=========================================="
echo "PHASE 1: Infrastructure (Terraform)"
echo "=========================================="

cd terraform/environments/dev

terraform init
terraform validate

echo ""
terraform plan

echo ""
read -p "Appliquer ce plan? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo -e "${RED}Déploiement annulé${NC}"
    exit 1
fi

terraform apply -auto-approve

MASTER_IP=$(terraform output -raw master_ip)
echo -e "${GREEN}✓ Infrastructure créée${NC}"
echo "Master IP: $MASTER_IP"

# Attente initialisation
echo ""
echo "Attente de l'initialisation des VMs (60s)..."
for i in {60..1}; do
    echo -ne "\rTemps restant: ${i}s  "
    sleep 1
done
echo ""

cd ../../..

# Phase 2: Ansible
echo ""
echo "=========================================="
echo "PHASE 2: Configuration Spark (Ansible)"
echo "=========================================="

cd ansible

echo "Test de connectivité..."
if ! ansible all -m ping -o; then
    echo -e "${RED}Erreur de connexion aux VMs${NC}"
    echo "Attendez encore 30s et réessayez manuellement:"
    echo "  cd ansible"
    echo "  ansible-playbook playbooks/deploy-spark.yml"
    exit 1
fi

echo -e "${GREEN}✓ Toutes les VMs accessibles${NC}"

echo ""
echo "Installation de Spark (10-15 minutes)..."
ansible-playbook playbooks/deploy-spark.yml -v

cd ..

# Phase 3: Vérification
echo ""
echo "=========================================="
echo "PHASE 3: Vérification"
echo "=========================================="

cd ansible
echo "Vérification de Spark..."
ansible spark_master -m shell -a '/opt/spark/bin/spark-submit --version' | head -5

cd ..

# Résumé
echo ""
echo "=========================================="
echo -e "${GREEN}DÉPLOIEMENT TERMINÉ !${NC}"
echo "=========================================="
echo ""
echo "📊 Spark Master UI: http://$MASTER_IP:8080"
echo "🔐 SSH Master: ssh -i ~/.ssh/spark-cluster spark-admin@$MASTER_IP"
echo ""
echo "Prochaines étapes:"
echo "  1. Ouvrir http://$MASTER_IP:8080 dans votre navigateur"
echo "  2. Compiler WordCount: cd wordcount && ./build.sh"
echo "  3. Tester: ./test-wordcount.sh"
echo ""
echo "Pour détruire l'infrastructure:"
echo "  cd terraform/environments/dev"
echo "  terraform destroy -auto-approve"
echo "=========================================="