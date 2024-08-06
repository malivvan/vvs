package vvs

import (
	"github.com/dop251/goja"
	"github.com/dop251/goja_nodejs/buffer"
	"github.com/dop251/goja_nodejs/console"
	"github.com/dop251/goja_nodejs/process"
	"github.com/dop251/goja_nodejs/url"
	"sync"
)

type WebAssembly struct {
	mutex sync.Mutex
}

func (w *WebAssembly) Instantiate(buf *buffer.Buffer, importObject map[string]interface{}) (interface{}, error) {
	return nil, nil
}

func (w *WebAssembly) Compile(buf *buffer.Buffer) (interface{}, error) {
	return nil, nil
}

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
