#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Krayin CRM - Reset de Senha do Admin${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Verificar se containers estão rodando
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${RED}❌ Containers não estão rodando!${NC}"
    echo "Execute primeiro: docker-compose up -d"
    exit 1
fi

# Solicitar email do admin
read -p "$(echo -e ${BLUE}Email do admin [padrão: admin@example.com]: ${NC})" ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@example.com}

# Validar formato de email
if [[ ! $ADMIN_EMAIL =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo -e "${RED}❌ Email inválido!${NC}"
    exit 1
fi

# Solicitar nova senha
echo ""
read -sp "$(echo -e ${BLUE}Nova senha: ${NC})" NEW_PASSWORD
echo ""

if [ -z "$NEW_PASSWORD" ]; then
    echo -e "${RED}❌ Senha não pode ser vazia!${NC}"
    exit 1
fi

# Confirmar senha
read -sp "$(echo -e ${BLUE}Confirme a senha: ${NC})" CONFIRM_PASSWORD
echo ""

if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
    echo -e "${RED}❌ Senhas não coincidem!${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔄 Resetando senha do admin...${NC}"

# Usar Laravel Tinker para resetar a senha
docker-compose exec app php artisan tinker --execute="
\$user = \Webkul\User\Models\Admin::where('email', '${ADMIN_EMAIL}')->first();
if (\$user) {
    \$user->password = bcrypt('${NEW_PASSWORD}');
    \$user->save();
    echo 'Senha atualizada com sucesso!';
} else {
    echo 'Usuário não encontrado!';
    exit(1);
}
"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  ✨ Senha Resetada com Sucesso!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}👤 Email:${NC} ${GREEN}${ADMIN_EMAIL}${NC}"
    echo -e "${BLUE}🔑 Nova senha:${NC} ${GREEN}[configurada]${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Guarde sua nova senha em local seguro!${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Erro ao resetar senha!${NC}"
    echo -e "${YELLOW}Verifique se o email está correto e tente novamente.${NC}"
    exit 1
fi
