#!/bin/bash
set -e

echo "🚀 Krayin CRM - Iniciando container..."

# Função para aguardar MySQL
wait_for_mysql() {
    echo "⏳ Aguardando MySQL estar disponível..."
    
    MAX_TRIES=30
    COUNT=0
    
    until php -r "
        try {
            \$pdo = new PDO(
                'mysql:host=${DB_HOST:-mysql};port=3306',
                '${DB_USERNAME:-krayin}',
                '${DB_PASSWORD:-krayin_password}'
            );
            exit(0);
        } catch (PDOException \$e) {
            exit(1);
        }
    " 2>/dev/null; do
        COUNT=$((COUNT + 1))
        if [ $COUNT -ge $MAX_TRIES ]; then
            echo "❌ Erro: MySQL não está disponível após $MAX_TRIES tentativas"
            echo "   Verifique as credenciais do banco de dados no .env"
            echo "   DB_HOST=${DB_HOST:-mysql}"
            echo "   DB_USERNAME=${DB_USERNAME:-krayin}"
            exit 1
        fi
        echo "   Tentativa $COUNT/$MAX_TRIES - Aguardando MySQL..."
        sleep 2
    done
    
    echo "✅ MySQL está disponível!"
}

# Aguardar MySQL
wait_for_mysql

# Verificar e criar .env se não existir
if [ ! -f .env ]; then
    echo "📝 Criando arquivo .env a partir de .env.example..."
    cp .env.example .env
fi

# Gerar APP_KEY se não existir
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Gerando APP_KEY..."
    php artisan key:generate --force
fi

# Verificar se é a primeira execução (verificando se tabelas existem)
FIRST_RUN=false
if ! php artisan tinker --execute="echo count(DB::select('SHOW TABLES'));" 2>/dev/null | grep -q "[1-9]"; then
    echo "🆕 Primeira execução detectada - Inicializando banco de dados..."
    FIRST_RUN=true
fi

# Se for primeira execução, executar instalação
if [ "$FIRST_RUN" = true ]; then
    echo "📦 Executando instalação do Krayin CRM..."
    
    # Executar migrations
    php artisan migrate --force
    
    # Executar seeders
    php artisan db:seed --force
    
    # Criar arquivo de flag de instalação
    touch storage/.installed
    
    echo "✅ Instalação concluída!"
else
    echo "♻️  Instalação existente detectada - Executando migrations pendentes..."
    php artisan migrate --force
fi

# Criar link simbólico do storage
if [ ! -L public/storage ]; then
    echo "🔗 Criando link simbólico do storage..."
    php artisan storage:link
fi

# Otimizações de cache para produção
if [ "${APP_ENV:-production}" = "production" ]; then
    echo "⚡ Otimizando para produção..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
else
    echo "🔧 Modo de desenvolvimento - Limpando caches..."
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
fi

# Ajustar permissões
echo "🔒 Ajustando permissões..."
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

echo "✨ Inicialização concluída! Iniciando serviços..."
echo ""
echo "================================================"
echo "  Krayin CRM está pronto!"
echo "================================================"
echo "  URL: http://localhost (ou seu domínio configurado)"
echo "  Admin: admin@example.com"
echo "  Senha: admin123"
echo "================================================"
echo ""

# Executar comando passado como argumento ou CMD padrão
exec "$@"
