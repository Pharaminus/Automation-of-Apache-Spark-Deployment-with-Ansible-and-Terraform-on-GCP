#!/bin/bash
# Script complet pour tester WordCount

set -e

echo "=========================================="
echo "Test complet WordCount"
echo "=========================================="

# Récupérer les IPs
cd terraform/environments/dev
MASTER_PRIV=$(terraform output -json | jq -r '.master_ip.value')
EDGE_IP=$(terraform output -json | jq -r '.edge_public_ip.value')
cd ../../..

echo "Master: $MASTER_PRIV"
echo "Edge: $EDGE_IP"

# Compiler
echo ""
echo "Compilation..."
cd wordcount
chmod +x build.sh
./build.sh

# Déployer
echo ""
echo "Déploiement..."
chmod +x deploy-to-cluster.sh
./deploy-to-cluster.sh

echo ""
echo "✓ WordCount déployé"
echo ""
echo "Maintenant, connectez-vous à l'edge node et lancez le benchmark:"
echo "  ssh -i ~/.ssh/spark-cluster spark-admin@$EDGE_IP"
echo "  cd /home/spark-admin/wordcount"
echo "  # Éditer benchmark.sh pour mettre MASTER_IP=$MASTER_PRIV"
echo "  chmod +x benchmark.sh"
echo "  ./benchmark.sh"