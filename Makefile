# 터미널 쉘 확인
TERMINAL_SHELL := $(or $(MAKE_SHELL),$(shell echo $$SHELL))
SHELL := $(TERMINAL_SHELL)

# Go 프로젝트 설정
APP_NAME := conn
SOURCE := main.go
CONFIG_DIR := config
BUILD_DIR := build

# 기본 빌드 환경
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)

# 지원되는 운영 체제와 아키텍처
PLATFORMS := linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64
PLATFORM_FILES := $(foreach platform,$(PLATFORMS),$(BUILD_DIR)/$(APP_NAME)_$(subst /,_,$(platform)))

# 기본 목표
all: $(BUILD_DIR)/$(APP_NAME)

# 기본 빌드
$(BUILD_DIR)/$(APP_NAME): $(SOURCE)
	mkdir -p $(BUILD_DIR)
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $@ $(SOURCE)

# 크로스 컴파일
build-all: $(PLATFORM_FILES)

$(BUILD_DIR)/$(APP_NAME)_%: $(SOURCE)
	mkdir -p $(BUILD_DIR)
	$(eval PARTS := $(subst _, ,$*))
	$(eval GOOS := $(word 1,$(PARTS)))
	$(eval GOARCH := $(word 2,$(PARTS)))
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $@ $(SOURCE)

# 설치
install: $(BUILD_DIR)/$(APP_NAME)
	mkdir -p /usr/local/bin
	cp $(BUILD_DIR)/$(APP_NAME) /usr/local/bin/

# 설정 파일 복사
copy-config:
	mkdir -p $(HOME)/.config/$(APP_NAME)
	cp -r $(CONFIG_DIR)/config.sample.yaml $(HOME)/.config/$(APP_NAME)/config.yaml

# 자동완성 스크립트 생성 및 ~/.zshrc에 추가
completion:
	@if [ "$(TERMINAL_SHELL)" = "/bin/zsh" ]; then \
		echo "Zsh 환경에서 자동완성 스크립트를 생성 중입니다..."; \
		mkdir -p $(HOME)/.config/$(APP_NAME); \
		$(BUILD_DIR)/$(APP_NAME) completion zsh > $(HOME)/.config/$(APP_NAME)/completion.zsh; \
		if ! grep -q "source $(HOME)/.config/$(APP_NAME)/completion.zsh" $(HOME)/.zshrc; then \
			echo "\n# $(APP_NAME) 자동완성 추가" >> $(HOME)/.zshrc; \
			echo "source $(HOME)/.config/$(APP_NAME)/completion.zsh" >> $(HOME)/.zshrc; \
		fi; \
	elif [ "$(TERMINAL_SHELL)" = "/bin/bash" ]; then \
		echo "Bash 환경에서 자동완성 스크립트를 생성 중입니다..."; \
		mkdir -p $(HOME)/.config/$(APP_NAME); \
		$(BUILD_DIR)/$(APP_NAME) completion bash > $(HOME)/.config/$(APP_NAME)/completion.bash; \
		if ! grep -q "source $(HOME)/.config/$(APP_NAME)/completion.bash" $(HOME)/.bashrc; then \
			echo "\n# $(APP_NAME) 자동완성 추가" >> $(HOME)/.bashrc; \
			echo "source $(HOME)/.config/$(APP_NAME)/completion.bash" >> $(HOME)/.bashrc; \
		fi; \
	else \
		echo "지원되지 않는 쉘입니다: $(TERMINAL_SHELL)"; \
	fi

# 클린업
clean:
	rm -rf $(BUILD_DIR)

# 도움말
help:
	@echo "사용 가능한 명령어:"
	@echo "  all           - 기본 빌드"
	@echo "  build-all     - 모든 플랫폼에 대해 크로스 컴파일"
	@echo "  install       - 빌드된 바이너리를 /usr/local/bin에 설치"
	@echo "  copy-config   - 설정 파일을 ~/.config/$(APP_NAME)으로 복사"
	@echo "  completion    - 자동완성 스크립트를 생성하고 ~/.zshrc에 추가"
	@echo "  clean         - 빌드 파일 삭제"
	@echo "  help          - 도움말 출력"