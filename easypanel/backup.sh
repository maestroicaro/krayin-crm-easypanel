#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Krayin CRM - Script de Backup${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Diretório de backup
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="krayin_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

# Criar diretório de backup
mkdir -p ${BACKUP_DIR}
mkdir -p ${BACKUP_PATH}

echo -e "${BLUE}📦 Criando backup em: ${BACKUP_PATH}${NC}"
echo ""

# Verificar se containers estão rodando
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  Containers não estão rodando. Iniciando...${NC}"
    docker-compose up -d
    sleep 10
fi

# Backup do banco de dados
echo -e "${BLUE}💾 Fazendo backup do banco de dados...${NC}"
docker-compose exec -T mysql mysqldump \
    -u root \
    -p${DB_ROOT_PASSWORD:-root_password} \
    ${DB_DATABASE:-krayin} \
    --single-transaction \
    --quick \
    --lock-tables=false \
    > ${BACKUP_PATH}/database.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Backup do banco de dados concluído${NC}"
else
    echo -e "${RED}❌ Erro ao fazer backup do banco de dados${NC}"
    exit 1
fi

# Backup do diretório storage
echo ""
echo -e "${BLUE}📁 Fazendo backup dos arquivos de storage...${NC}"
docker cp krayin-app:/var/www/html/storage ${BACKUP_PATH}/storage

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Backup do storage concluído${NC}"
else
    echo -e "${RED}❌ Erro ao fazer backup do storage${NC}"
fi

# Backup do arquivo .env
echo ""
echo -e "${BLUE}⚙️  Fazendo backup do arquivo .env...${NC}"
if [ -f .env ]; then
    cp .env ${BACKUP_PATH}/.env
    echo -e "${GREEN}✅ Backup do .env concluído${NC}"
else
    echo -e "${YELLOW}⚠️  Arquivo .env não encontrado${NC}"
fi

# Criar arquivo compactado
echo ""
echo -e "${BLUE}🗜️  Compactando backup...${NC}"
cd ${BACKUP_DIR}
tar -czf ${BACKUP_NAME}.tar.gz ${BACKUP_NAME}

if [ $? -eq 0 ]; then
    # Remover diretório não compactado
    rm -rf ${BACKUP_NAME}
    
    BACKUP_SIZE=$(du -h ${BACKUP_NAME}.tar.gz | cut -f1)
    
    echo -e "${GREEN}✅ Backup compactado com sucesso${NC}"
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  ✨ Backup Concluído!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}📦 Arquivo:${NC} ${GREEN}${BACKUP_DIR}/${BACKUP_NAME}.tar.gz${NC}"
    echo -e "${BLUE}📊 Tamanho:${NC} ${GREEN}${BACKUP_SIZE}${NC}"
    echo ""
    echo -e "${BLUE}📝 Para restaurar este backup:${NC}"
    echo -e "   1. Extrair: ${GREEN}tar -xzf ${BACKUP_NAME}.tar.gz${NC}"
    echo -e "   2. Restaurar DB: ${GREEN}docker-compose exec -T mysql mysql -u root -p[senha] krayin < ${BACKUP_NAME}/database.sql${NC}"
    echo -e "   3. Restaurar storage: ${GREEN}docker cp ${BACKUP_NAME}/storage krayin-app:/var/www/html/${NC}"
    echo ""
else
    echo -e "${RED}❌ Erro ao compactar backup${NC}"
    exit 1
fi

cd ..
