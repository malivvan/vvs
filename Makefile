.PHONY: build
default: build

define build
    $(eval $@_CGO = $(1))
    $(eval $@_TAGS = $(shell echo $(2)| sed 's/\s\+/,/g'))
    $(eval $@_OS = $(4))
    $(eval $@_ARCH = $(5))
    $(eval $@_OUT = $(3)_$(4)_$(5)$(6))
    $(eval $@_SRC = $(7))
	echo -n "CGO=$($@_CGO)\tOS=$($@_OS)\tARCH=$($@_ARCH)\tTAGS=$($@_TAGS)\tSRC=$($@_SRC)"
	CGO_ENABLED=$($@_CGO) GOOS=$($@_OS) GOARCH=$($@_ARCH) GOFLAGS="-tags=$(TAGS)" ./tools/cyclonedx-gomod app -json -licenses -packages -std -output ./build/$($@_OUT).json -main $($@_SRC) .
	CGO_ENABLED=$($@_CGO) GOOS=$($@_OS) GOARCH=$($@_ARCH) go build -trimpath -ldflags="-s -w -buildid=" -tags="$($@_TAGS)" -o ./build/$($@_OUT) $($@_SRC) || (echo " FAIL"; exit 1)
	echo "\tSIZE=$$(ls -lh ./build/$($@_OUT) | awk '{print $$5}')\tFILE=$$(file ./build/$($@_OUT) | cut -d: -f2 | cut -c2-)"
endef

tools:
	@mkdir -p tools
	GOBIN=$(shell pwd)/tools go install aead.dev/minisign/cmd/minisign@v0.3.0
	GOBIN=$(shell pwd)/tools go install github.com/Zxilly/go-size-analyzer/cmd/gsa@v1.6.2
	GOBIN=$(shell pwd)/tools go install github.com/CycloneDX/cyclonedx-gomod/cmd/cyclonedx-gomod@v1.7.0

clean:
	@mkdir -p ./build
	@rm -f ./build/*

build: tools clean
	@$(call build,"0","netgo osusergo","vvs","linux","amd64","","./cmd")
	@$(call build,"0","netgo osusergo","vvs","linux","386","","./cmd")
	@$(call build,"0","netgo osusergo","vvs","linux","arm64","","./cmd")
	@$(call build,"0","netgo osusergo","vvs","linux","arm","","./cmd")
	@$(call build,"0","netgo osusergo","vvs","windows","amd64",".exe","./cmd")
	@$(call build,"0","netgo osusergo","vvs","windows","386",".exe","./cmd")
	@$(call build,"0","netgo osusergo","vvs","windows","arm64",".exe","./cmd")
	@$(call build,"0","netgo osusergo","vvs","darwin","amd64","","./cmd")
	@$(call build,"0","netgo osusergo","vvs","darwin","arm64","","./cmd")

