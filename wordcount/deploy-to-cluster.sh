#!/bin/bash
# Déployer WordCount sur le cluster

set -e

echo "=========================================="
echo "Déploiement WordCount sur le cluster"
echo "=========================================="

# Récupérer l'IP de l'edge node
cd ../terraform/environments/dev
EDGE_IP=$(terraform output -raw edge_public_ip)
MASTER_IP=$(terraform output -raw master_ip)
cd ../../../wordcount

echo "Edge IP: $EDGE_IP"
echo "Master IP: $MASTER_IP"

# Créer le répertoire sur l'edge
echo "Création du répertoire distant..."
ssh -i ~/.ssh/spark-cluster spark-admin@$EDGE_IP "mkdir -p /home/spark-admin/wordcount"

# Copier le JAR
echo "Copie du JAR..."
scp -i ~/.ssh/spark-cluster target/scala-2.12/wordcount.jar \
    spark-admin@$EDGE_IP:/home/spark-admin/wordcount/

# Copier les données de test
echo "Copie des données..."
scp -i ~/.ssh/spark-cluster data/sample.txt \
    spark-admin@$EDGE_IP:/home/spark-admin/wordcount/

echo ""
echo "✓ Déploiement terminé"
echo ""
echo "Pour exécuter:"
echo "  ssh -i ~/.ssh/spark-cluster spark-admin@$EDGE_IP"
echo "  cd /home/spark-admin/wordcount"
echo "  /opt/spark/bin/spark-submit \\"
echo "    --class WordCount \\"
echo "    --master spark://${MASTER_IP}:7077 \\"
echo "    --num-executors 2 \\"
echo "    --executor-memory 2G \\"
echo "    wordcount.jar sample.txt output"