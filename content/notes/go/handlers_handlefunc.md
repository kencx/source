---
title: "Handler, Handle, HandleFunc and HandlerFunc"
date: 2022-07-01T09:55:25+08:00
lastmod:
draft: false
toc: false
tags:
- go
---

Go's `http` package has four different but similar sounding functions and types:
- `Handler`
- `Handle`
- `HandleFunc`
- `HandlerFunc`

## Handler
To start a web server in Go, we call the function

```go
func ListenAndServe(addr string, handler Handler) error
```

`ListenAndServe` creates a goroutine for every request and runs it against a
**Handler**, an interface that responds to a HTTP request.

```go
type Handler interface {
	ServeHTTP(ResponseWriter, *Request)
}
```

It must satisfy the `ServeHTTP` method and is responsible for executing
application logic and writing HTTP response headers and bodies.

## Handle
To map a specific route (url pattern) to a handler, we can use a `ServeMux` router
and its `Handle` method

```go
func (mux *ServeMux) Handle(pattern string, handler Handler)

func main() {
	mux := http.NewServeMux()

	mux.Handle("/foo", fooHandler)

	http.ListenAndServe(":5000", mux)
}
```

When the `/foo` endpoint is hit, `fooHandler` is executed.

## HandlerFunc
In order to construct a handler, `net/http` provides two convenience methods: 1.
`HandlerFunc` and 2. `HandleFunc`.

The `HandlerFunc` type is an adapter that converts ordinary functions (with the
appropriate signature) into HTTP handlers.

```go
type HandlerFunc func(ResponseWriter, *Request)

func (f HandlerFunc) ServeHTTP(rw ResponseWriter, r *Request) {
	f(w, r)
}
```

We see that `HandlerFunc` has an associated `ServeHTTP` method and hence
satisfies the `Handler` interface. Here's an example of how it is used

```go
func GetAuthor(w http.ResponseWriter, r *http.Request) {
	// logic...
}

func main() {
	mux := NewServeMux()

	handler := http.HandlerFunc(GetAuthor)
	mux.Handle("/foo", handler)

	http.ListenAndServe(":5000", mux)
}
```

## HandleFunc
Finally, the `HandleFunc` function actually uses `Handle` and `HandlerFunc` to
register a route to an ordinary function

```go
func (mux *ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
	mux.Handle(pattern, HandlerFunc(handler))
}
```

The function is passed into `HandlerFunc`, converting it into a `Handler` and is
mapped to the given pattern with `Handle`. Here is how it is used

```go
func main() {
	mux := NewServeMux()

	mux.HandleFunc("/foo", GetAuthor)

	http.ListenAndServe(":5000", mux)
}
```

>`Handle` and `HandleFunc` can also be used without initializing a new `ServeMux`
>object. These global functions are used in the same manner but are tied to the
>global `DefaultServeMux` instance.
>```go
>func main() {
>	http.HandleFunc("/foo", GetFoo)
>	http.ListenAndServe(":5000", nil)
>}
>```

## Summary
| Name          | Description                                                                      |
| :-----------: | :------------------------------------------------------------------------------- |
| `Handler`     | Interface with `ServeHTTP` method responsible for executing application logic    |
| `Handle`      | Maps a route to a `Handler` object                                               |
| `HandlerFunc` | Adapter type that converts ordinary functions into a `Handler`                   |
| `HandleFunc`  | Maps a route to a ordinary function (uses `Handle` and `HandlerFunc` internally) |

## References
- [Understanding Golang's Func types](https://www.integralist.co.uk/posts/understanding-golangs-func-type/)
- [Go docs - http package](https://pkg.go.dev/net/http)
