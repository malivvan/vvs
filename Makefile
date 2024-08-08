.PHONY: build
default: build

define go_build
    $(eval $@_CGO = $(4))
    $(eval $@_TAGS = $(shell echo $(5) | sed 's/\s\+/,/g'))
    $(eval $@_OS = $(2))
    $(eval $@_ARCH = $(3))
    $(if $(findstring windows,$($@_OS)), $(eval $@_OUT = $(1)_$(2)_$(3).exe), $(eval $@_OUT = $(1)_$(2)_$(3)))
    $(eval $@_SRC = $(6))
    $(eval $@_ID = $(shell git rev-parse HEAD))
	echo -n "BUILDING  SRC=$($@_SRC)\tCGO=$($@_CGO)\tOS=$($@_OS)\tARCH=$($@_ARCH)\tTAGS=$($@_TAGS)"
	CGO_ENABLED=$($@_CGO) GOOS=$($@_OS) GOARCH=$($@_ARCH) GOARM=7 GOFLAGS="-tags=$($@_TAGS)" ./tools/cyclonedx-gomod app -json -packages -std -output ./build/$($@_OUT).json -main $($@_SRC) . || (echo " FAIL"; exit 1)
	CGO_ENABLED=$($@_CGO) GOOS=$($@_OS) GOARCH=$($@_ARCH) GOARM=7 go build -trimpath -ldflags="-s -w -buildid=$($@_ID)" -tags="$($@_TAGS)" -o ./build/$($@_OUT) $($@_SRC) || (echo " FAIL"; exit 1)
	echo -n "\tSIZE=$$(ls -lh ./build/$($@_OUT) | awk '{print $$5}')\tBUILDID="
	go tool buildid ./build/$($@_OUT)
endef

define minisign_gen
	$(eval $@_SEC = $(shell head /dev/urandom | tr -dc A-Za-z0-9 | head -c64))
	echo "export SIGNING_SEC=$($@_SEC)"
	echo $($@_SEC) | ./tools/minisign -G -Q -q -p $(1).pub -s $(1).key -f >/dev/null 2>&1
	echo -n "export SIGNING_KEY="
	tail -1 $(1).key
	echo
	echo -n "export SIGNING_PUB="
    tail -1 $(1).pub
    echo
	rm $(1).key
endef

define minisign_sign
	echo "untrusted comment: minisign encrypted secret key" > $(1).key
	echo $(shell echo $$SIGNING_KEY) >> $(1).key
	echo $(shell echo $$SIGNING_SEC) | ./tools/minisign -f -R -Q -q -p $(1).pub -s $(1).key >/dev/null 2>&1
	$(eval $@_PUB = $(shell tail -1 $(1).pub && rm -f $(1).pub))
	$(shell export SIGNING_PUB=$($@_PUB))
	echo -n "MINISIGN  "
    echo $(shell echo $$SIGNING_PUB)
	$(eval $@_MSIGS = $(shell find ./build/* | grep .minisig | sed -z 's/\n/ /g'))
	rm -f $($@_MSIGS) ./build/$(1)_checksums.txt
	$(eval $@_FILES = $(shell find ./build/* | grep -v .minisig | grep -v .txt | sed -z 's/\n/ -m /g'))
	cd build && sha256sum * > $(1)_checksums.txt
	echo $(shell echo $$SIGNING_SEC) | ./tools/minisign -Q -q -S -s $(1).key -m $($@_FILES) ./build/$(1)_checksums.txt >/dev/null 2>&1
	rm -f $(1).key
endef

define minisign_verify
	$(eval $@_PUB = $(shell echo $$SIGNING_PUB))
	for file in $(shell find ./build -type f -name "*.minisig" | sed -e "s/^././" -e "s/.minisig//"); do \
		echo -n "CHECKING  "; \
		./tools/minisign -Q -V -P $($@_PUB) -m $$file || (echo "Verification failed"; exit 1); \
	done
	cd build && sha256sum --quiet -c $(1)_checksums.txt || (echo "Verification failed"; exit 1)
	echo "VERIFIED  $($@_PUB)"
endef

tools:
	@mkdir -p tools
	GOBIN=$(shell pwd)/tools go install aead.dev/minisign/cmd/minisign@v0.3.0
	GOBIN=$(shell pwd)/tools go install github.com/CycloneDX/cyclonedx-gomod/cmd/cyclonedx-gomod@v1.7.0
	GOBIN=$(shell pwd)/tools go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
clean:
	@echo "CLEANING  ./build"
	@mkdir -p ./build
	@rm -f ./build/*

keygen: tools
	@$(call minisign_gen,"vvs")

check_key:
ifeq ($(shell echo $$SIGNING_KEY),)
	@echo "ERROR: SIGNING_KEY not set!"
	@echo "run 'make keygen' to generate a new keypair"
	@exit 1
endif

check_sec:
ifeq ($(shell echo $$SIGNING_SEC),)
	@echo "ERROR: SIGNING_SEC not set!"
	@echo "run 'make keygen' to generate a new keypair"
	@exit 1
endif

check_pub:
ifeq ($(shell echo $$SIGNING_PUB),)
	@echo "ERROR: SIGNING_PUB not set!"
	@echo "run 'make keygen' to generate a new keypair"
	@exit 1
endif

build: tools clean
	@$(call go_build,"vvs","linux","amd64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","linux","386","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","linux","arm64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","linux","arm","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","linux","riscv64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","windows","amd64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","windows","386","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","windows","arm64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","windows","arm","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","darwin","amd64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","darwin","arm64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","freebsd","amd64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","freebsd","386","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","freebsd","arm64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","freebsd","arm","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","freebsd","riscv64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","openbsd","amd64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","openbsd","386","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","openbsd","arm64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","openbsd","arm","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","netbsd","amd64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","netbsd","386","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","netbsd","arm64","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","netbsd","arm","0","netgo osusergo","./cmd")
	@$(call go_build,"vvs","dragonfly","amd64","0","netgo osusergo","./cmd")

sign: tools check_key check_sec
	@$(call minisign_sign,"vvs")

verify: tools check_pub
	@$(call minisign_verify,"vvs")
