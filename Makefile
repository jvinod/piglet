#BUILD_TYPE=debug
ifeq ($(BUILD_TYPE),debug)
BUILD_OPTIONS += -i -v -gcflags "-N -l"
else
BUILD_OPTIONS += -i -v
endif

ifndef TAGS
TAGS := daemon
endif

.PHONY: clean piglet

ifndef PKGS
PKGS = $(shell GOPATH=$(GOPATH) go list ./... 2>&1 | grep -v 'piglet/vendor')
endif

ifndef SUDOENV
SUDOENV := GO15VENDOREXPERIMENT=1 GOPATH=$(GOPATH) PATH=/sbin:/usr/local/go/bin:$(PATH)
endif

TARGETS += piglet vet lint

$(info  $(TARGETS))

BIN := $(BASE_DIR)/bin

.DEFAULT_GOAL=all

all: $(TARGETS) tags

deps:
	GO15VENDOREXPERIMENT=0 go get -d -v $(PKGS)

update-deps:
	GO15VENDOREXPERIMENT=0 go get -d -v -u -f $(PKGS)

test-deps:
	GO15VENDOREXPERIMENT=0 go get -d -v -t $(PKGS)

update-test-deps:
	GO15VENDOREXPERIMENT=0 go get -tags "$(TAGS)" -d -v -t -u -f $(PKGS)

vendor-update:
	GO15VENDOREXPERIMENT=0 GOOS=linux GOARCH=amd64 go get -tags \
	"daemon" -d -v -t -u -f \
	$(shell go list ./... 2>&1 | grep -v 'piglet/vendor')

vendor-without-update:
	go get -v github.com/kardianos/govendor
	rm -rf vendor
	govendor init
	GOOS=linux GOARCH=amd64 govendor add +external
	GOOS=linux GOARCH=amd64 govendor update +vendor
	GOOS=linux GOARCH=amd64 govendor add +external
	GOOS=linux GOARCH=amd64 govendor update +vendor

vendor: vendor-update vendor-without-update

lint:
	go get -v github.com/golang/lint/golint
	for file in $$(find . -name '*.go' | grep -v vendor | grep -v '\.pb\.go' | grep -v '\.pb\.gw\.go'); do \
		golint $${file}; \
		if [ -n "$$(golint $${file})" ]; then \
			exit 1; \
		fi; \
	done

vet:
	go vet $(PKGS)

errcheck:
	go get -v github.com/kisielk/errcheck
	errcheck -tags "$(TAGS)" $(PKGS)

pretest: lint vet errcheck

tags:
	@ctags -R

clean:
	@echo "Cleaning..."
	go clean -i $(PKGS)

test: $(TARGETS)
	sudo env $(SUDOENV) go test -v -tags "$(TAGS)" $(TESTFLAGS) $(PKGS)

