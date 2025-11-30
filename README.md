# Krayin CRM - EasyPanel Edition

<p align="center">
  <img src="https://raw.githubusercontent.com/krayin/temp-media/master/dashboard.png" alt="Krayin CRM Dashboard">
</p>

<p align="center">
  <a href="https://github.com/maestroicaro/krayin-crm-easypanel/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
  <a href="https://github.com/maestroicaro/krayin-crm-easypanel"><img src="https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker" alt="Docker"></a>
  <a href="https://github.com/maestroicaro/krayin-crm-easypanel"><img src="https://img.shields.io/badge/EasyPanel-Optimized-00C7B7" alt="EasyPanel"></a>
</p>

## 📋 Sobre

Esta é uma versão **containerizada e otimizada** do [Krayin CRM](https://krayincrm.com) para deployment facilitado no **EasyPanel**. 

Krayin é um CRM Laravel open-source completo para gerenciamento do ciclo de vida do cliente, incluindo:

- ✅ Gestão de Leads e Pipelines
- ✅ Gestão de Contatos e Organizações
- ✅ Produtos e Cotações
- ✅ Atividades e Tarefas
- ✅ Email Integration (IMAP)
- ✅ Automação de Marketing
- ✅ Relatórios e Dashboards
- ✅ API RESTful

## 🚀 Instalação Rápida

### Opção 1: EasyPanel (Recomendado)

1. Acesse seu painel EasyPanel
2. Clique em **"New Service" → "From Template"**
3. Cole o conteúdo de [`easypanel-template.json`](easypanel-template.json)
4. Clique em **"Deploy"**
5. Aguarde 2-3 minutos ⏳
6. Acesse sua URL e faça login!

**Credenciais padrão**:
- Email: `admin@example.com`
- Senha: `admin123`

> ⚠️ **IMPORTANTE**: Altere a senha após o primeiro login!

---

### Opção 2: Docker Compose Local

```bash
# Clone o repositório
git clone https://github.com/maestroicaro/krayin-crm-easypanel.git
cd krayin-crm-easypanel

# Execute o script de instalação
bash easypanel/install.sh

# Ou manualmente
docker-compose up -d

# Acesse
http://localhost:8080
```

---

## 📦 O que está incluído?

### Infraestrutura Docker

- ✅ **Dockerfile multi-stage** otimizado
  - PHP 8.2-FPM com todas extensões necessárias
  - Nginx integrado
  - Supervisor para gerenciamento de processos
  - OPcache habilitado
  - Tamanho final: ~400MB

- ✅ **docker-compose.yml** completo
  - MySQL 8.0
  - Redis 7
  - Volumes persistentes
  - Health checks

- ✅ **Entrypoint automatizado**
  - Aguarda MySQL estar disponível
  - Executa migrations automaticamente
  - Cria admin padrão
  - Otimiza caches

### Scripts de Automação

| Script | Descrição |
|--------|-----------|
| [`install.sh`](easypanel/install.sh) | Instalação automatizada com senhas seguras |
| [`update.sh`](easypanel/update.sh) | Atualização com backup automático |
| [`backup.sh`](easypanel/backup.sh) | Backup completo (DB + arquivos) |
| [`reset-admin.sh`](easypanel/reset-admin.sh) | Reset de senha do admin |

### Documentação

- 📖 [**README-EASYPANEL.md**](README-EASYPANEL.md) - Guia completo em português
- 📖 [**easypanel/README.md**](easypanel/README.md) - Documentação dos scripts

---

## 🛠️ Requisitos

- **Docker** 20.10+
- **Docker Compose** 2.0+
- **2GB RAM** mínimo (4GB recomendado)
- **10GB** espaço em disco

---

## 📊 Arquitetura

```
┌─────────────────────────────────────────┐
│         Krayin CRM Container            │
│  ┌──────────┐  ┌──────────┐            │
│  │  Nginx   │  │ PHP-FPM  │            │
│  │  :80     │→ │  :9000   │            │
│  └──────────┘  └──────────┘            │
│         Supervisor                      │
└─────────────────────────────────────────┘
              ↓           ↓
    ┌─────────────┐  ┌─────────┐
    │  MySQL 8.0  │  │ Redis 7 │
    │   :3306     │  │  :6379  │
    └─────────────┘  └─────────┘
```

---

## 🔧 Configuração

### Variáveis de Ambiente Principais

```env
APP_NAME='Krayin CRM'
APP_ENV=production
APP_DEBUG=false
APP_URL=https://seu-dominio.com

DB_HOST=mysql
DB_DATABASE=krayin
DB_USERNAME=krayin
DB_PASSWORD=sua_senha_segura

REDIS_HOST=redis
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

Veja [`.env.example`](.env.example) para todas as opções.

---

## 🎯 Recursos Implementados

### Performance
- ✅ OPcache habilitado e otimizado
- ✅ Redis para cache, sessões e filas
- ✅ Cache de rotas, views e config
- ✅ Compressão Gzip
- ✅ Cache de arquivos estáticos

### Segurança
- ✅ Execução como usuário não-root
- ✅ Headers de segurança
- ✅ Debug desabilitado em produção
- ✅ Senhas geradas automaticamente

### Confiabilidade
- ✅ Health checks
- ✅ Restart automático
- ✅ Backup automatizado
- ✅ Logs centralizados

---

## 📝 Comandos Úteis

```bash
# Ver status dos containers
docker-compose ps

# Ver logs em tempo real
docker-compose logs -f

# Acessar shell do container
docker-compose exec app bash

# Executar comandos Artisan
docker-compose exec app php artisan [comando]

# Fazer backup
bash easypanel/backup.sh

# Atualizar aplicação
bash easypanel/update.sh

# Resetar senha do admin
bash easypanel/reset-admin.sh
```

---

## 🐛 Troubleshooting

### Containers não iniciam
```bash
docker-compose logs -f
docker-compose down
docker-compose up -d
```

### Erro de conexão com banco
```bash
# Verificar se MySQL está rodando
docker-compose ps mysql

# Ver logs do MySQL
docker-compose logs mysql
```

### Limpar caches
```bash
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan view:clear
```

Veja mais em [README-EASYPANEL.md](README-EASYPANEL.md#troubleshooting)

---

## 📚 Documentação

- [Guia Completo de Instalação](README-EASYPANEL.md)
- [Documentação dos Scripts](easypanel/README.md)
- [Documentação Oficial Krayin](https://devdocs.krayincrm.com)
- [Fórum Krayin](https://forums.krayincrm.com)

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fork o projeto
2. Criar uma branch (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Add: MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abrir um Pull Request

---

## 📄 Licença

Este projeto é open-source sob a [Licença MIT](LICENSE).

Baseado no [Krayin CRM](https://github.com/krayin/laravel-crm) original.

---

## 🙏 Créditos

- **Krayin CRM** - [https://krayincrm.com](https://krayincrm.com)
- **Webkul** - Desenvolvedores originais do Krayin
- **Containerização e EasyPanel** - Esta implementação

---

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/maestroicaro/krayin-crm-easypanel/issues)
- **Documentação**: [README-EASYPANEL.md](README-EASYPANEL.md)
- **Krayin Forum**: [forums.krayincrm.com](https://forums.krayincrm.com)

---

<p align="center">
  Feito com ❤️ para facilitar o deployment do Krayin CRM
</p>
