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
	@echo "  clean         - 빌드 파일 삭제"
	@echo "  help          - 도움말 출력"