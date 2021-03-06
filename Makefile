GOPATH ?= /go
GOOS ?= linux
GOARCH ?= amd64
V3CTL_TAG ?= latest
V3CTL_PATH ?= $(GOPATH)/src/github.com/v3io/v3ctl
V3CTL_BUILD_COMMAND ?= CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags="-s -w" -o $(GOPATH)/bin/v3ctl-$(V3CTL_TAG)-$(GOOS)-$(GOARCH) $(V3CTL_PATH)/cmd/v3ctl/main.go

# force go modules
export GO111MODULE := on

.PHONY: lint
lint:
	docker run --rm \
		--volume ${shell pwd}:/go/src/github.com/v3io/v3ctl \
		--env GOPATH=/go \
		--env GO111MODULE=off \
		golang:1.12 \
		bash /go/src/github.com/v3io/v3ctl/hack/lint.sh

	@echo Done.

.PHONY: get-dependencies
get-dependencies:
	go get ./...

.PHONY: v3ctl-bin
v3ctl-bin:
	$(V3CTL_BUILD_COMMAND)

.PHONY: v3ctl
v3ctl:
	docker run \
		--volume $(shell pwd):$(V3CTL_PATH) \
		--volume $(shell pwd):/go/bin \
		--workdir $(GOPATH) \
		--env GOOS=$(GOOS) \
		--env GOARCH=$(GOARCH) \
		golang:1.12 \
		make v3ctl-bin
