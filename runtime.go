package vvs

import (
	"github.com/dop251/goja"
	"github.com/dop251/goja_nodejs/buffer"
	"github.com/dop251/goja_nodejs/console"
	"github.com/dop251/goja_nodejs/process"
	"github.com/dop251/goja_nodejs/require"
	"github.com/dop251/goja_nodejs/url"
)

var registry = new(require.Registry)

func Runtime() *goja.Runtime {
	runtime := goja.New()
	if err := runtime.Set("WebAssembly", &WebAssembly{}); err != nil {
		panic(err)
	}
	registry.Enable(runtime)
	console.Enable(runtime)
	buffer.Enable(runtime)
	process.Enable(runtime)
	url.Enable(runtime)
	return runtime
}
