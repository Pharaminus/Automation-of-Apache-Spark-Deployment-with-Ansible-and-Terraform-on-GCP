#!/bin/bash
# Benchmark WordCount avec différentes configurations

set -e

# À remplacer avec l'IP privée réelle du master
MASTER_IP="10.0.0.2"  # Remplacer!
MASTER_URL="spark://${MASTER_IP}:7077"

OUTPUT_LOG="benchmark_results.txt"

echo "==========================================" | tee $OUTPUT_LOG
echo "Benchmark WordCount - $(date)" | tee -a $OUTPUT_LOG
echo "==========================================" | tee -a $OUTPUT_LOG

# Générer un fichier de test volumineux
echo "Génération du fichier de test..." | tee -a $OUTPUT_LOG
for i in {1..10000}; do
    cat sample.txt
done > benchmark_input.txt

echo "Taille: $(du -h benchmark_input.txt | cut -f1)" | tee -a $OUTPUT_LOG
echo "Lignes: $(wc -l < benchmark_input.txt)" | tee -a $OUTPUT_LOG

# Configurations à tester
declare -a CONFIGS=(
    "1:2G:2"
    "2:2G:2"
    "3:2G:2"
)

for config in "${CONFIGS[@]}"; do
    IFS=':' read -r num_ex mem cores <<< "$config"
    
    echo "" | tee -a $OUTPUT_LOG
    echo "--- Config: $num_ex executor(s), ${mem} RAM, $cores cores ---" | tee -a $OUTPUT_LOG
    
    OUTPUT_DIR="benchmark-output-${num_ex}ex-${mem}-$(date +%s)"
    
    START=$(date +%s)
    
    /opt/spark/bin/spark-submit \
        --class WordCount \
        --master $MASTER_URL \
        --deploy-mode client \
        --num-executors $num_ex \
        --executor-memory $mem \
        --executor-cores $cores \
        --driver-memory 1G \
        --conf spark.default.parallelism=$((num_ex * cores * 2)) \
        wordcount.jar \
        benchmark_input.txt \
        $OUTPUT_DIR 2>&1 | tee benchmark_run.log
    
    END=$(date +%s)
    DURATION=$((END - START))
    
    echo "Durée: ${DURATION}s" | tee -a $OUTPUT_LOG
    
    # Top 10 mots
    echo "Top 10 mots:" | tee -a $OUTPUT_LOG
    cat $OUTPUT_DIR/part-* | head -10 | tee -a $OUTPUT_LOG
    
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