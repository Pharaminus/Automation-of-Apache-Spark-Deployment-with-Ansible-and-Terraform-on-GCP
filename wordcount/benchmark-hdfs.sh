#!/bin/bash
# Benchmark WordCount avec HDFS

set -e

# Récupérer l'IP privée du master depuis l'inventaire
MASTER_PRIVATE_IP="10.0.0.5"  # À mettre à jour
MASTER_URL="spark://${MASTER_PRIVATE_IP}:7077"
HDFS_URL="hdfs://${MASTER_PRIVATE_IP}:9000"

OUTPUT_LOG="benchmark_hdfs_results.txt"

echo "==========================================" | tee $OUTPUT_LOG
echo "Benchmark WordCount HDFS - $(date)" | tee -a $OUTPUT_LOG
echo "==========================================" | tee -a $OUTPUT_LOG
echo "HDFS: $HDFS_URL" | tee -a $OUTPUT_LOG
echo "Spark Master: $MASTER_URL" | tee -a $OUTPUT_LOG
echo "==========================================" | tee -a $OUTPUT_LOG

# Vérifier la disponibilité HDFS
echo "Vérification HDFS..." | tee -a $OUTPUT_LOG
/opt/hadoop/bin/hdfs dfs -ls ${HDFS_URL}/user/spark-admin/wordcount/input/ | tee -a $OUTPUT_LOG

# Configurations à tester (adaptées aux ressources: 2 workers × 2 cores × 4GB)
declare -a CONFIGS=(
    "1:1G:1"
    "2:1G:1"
    "2:2G:1"
)

for config in "${CONFIGS[@]}"; do
    IFS=':' read -r num_ex mem cores <<< "$config"

    echo "" | tee -a $OUTPUT_LOG
    echo "--- Config: $num_ex executor(s), ${mem} RAM, $cores cores ---" | tee -a $OUTPUT_LOG

    OUTPUT_DIR="${HDFS_URL}/user/spark-admin/wordcount/output/benchmark-${num_ex}ex-${mem}-$(date +%s)"

    START=$(date +%s)

    /opt/spark/bin/spark-submit \
        --class WordCount \
        --master $MASTER_URL \
        --deploy-mode client \
        --num-executors $num_ex \
        --executor-memory $mem \
        --executor-cores $cores \
        --driver-memory 512M \
        --conf spark.default.parallelism=$((num_ex * cores * 2)) \
        wordcount.jar \
        ${HDFS_URL}/user/spark-admin/wordcount/input/benchmark_input.txt \
        $OUTPUT_DIR 2>&1 | tee benchmark_hdfs_run.log

    END=$(date +%s)
    DURATION=$((END - START))

    echo "Durée: ${DURATION}s" | tee -a $OUTPUT_LOG

    # Top 10 mots depuis HDFS
    echo "Top 10 mots:" | tee -a $OUTPUT_LOG
    /opt/hadoop/bin/hdfs dfs -cat ${OUTPUT_DIR}/part-* 2>/dev/null | head -10 | tee -a $OUTPUT_LOG || echo "Pas de résultats"

    # Statistiques de la tâche
    echo "Statistiques:" | tee -a $OUTPUT_LOG
    /opt/hadoop/bin/hdfs dfs -du -h $OUTPUT_DIR | tee -a $OUTPUT_LOG

    sleep 10
done

echo "" | tee -a $OUTPUT_LOG
echo "==========================================" | tee -a $OUTPUT_LOG
echo "Benchmark terminé !" | tee -a $OUTPUT_LOG
echo "Résultats: $OUTPUT_LOG" | tee -a $OUTPUT_LOG
echo "==========================================" | tee -a $OUTPUT_LOG

# Résumé
echo "" | tee -a $OUTPUT_LOG
echo "RÉSUMÉ DES PERFORMANCES:" | tee -a $OUTPUT_LOG
grep "Durée:" $OUTPUT_LOG | tee -a $OUTPUT_LOG

echo "" | tee -a $OUTPUT_LOG
echo "Pour voir tous les résultats dans HDFS:" | tee -a $OUTPUT_LOG
echo "  /opt/hadoop/bin/hdfs dfs -ls ${HDFS_URL}/user/spark-admin/wordcount/output/" | tee -a $OUTPUT_LOG