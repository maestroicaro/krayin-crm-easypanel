# Krayin CRM - Guia de Instalação no EasyPanel

![Krayin CRM](https://raw.githubusercontent.com/krayin/temp-media/master/dashboard.png)

## 📋 Índice

1. [Sobre](#sobre)
2. [Pré-requisitos](#pré-requisitos)
3. [Instalação Rápida](#instalação-rápida)
4. [Instalação Manual com Docker Compose](#instalação-manual-com-docker-compose)
5. [Configuração](#configuração)
6. [Credenciais Padrão](#credenciais-padrão)
7. [Pós-Instalação](#pós-instalação)
8. [Troubleshooting](#troubleshooting)
9. [Atualização](#atualização)
10. [Backup e Restauração](#backup-e-restauração)
11. [Otimização de Performance](#otimização-de-performance)

## Sobre

Esta é uma versão containerizada do **Krayin CRM** otimizada para deployment no EasyPanel. Inclui todas as dependências necessárias (PHP 8.2, MySQL 8.0, Redis 7, Nginx) em containers Docker prontos para produção.

## Pré-requisitos

### Para EasyPanel:
- Conta no EasyPanel
- Domínio (opcional, mas recomendado)

### Para Instalação Manual:
- Docker 20.10+
- Docker Compose 2.0+
- 2GB RAM mínimo (4GB recomendado)
- 10GB espaço em disco

## Instalação Rápida

### Usando EasyPanel

1. Acesse seu painel EasyPanel
2. Clique em **"New Service"**
3. Selecione **"From Template"**
4. Cole o conteúdo do arquivo `easypanel-template.json`
5. Configure as variáveis de ambiente (ou use os padrões)
6. Clique em **"Deploy"**
7. Aguarde 2-3 minutos para a instalação completar

✅ Pronto! Acesse sua URL e faça login com as credenciais padrão.

## Instalação Manual com Docker Compose

### Passo 1: Clone ou baixe este repositório

```bash
git clone https://github.com/krayin/laravel-crm.git
cd laravel-crm
```

### Passo 2: Execute o script de instalação

```bash
bash easypanel/install.sh
```

O script irá:
- ✅ Verificar se Docker está instalado
- ✅ Criar arquivo `.env` com configurações seguras
- ✅ Gerar senhas aleatórias para o banco de dados
- ✅ Construir as imagens Docker
- ✅ Iniciar todos os containers
- ✅ Executar migrations e seeders automaticamente

### Passo 3: Acesse a aplicação

Abra seu navegador em: `http://localhost:8080`

> **Nota**: A porta padrão é 8080, mas você pode alterá-la durante a instalação.

## Configuração

### Variáveis de Ambiente Principais

Edite o arquivo `.env` para personalizar sua instalação:

```env
# Aplicação
APP_NAME='Krayin CRM'
APP_ENV=production
APP_DEBUG=false
APP_URL=https://seu-dominio.com

# Banco de Dados
DB_HOST=mysql
DB_DATABASE=krayin
DB_USERNAME=krayin
DB_PASSWORD=sua_senha_segura

# Redis (Cache/Sessões/Filas)
REDIS_HOST=redis
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Email (Opcional)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-app
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@seu-dominio.com
```

### Portas Configuráveis

No arquivo `.env` ou `docker-compose.yml`:

```env
APP_PORT=8080        # Porta web da aplicação
MYSQL_PORT=3306      # Porta do MySQL
REDIS_PORT=6379      # Porta do Redis
```

## Credenciais Padrão

### Acesso Admin

```
URL: http://localhost:8080/admin/login
Email: admin@example.com
Senha: admin123
```

> ⚠️ **IMPORTANTE**: Altere a senha do admin imediatamente após o primeiro login!

### Banco de Dados

As credenciais do banco são geradas automaticamente durante a instalação e salvas no arquivo `.env`.

## Pós-Instalação

### 1. Alterar Senha do Admin

**Opção A - Via Interface Web:**
1. Faça login no painel admin
2. Vá em **Settings → My Account**
3. Altere sua senha

**Opção B - Via Script:**
```bash
bash easypanel/reset-admin.sh
```

### 2. Configurar Email (Opcional)

Para enviar emails (recuperação de senha, notificações, etc.):

1. Edite `.env` com suas configurações SMTP
2. Reinicie os containers:
```bash
docker-compose restart
```

3. Teste o envio de email no painel admin

### 3. Configurar Cron Jobs para Filas (Recomendado)

Para processar filas em background, adicione ao crontab do host:

```bash
* * * * * cd /caminho/para/laravel-crm && docker-compose exec -T app php artisan schedule:run >> /dev/null 2>&1
```

Ou inicie um worker de fila:

```bash
docker-compose exec app php artisan queue:work --daemon
```

### 4. Configurar HTTPS (Produção)

Para usar HTTPS, configure um proxy reverso (Nginx/Traefik) ou use o proxy do EasyPanel.

Atualize o `.env`:
```env
APP_URL=https://seu-dominio.com
```

## Troubleshooting

### Problema: Containers não iniciam

**Solução:**
```bash
# Ver logs
docker-compose logs -f

# Verificar status
docker-compose ps

# Reiniciar tudo
docker-compose down
docker-compose up -d
```

### Problema: Erro de conexão com banco de dados

**Sintomas:** "SQLSTATE[HY000] [2002] Connection refused"

**Solução:**
```bash
# Verificar se MySQL está rodando
docker-compose ps mysql

# Verificar logs do MySQL
docker-compose logs mysql

# Aguardar MySQL inicializar completamente (pode levar 30-60 segundos)
```

### Problema: Permissões de arquivo

**Sintomas:** Erro ao fazer upload de arquivos ou salvar logs

**Solução:**
```bash
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

### Problema: Página em branco ou erro 500

**Solução:**
```bash
# Limpar caches
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan view:clear

# Recriar caches
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache
```

### Problema: Assets (CSS/JS) não carregam

**Solução:**
```bash
# Reconstruir assets
docker-compose exec app npm run build

# Ou reconstruir a imagem
docker-compose build --no-cache app
docker-compose up -d
```

### Ver Logs da Aplicação

```bash
# Todos os serviços
docker-compose logs -f

# Apenas aplicação
docker-compose logs -f app

# Apenas MySQL
docker-compose logs -f mysql

# Últimas 100 linhas
docker-compose logs --tail=100 app
```

## Atualização

### Método Automático (Recomendado)

```bash
bash easypanel/update.sh
```

O script irá:
1. ✅ Criar backup automático do banco de dados
2. ✅ Baixar última versão da imagem
3. ✅ Reconstruir containers
4. ✅ Executar migrations
5. ✅ Limpar e recriar caches

### Método Manual

```bash
# 1. Fazer backup
bash easypanel/backup.sh

# 2. Baixar atualizações
git pull origin main

# 3. Reconstruir imagens
docker-compose build --no-cache

# 4. Reiniciar containers
docker-compose down
docker-compose up -d

# 5. Executar migrations
docker-compose exec app php artisan migrate --force

# 6. Limpar caches
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache
```

## Backup e Restauração

### Criar Backup

**Método Automático:**
```bash
bash easypanel/backup.sh
```

Isso cria um arquivo compactado em `backups/` contendo:
- Dump completo do banco de dados
- Todos os arquivos do diretório `storage/`
- Arquivo `.env` com configurações

**Método Manual:**
```bash
# Backup do banco de dados
docker-compose exec mysql mysqldump -u root -p[senha] krayin > backup_$(date +%Y%m%d).sql

# Backup do storage
docker cp krayin-app:/var/www/html/storage ./backup_storage
```

### Restaurar Backup

```bash
# 1. Extrair backup
tar -xzf backups/krayin_backup_YYYYMMDD_HHMMSS.tar.gz

# 2. Restaurar banco de dados
docker-compose exec -T mysql mysql -u root -p[senha] krayin < krayin_backup_YYYYMMDD_HHMMSS/database.sql

# 3. Restaurar storage
docker cp krayin_backup_YYYYMMDD_HHMMSS/storage krayin-app:/var/www/html/

# 4. Ajustar permissões
docker-compose exec app chown -R www-data:www-data storage
```

## Otimização de Performance

### 1. OPcache (Já Habilitado)

O OPcache está pré-configurado no Dockerfile para máxima performance:

```ini
opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=10000
opcache.validate_timestamps=0
```

### 2. Redis Cache

Redis está configurado para:
- ✅ Cache de aplicação
- ✅ Sessões de usuário
- ✅ Filas de jobs

Verifique conexão:
```bash
docker-compose exec app php artisan tinker --execute="Cache::put('test', 'OK', 60); echo Cache::get('test');"
```

### 3. Queue Workers

Para processar jobs em background:

```bash
# Iniciar worker
docker-compose exec -d app php artisan queue:work --tries=3

# Ou adicionar ao docker-compose.yml um serviço dedicado
```

### 4. Ajustar Recursos do Container

Edite `docker-compose.yml` para alocar mais recursos:

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

### 5. Monitoramento

```bash
# Ver uso de recursos
docker stats

# Ver processos PHP-FPM
docker-compose exec app ps aux | grep php-fpm
```

## Comandos Úteis

```bash
# Ver status dos containers
docker-compose ps

# Ver logs em tempo real
docker-compose logs -f

# Acessar shell do container
docker-compose exec app bash

# Executar comandos Artisan
docker-compose exec app php artisan [comando]

# Limpar tudo e recomeçar
docker-compose down -v
docker-compose up -d

# Ver uso de espaço
docker system df
```

## Suporte

- **Documentação Oficial**: https://devdocs.krayincrm.com
- **Fórum**: https://forums.krayincrm.com
- **GitHub Issues**: https://github.com/krayin/laravel-crm/issues

## Licença

Krayin CRM é open-source sob a [Licença MIT](https://github.com/krayin/laravel-crm/blob/master/LICENSE).
