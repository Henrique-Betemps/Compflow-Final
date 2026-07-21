#!/usr/bin/env bash
# ============================================================
# Elimina a duplicação de frontend do projeto CompFlow.
#
# Situação atual: existem 3 cópias dos mesmos HTML/CSS/JS:
#   1) compflow-integrado/                              <- pasta de trabalho solta
#   2) compflow-java/src/main/resources/static/         <- FONTE REAL servida pelo Spring
#   3) compflow-java/target/classes/static/             <- gerada automaticamente no build
#
# Este script:
#   - Faz backup da pasta compflow-integrado/ (por segurança)
#   - Remove compflow-integrado/ do controle do dia a dia
#   - Remove target/ inteiro (é sempre regenerado pelo Maven)
#
# Rode este script a partir da RAIZ do projeto (onde está o
# Dockerfile e a pasta compflow-java/).
# ============================================================

set -e

ROOT_DIR="$(pwd)"
JAVA_DIR="$ROOT_DIR/compflow-java"
STATIC_DIR="$JAVA_DIR/src/main/resources/static"
INTEGRADO_DIR="$ROOT_DIR/compflow-integrado"

if [ ! -d "$STATIC_DIR" ]; then
  echo "ERRO: não encontrei $STATIC_DIR"
  echo "Rode este script na raiz do projeto (onde fica a pasta compflow-java/)."
  exit 1
fi

echo "Fonte de verdade do frontend: $STATIC_DIR"

if [ -d "$INTEGRADO_DIR" ]; then
  BACKUP_DIR="$ROOT_DIR/_backup_compflow-integrado_$(date +%Y%m%d%H%M%S)"
  echo "Fazendo backup de compflow-integrado/ em: $BACKUP_DIR"
  mv "$INTEGRADO_DIR" "$BACKUP_DIR"
  echo "compflow-integrado/ removida do caminho de trabalho (backup preservado)."
else
  echo "compflow-integrado/ não encontrada (ok, já removida antes)."
fi

TARGET_DIR="$JAVA_DIR/target"
if [ -d "$TARGET_DIR" ]; then
  echo "Removendo $TARGET_DIR (é sempre regenerado por 'mvn clean package')."
  rm -rf "$TARGET_DIR"
else
  echo "target/ não encontrado (ok, nada a remover)."
fi

echo ""
echo "Concluído. A partir de agora, edite SOMENTE os arquivos em:"
echo "  $STATIC_DIR"
echo ""
echo "Para gerar o build novamente:"
echo "  cd compflow-java && mvn clean package"
