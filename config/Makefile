.PHONY: install-oneagent install-docker clean check-oneagent check-docker

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

# Verifica se o OneAgent já está instalado
check-oneagent:
	@echo "🔍 Verificando se o OneAgent já está instalado..."
	@ssh -i $(SSH_KEY) -o StrictHostKeyChecking=no ubuntu@$(EC2_IP) "\
		if sudo systemctl is-active --quiet oneagent; then \
			echo '✅ OneAgent já está instalado e rodando'; \
			exit 0; \
		else \
			echo '📦 OneAgent não encontrado, prosseguindo com instalação'; \
			exit 1; \
		fi" || make install-oneagent-core

# Verifica se o Docker já está instalado
check-docker:
	@echo "🔍 Verificando se o Docker já está instalado..."
	@ssh -i $(SSH_KEY) -o StrictHostKeyChecking=no ubuntu@$(EC2_IP) "\
		if command -v docker &> /dev/null && sudo systemctl is-active --quiet docker; then \
			echo '✅ Docker já está instalado e rodando'; \
			exit 0; \
		else \
			echo '📦 Docker não encontrado ou não está rodando, prosseguindo com instalação'; \
			exit 1; \
		fi" || make install-docker-core

# Instala o OneAgent (core)
install-oneagent-core:
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

# Instala o Docker (core)
install-docker-core:
	@echo "🐳 Iniciando instalação do Docker em $(EC2_IP)..."
	@ssh -i $(SSH_KEY) -o StrictHostKeyChecking=no ubuntu@$(EC2_IP) "\
		echo '🧹 Removendo versões antigas do Docker...' && \
		for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y \$$pkg || true; done && \
		\
		echo '📦 Instalando dependências...' && \
		sudo apt-get update || true && \
		sudo apt-get install -y ca-certificates curl && \
		\
		echo '🔑 Configurando repositório do Docker...' && \
		sudo install -m 0755 -d /etc/apt/keyrings && \
		sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
		sudo chmod a+r /etc/apt/keyrings/docker.asc && \
		\
		echo '📝 Adicionando repositório do Docker...' && \
		echo \"deb [arch=\$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
		\$$( . /etc/os-release && echo \"\$${UBUNTU_CODENAME:-\$$VERSION_CODENAME}\") stable\" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
		\
		echo '📦 Instalando Docker...' && \
		sudo apt-get update || true && \
		sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
		\
		echo '👤 Configurando permissões...' && \
		sudo usermod -aG docker ubuntu && \
		\
		echo '🔄 Habilitando serviços...' && \
		sudo systemctl enable docker.service && \
		sudo systemctl enable containerd.service && \
		sudo systemctl start docker.service && \
		sudo systemctl start containerd.service && \
		\
		echo '✅ Docker instalado com sucesso!'"

# Instala o OneAgent (entrada principal)
install-oneagent: check-env check-oneagent

# Instala o Docker (entrada principal)
install-docker: check-env check-docker

# Limpa arquivos temporários
clean:
	@echo "🧹 Limpando arquivos temporários..."
	@ssh -i $(SSH_KEY) -o StrictHostKeyChecking=no ubuntu@$(EC2_IP) "rm -f Dynatrace-OneAgent-Linux-x86-latest.sh" || true

# Instala tudo
install-all: install-oneagent install-docker
	@echo "✨ Todas as instalações concluídas com sucesso!" 