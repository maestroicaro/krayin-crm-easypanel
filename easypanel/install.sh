#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Krayin CRM - Script de Instalação${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não está instalado!${NC}"
    echo "Por favor, instale o Docker primeiro: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose não está instalado!${NC}"
    echo "Por favor, instale o Docker Compose primeiro: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✅ Docker e Docker Compose encontrados${NC}"
echo ""

# Verificar se arquivo .env existe
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  Arquivo .env não encontrado${NC}"
    echo -e "${BLUE}📝 Criando .env a partir de .env.example...${NC}"
    cp .env.example .env
    
    # Gerar senha aleatória para banco de dados
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    ROOT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    
    # Atualizar .env com senhas geradas
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env
    
    echo -e "${GREEN}✅ Arquivo .env criado com senhas seguras${NC}"
    echo ""
    echo -e "${YELLOW}📋 Credenciais do Banco de Dados:${NC}"
    echo -e "   Database: krayin"
    echo -e "   Username: krayin"
    echo -e "   Password: ${DB_PASSWORD}"
    echo -e "   Root Password: ${ROOT_PASSWORD}"
    echo ""
    echo -e "${YELLOW}⚠️  Salve essas credenciais em local seguro!${NC}"
    echo ""
fi

# Perguntar porta de acesso
read -p "$(echo -e ${BLUE}Porta para acesso web [padrão: 8080]: ${NC})" APP_PORT
APP_PORT=${APP_PORT:-8080}

# Atualizar porta no .env se necessário
if ! grep -q "APP_PORT=" .env; then
    echo "APP_PORT=${APP_PORT}" >> .env
else
    sed -i "s/APP_PORT=.*/APP_PORT=${APP_PORT}/" .env
fi

echo ""
echo -e "${BLUE}🏗️  Construindo imagens Docker...${NC}"
docker-compose build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro ao construir imagens Docker${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🚀 Iniciando containers...${NC}"
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro ao iniciar containers${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}⏳ Aguardando serviços iniciarem (isso pode levar alguns minutos)...${NC}"
sleep 10

# Verificar status dos containers
echo ""
echo -e "${BLUE}📊 Status dos containers:${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ✨ Instalação Concluída!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${BLUE}🌐 URL de Acesso:${NC} http://localhost:${APP_PORT}"
echo ""
echo -e "${BLUE}👤 Credenciais de Admin Padrão:${NC}"
echo -e "   Email: ${GREEN}admin@example.com${NC}"
echo -e "   Senha: ${GREEN}admin123${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE: Altere a senha do admin após primeiro login!${NC}"
echo ""
echo -e "${BLUE}📝 Comandos Úteis:${NC}"
echo -e "   Ver logs:        ${GREEN}docker-compose logs -f${NC}"
echo -e "   Parar:           ${GREEN}docker-compose stop${NC}"
echo -e "   Reiniciar:       ${GREEN}docker-compose restart${NC}"
echo -e "   Remover tudo:    ${GREEN}docker-compose down -v${NC}"
echo ""
echo -e "${BLUE}================================================${NC}"
