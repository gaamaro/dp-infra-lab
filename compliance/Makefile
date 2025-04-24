# Variáveis
TTENANT_ID ?= $(shell echo $$DYNATRACE_ENV | grep -o 'ogp[0-9]*')
DYNATRACE_URL ?= https://$(TENANT_ID).live.dynatrace.com
DYNATRACE_TOKEN ?= $(shell echo $$DYNATRACE_TOKEN)
GITHUB_RUN_ID ?= $(shell echo $$GITHUB_RUN_ID)
GITHUB_ACTOR ?= $(shell echo $$GITHUB_ACTOR)
GITHUB_SERVER_URL ?= $(shell echo $$GITHUB_SERVER_URL)
GITHUB_REPOSITORY ?= $(shell echo $$GITHUB_REPOSITORY)
PIPELINE_URL ?= $(GITHUB_SERVER_URL)/$(GITHUB_REPOSITORY)/actions/runs/$(GITHUB_RUN_ID)
TIMESTAMP ?= $(shell date -u +"%Y-%m-%dT%H:%M:%S.000Z")
HOST_ID ?= $(shell echo $$DT_HOST_ID)

.PHONY: check-env send-deployment-event

# Verifica variáveis de ambiente
check-env:
	@echo "🔍 Verificando variáveis de ambiente..."
	@if [ -z "$(TENANT_ID)" ]; then echo "❌ Não foi possível extrair TENANT_ID do DYNATRACE_ENV"; exit 1; fi
	@if [ -z "$(DYNATRACE_EVENTS_TOKEN)" ]; then echo "❌ DYNATRACE_EVENTS_TOKEN não definido"; exit 1; fi
	@if [ -z "$(GITHUB_RUN_ID)" ]; then echo "❌ GITHUB_RUN_ID não definido"; exit 1; fi
	@if [ -z "$(GITHUB_ACTOR)" ]; then echo "❌ GITHUB_ACTOR não definido"; exit 1; fi
	@if [ -z "$(HOST_ID)" ]; then echo "❌ HOST_ID não definido"; exit 1; fi
	@echo "✅ Todas as variáveis de ambiente estão definidas"

# Envia evento de deployment para o Dynatrace
send-deployment-event:
	@echo "📤 Enviando evento de deployment para o Dynatrace..."
	@curl -X POST "$(DYNATRACE_URL)/api/v2/events/ingest" \
		-H "Authorization: Api-Token $(DYNATRACE_EVENTS_TOKEN)" \
		-H "Content-Type: application/json" \
		-d '{ \
			"eventType": "CUSTOM_DEPLOYMENT", \
			"title": "Deployment EC2 Infrastructure", \
			"timeout": 15, \
			"entitySelector": "type(HOST),entityId(HOST-$(HOST_ID))", \
			"properties": { \
				"Pipeline URL": "$(PIPELINE_URL)", \
				"Deployment ID": "$(GITHUB_RUN_ID)", \
				"Responsável": "$(GITHUB_ACTOR)", \
				"Timestamp": "$(TIMESTAMP)" \
			} \
		}'

# Target principal
notify-governance: check-env send-deployment-event
	@echo "✅ Evento de governança enviado com sucesso!" 