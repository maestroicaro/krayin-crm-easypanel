#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Krayin CRM - Script de Atualização${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Verificar se está rodando
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${RED}❌ Containers não estão rodando!${NC}"
    echo "Execute primeiro: docker-compose up -d"
    exit 1
fi

# Criar backup antes de atualizar
echo -e "${BLUE}💾 Criando backup antes da atualização...${NC}"
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_pre_update_${TIMESTAMP}.sql"

mkdir -p ${BACKUP_DIR}

# Backup do banco de dados
docker-compose exec -T mysql mysqldump -u root -p${DB_ROOT_PASSWORD:-root_password} ${DB_DATABASE:-krayin} > ${BACKUP_FILE}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Backup criado: ${BACKUP_FILE}${NC}"
else
    echo -e "${RED}❌ Erro ao criar backup!${NC}"
    read -p "$(echo -e ${YELLOW}Deseja continuar mesmo assim? [y/N]: ${NC})" CONTINUE
    if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}📥 Baixando última versão da imagem...${NC}"
docker-compose pull

echo ""
echo -e "${BLUE}🏗️  Reconstruindo containers...${NC}"
docker-compose build --no-cache

echo ""
echo -e "${BLUE}🔄 Parando containers...${NC}"
docker-compose down

echo ""
echo -e "${BLUE}🚀 Iniciando containers atualizados...${NC}"
docker-compose up -d

echo ""
echo -e "${BLUE}⏳ Aguardando containers iniciarem...${NC}"
sleep 15

# Executar migrations
echo ""
echo -e "${BLUE}📦 Executando migrations...${NC}"
docker-compose exec app php artisan migrate --force

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro ao executar migrations!${NC}"
    echo -e "${YELLOW}Você pode restaurar o backup em: ${BACKUP_FILE}${NC}"
    exit 1
fi

# Limpar caches
echo ""
echo -e "${BLUE}🧹 Limpando caches...${NC}"
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ✨ Atualização Concluída!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${BLUE}📊 Status dos containers:${NC}"
docker-compose ps
echo ""
echo -e "${BLUE}💾 Backup salvo em: ${GREEN}${BACKUP_FILE}${NC}"
echo ""
