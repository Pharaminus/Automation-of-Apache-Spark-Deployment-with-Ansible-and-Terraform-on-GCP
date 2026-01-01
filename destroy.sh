#!/bin/bash
# Détruire l'infrastructure

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=========================================="
echo "DESTRUCTION DE L'INFRASTRUCTURE"
echo -e "==========================================${NC}"

echo ""
echo -e "${RED}ATTENTION: Cette action est irréversible!${NC}"
echo ""
read -p "Êtes-vous sûr de vouloir détruire le cluster? (tapez 'destroy'): " confirm

if [ "$confirm" != "destroy" ]; then
    echo "Annulé"
    exit 0
fi

cd terraform/environments/dev

echo ""
echo "Destruction en cours..."
terraform destroy -auto-approve

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Infrastructure détruite"
    echo ""
    echo "Nettoyage local..."
    rm -f ../../../ansible/inventory/hosts.ini
    echo "✓ Inventory supprimé"
else
    echo "Erreur lors de la destruction"
    exit 1
fi

cd ../../..

echo ""
echo "=========================================="
echo "Infrastructure complètement supprimée"
echo "=========================================="