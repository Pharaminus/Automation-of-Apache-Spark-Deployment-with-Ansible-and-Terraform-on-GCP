#!/bin/bash
# Upload des données de test vers HDFS

set -e

echo "=========================================="
echo "Upload des données vers HDFS"
echo "=========================================="

# Récupérer l'IP du master
cd ../terraform/environments/dev
MASTER_IP=$(terraform output -raw master_ip)
cd ../../../wordcount

echo "Master IP: $MASTER_IP"

# Se connecter au master et uploader les fichiers
echo "Copie des fichiers locaux vers le master..."
scp -i ~/.ssh/spark-cluster data/sample.txt spark-admin@$MASTER_IP:/tmp/

echo "Upload vers HDFS..."
ssh -i ~/.ssh/spark-cluster spark-admin@$MASTER_IP << 'ENDSSH'
    export HADOOP_HOME=/opt/hadoop
    export PATH=$PATH:$HADOOP_HOME/bin

    echo "Création des répertoires HDFS..."
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/spark-admin/wordcount/input

    echo "Upload de sample.txt..."
    $HADOOP_HOME/bin/hdfs dfs -put -f /tmp/sample.txt /user/spark-admin/wordcount/input/

    echo "Génération d'un fichier volumineux..."
    for i in {1..10000}; do
        cat /tmp/sample.txt
    done > /tmp/benchmark_input.txt

    echo "Upload de benchmark_input.txt..."
    $HADOOP_HOME/bin/hdfs dfs -put -f /tmp/benchmark_input.txt /user/spark-admin/wordcount/input/

    echo "Nettoyage..."
    rm -f /tmp/sample.txt /tmp/benchmark_input.txt

    echo ""
    echo "Fichiers dans HDFS:"
    $HADOOP_HOME/bin/hdfs dfs -ls -h /user/spark-admin/wordcount/input/
ENDSSH

echo ""
echo "✓ Données uploadées vers HDFS"
echo ""
echo "Chemins HDFS:"
echo "  - hdfs://$MASTER_IP:9000/user/spark-admin/wordcount/input/sample.txt"
echo "  - hdfs://$MASTER_IP:9000/user/spark-admin/wordcount/input/benchmark_input.txt"