#!/bin/bash
# Diagnostic du cluster

echo "=========================================="
echo "DIAGNOSTIC CLUSTER SPARK"
echo "=========================================="

# Terraform
echo ""
echo "--- Infrastructure Terraform ---"
cd terraform/environments/dev
terraform show | grep -E "name|ip_address" | head -20 || echo "Pas d'infrastructure"
cd ../../..

# Ansible connectivité
echo ""
echo "--- Connectivité Ansible ---"
cd ansible
ansible all -m ping -o || echo "Échec connexion"

# Services
echo ""
echo "--- Services Spark ---"
ansible spark_master -m shell -a "systemctl status spark-master | head -3" -o || echo "Master non démarré"
ansible spark_workers -m shell -a "systemctl status spark-worker | head -3" -o || echo "Workers non démarrés"

# Java
echo ""
echo "--- Versions ---"
ansible spark_cluster -m shell -a "java -version 2>&1 | head -1" -o

# Espace disque
echo ""
echo "--- Espace Disque ---"
ansible spark_cluster -m shell -a "df -h / | tail -1" -o

# Logs
echo ""
echo "--- Logs Master (20 dernières lignes) ---"
ansible spark_master -m shell -a "tail -20 /opt/spark/logs/spark-*.out 2>/dev/null || echo 'Pas de logs'" || echo "Impossible de lire"

cd ..

echo ""
echo "=========================================="
echo "Diagnostic terminé"
echo "=========================================="