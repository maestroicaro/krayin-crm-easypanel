# Scripts de Automação - Krayin CRM

Este diretório contém scripts auxiliares para facilitar o gerenciamento do Krayin CRM em containers Docker.

## 📜 Scripts Disponíveis

### 1. install.sh - Instalação Automatizada

**Descrição**: Script completo de instalação que configura todo o ambiente.

**Uso**:
```bash
bash easypanel/install.sh
```

**O que faz**:
- ✅ Verifica instalação do Docker e Docker Compose
- ✅ Cria arquivo `.env` a partir do `.env.example`
- ✅ Gera senhas seguras para banco de dados
- ✅ Constrói imagens Docker
- ✅ Inicia todos os containers
- ✅ Exibe credenciais e URLs de acesso

**Parâmetros**: Nenhum (interativo)

---

### 2. update.sh - Atualização da Aplicação

**Descrição**: Atualiza a aplicação para a versão mais recente com backup automático.

**Uso**:
```bash
bash easypanel/update.sh
```

**O que faz**:
- ✅ Cria backup do banco de dados antes de atualizar
- ✅ Baixa última versão da imagem Docker
- ✅ Reconstrói containers
- ✅ Executa migrations pendentes
- ✅ Limpa e recria caches
- ✅ Reinicia serviços

**Parâmetros**: Nenhum

**Variáveis de Ambiente Necessárias**:
- `DB_ROOT_PASSWORD` - Senha root do MySQL
- `DB_DATABASE` - Nome do banco de dados

---

### 3. backup.sh - Backup Completo

**Descrição**: Cria backup completo do banco de dados, arquivos e configurações.

**Uso**:
```bash
bash easypanel/backup.sh
```

**O que faz**:
- ✅ Cria dump do banco de dados MySQL
- ✅ Copia diretório `storage/` (uploads, logs, cache)
- ✅ Copia arquivo `.env`
- ✅ Compacta tudo em arquivo `.tar.gz` com timestamp

**Saída**: Arquivo em `backups/krayin_backup_YYYYMMDD_HHMMSS.tar.gz`

**Parâmetros**: Nenhum

**Exemplo de Restauração**:
```bash
# Extrair backup
tar -xzf backups/krayin_backup_20250130_143022.tar.gz

# Restaurar banco
docker-compose exec -T mysql mysql -u root -p[senha] krayin < krayin_backup_20250130_143022/database.sql

# Restaurar storage
docker cp krayin_backup_20250130_143022/storage krayin-app:/var/www/html/
```

---

### 4. reset-admin.sh - Reset de Senha do Admin

**Descrição**: Reseta a senha de um usuário administrador.

**Uso**:
```bash
bash easypanel/reset-admin.sh
```

**O que faz**:
- ✅ Solicita email do admin (padrão: admin@example.com)
- ✅ Valida formato do email
- ✅ Solicita nova senha com confirmação
- ✅ Atualiza senha no banco de dados usando Laravel Tinker

**Parâmetros**: Nenhum (interativo)

**Exemplo de Uso**:
```
Email do admin [padrão: admin@example.com]: admin@meusite.com
Nova senha: ********
Confirme a senha: ********
✅ Senha resetada com sucesso!
```

---

## 🔧 Configuração dos Scripts

### Permissões

Os scripts precisam de permissão de execução:

```bash
chmod +x easypanel/*.sh
```

### Variáveis de Ambiente

Alguns scripts usam variáveis do arquivo `.env`:

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `DB_DATABASE` | Nome do banco de dados | `krayin` |
| `DB_USERNAME` | Usuário do banco | `krayin` |
| `DB_PASSWORD` | Senha do banco | - |
| `DB_ROOT_PASSWORD` | Senha root do MySQL | `root_password` |

### Cores no Terminal

Os scripts usam cores ANSI para melhor visualização:
- 🔵 **Azul**: Informações
- 🟢 **Verde**: Sucesso
- 🟡 **Amarelo**: Avisos
- 🔴 **Vermelho**: Erros

---

## 📋 Troubleshooting

### Script não executa

**Problema**: `bash: ./install.sh: Permission denied`

**Solução**:
```bash
chmod +x easypanel/install.sh
bash easypanel/install.sh
```

### Erro: Docker não encontrado

**Problema**: `Docker não está instalado!`

**Solução**: Instale o Docker:
- Windows/Mac: https://www.docker.com/products/docker-desktop
- Linux: https://docs.docker.com/engine/install/

### Erro no backup

**Problema**: `Erro ao fazer backup do banco de dados`

**Solução**:
```bash
# Verificar se MySQL está rodando
docker-compose ps mysql

# Verificar senha root
docker-compose exec mysql mysql -u root -p[senha] -e "SELECT 1"
```

### Erro ao resetar senha

**Problema**: `Usuário não encontrado!`

**Solução**:
```bash
# Listar todos os admins
docker-compose exec app php artisan tinker --execute="
\Webkul\User\Models\Admin::all(['id', 'name', 'email'])->each(function(\$u) {
    echo \$u->id . ' - ' . \$u->name . ' (' . \$u->email . ')' . PHP_EOL;
});
"
```

---

## 🚀 Automação com Cron

### Backup Automático Diário

Adicione ao crontab:

```bash
# Editar crontab
crontab -e

# Adicionar linha (backup às 2h da manhã)
0 2 * * * cd /caminho/para/laravel-crm && bash easypanel/backup.sh >> /var/log/krayin-backup.log 2>&1
```

### Limpeza de Backups Antigos

```bash
# Manter apenas backups dos últimos 30 dias
0 3 * * * find /caminho/para/laravel-crm/backups -name "*.tar.gz" -mtime +30 -delete
```

---

## 📞 Suporte

Para problemas com os scripts:

1. Verifique os logs: `docker-compose logs -f`
2. Consulte o [README-EASYPANEL.md](../README-EASYPANEL.md)
3. Abra uma issue: https://github.com/krayin/laravel-crm/issues
