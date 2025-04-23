.PHONY: install-oneagent clean

# Variáveis
TENANT_ID ?= $(shell echo $$DYNATRACE_ENV | grep -o 'ogp[0-9]*')
DYNATRACE_URL ?= https://$(TENANT_ID).live.dynatrace.com
DYNATRACE_TOKEN ?= $(shell echo $$DYNATRACE_TOKEN)
EC2_IP ?= $(shell echo $$EC2_IP)
SSH_KEY ?= /tmp/ssh_key

# Verifica se as variáveis necessárias estão definidas
check-env:
	@echo "🔍 Verificando variáveis de ambiente..."
	@if [ -z "$(TENANT_ID)" ]; then echo "❌ Não foi possível extrair TENANT_ID do DYNATRACE_ENV"; exit 1; fi
	@if [ -z "$(DYNATRACE_TOKEN)" ]; then echo "❌ DYNATRACE_TOKEN não definido"; exit 1; fi
	@if [ -z "$(EC2_IP)" ]; then echo "❌ EC2_IP não definido"; exit 1; fi
	@if [ ! -f "$(SSH_KEY)" ]; then echo "❌ Chave SSH não encontrada em $(SSH_KEY)"; exit 1; fi
	@echo "✅ Todas as variáveis de ambiente estão definidas"
	@echo "📝 TENANT_ID: $(TENANT_ID)"
	@echo "📝 DYNATRACE_URL: $(DYNATRACE_URL)"
	@echo "📝 EC2_IP: $(EC2_IP)"

# Instala o OneAgent
install-oneagent: check-env
	@echo "🚀 Iniciando instalação do OneAgent em $(EC2_IP)..."
	@echo "📥 URL do instalador: $(DYNATRACE_URL)/api/v1/deployment/installer/agent/unix/default/latest?arch=x86"
	@ssh -i $(SSH_KEY) -o StrictHostKeyChecking=no ubuntu@$(EC2_IP) "\
		echo '📥 Baixando instalador do OneAgent...' && \
		wget -O Dynatrace-OneAgent-Linux-x86-latest.sh '$(DYNATRACE_URL)/api/v1/deployment/installer/agent/unix/default/latest?arch=x86' \
			--header='Authorization: Api-Token $(DYNATRACE_TOKEN)' && \
		echo '🔒 Tornando o instalador executável...' && \
		chmod +x Dynatrace-OneAgent-Linux-x86-latest.sh && \
		echo '📦 Instalando o OneAgent...' && \
		sudo ./Dynatrace-OneAgent-Linux-x86-latest.sh --set-app-log-content-access=true --set-infra-only=false --set-host-group=EC2 && \
		echo '✅ OneAgent instalado com sucesso!'"

# Limpa arquivos temporários
clean:
	@echo "🧹 Limpando arquivos temporários..."
	@ssh -i $(SSH_KEY) -o StrictHostKeyChecking=no ubuntu@$(EC2_IP) "rm -f Dynatrace-OneAgent-Linux-x86-latest.sh" || true 