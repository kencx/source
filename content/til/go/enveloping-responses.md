---
title: "Enveloping JSON Responses"
date: 2022-07-01T09:55:25+08:00
lastmod:
draft: false
toc: false
tags:
- go
---

An enveloped JSON response looks like this:

```json
{
	"book": {
		"id": 123,
		"title": "Foobar",
		"pages": 69
	}
}
```

To envelope all responses, create a custom `envelope` type

```go
type envelope map[string]interface{}
```

When marshalling objects to JSON, instead of passing the object directly, we
wrap it in the envelope map type

```go
func exampleHandler(w http.ResponseWriter, r *http.Request) {
	book := Book{ ... }

	// write response
	err := writeJSON(w, http.StatusOK, envelope{"book": book})
}
```

This works well when creating standardized JSON error responses:

```go
func (s *Server) errorResponse(w http.ResponseWriter, r *http.Request, status int, message interface{}) {
	env := envelope{"error": message}

	err := writeJSON(w, status, env)
	if err != nil {
		w.WriteHeader(500)
	}
}
```

which returns the following

```json
{
	"error": "error message here"
}
```

## References
- [Let's Go Further - Alex Edwards](https://lets-go-further.alexedwards.net/)
