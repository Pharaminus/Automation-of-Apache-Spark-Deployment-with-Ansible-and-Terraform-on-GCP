#!/bin/bash
# Compilation de WordCount

set -e

echo "=========================================="
echo "Compilation WordCount"
echo "=========================================="

# Installer sbt si nécessaire
if ! command -v sbt &> /dev/null; then
    echo "Installation de sbt..."
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
    sudo apt-get update
    sudo apt-get install -y sbt
fi

# Compiler
echo "Compilation en cours..."
sbt clean assembly

if [ $? -eq 0 ]; then
    echo "✓ Compilation réussie"
    echo "JAR: target/scala-2.12/wordcount.jar"
    ls -lh target/scala-2.12/wordcount.jar
else
    echo "✗ Erreur de compilation"
    exit 1
fi