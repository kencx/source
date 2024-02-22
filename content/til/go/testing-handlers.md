---
title: "Testing Handlers and Middlewares"
date: 2022-07-01T09:55:25+08:00
lastmod:
draft: false
toc: true
tags:
- go
- http
- testing
---

## Helper Struct

Create a helper struct to store request information

```go
type testCase struct {
	url     string
	method  string
	headers map[string]string
	data    []byte
	params  map[string]string
	fn      func(http.ResponseWriter, *http.Request)
}
```

## Testing Handlers

To test any response, we use the `testResponse` helper. It creates a new request
with the given `testCase` and returns a `httptest.ResponseRecorder` which can be
probed for response validation.

```go
func testResponse(t *testing.T, tc *testCase) (*httptest.ResponseRecorder, error) {
	t.Helper()

	req, err := http.NewRequest(tc.method, tc.url, bytes.NewReader(tc.data))
	if err != nil {
		return nil, err
	}

	rw := httptest.NewRecorder()
	if tc.params != nil {
		req = mux.SetURLVars(req, tc.params)
	}

	http.HandlerFunc(tc.fn).ServeHTTP(rw, req)
	return rw, nil
}
```

An example of getting an `Author` object:

```go
type Author struct {
	Name string
}

func TestGetAuthor(t *testing.T) {
	tc := &testCase{
		method: http.MethodGet,
		url:    "/path/example",
		params: map[string]string{"id": "1"},
		fn:     GetAuthor,
	}

	w, err := testResponse(t, tc)
	if err != nil {
		t.Fatalf("unexpected err: %v", err)
	}

	// unmarshal response body to Author object
	var got Author
	err = json.NewDecoder(w.Body).Decode(&got)
	if err != nil {
		t.Fatalf("unexpected err: %v", err)
	}

	// response validation
	assertEqual(t, got.Name, want.Name)
	assertEqual(t, w.Code, http.StatusOK)
	assertEqual(t, w.HeaderMap.Get("Content-Type"), "application/json")
}
```

## Testing Middlewares
Middlewares use a similar approach to testing with a more generalized helper.
`middlewareTestResponse` helper accepts an additional function with a middleware
type signature.

```go
func middlewareTestResponse(t *testing.T, tc *testCase, fn func(next http.Handler) http.Handler) (*httptest.ResponseRecorder, error) {
	t.Helper()

	req, err := http.NewRequest(tc.method, tc.url, bytes.NewReader(tc.data))
	if err != nil {
		return nil, err
	}
	if tc.headers != nil {
		for k, v := range tc.headers {
			req.Header.Add(k, v)
		}
	}

	rw := httptest.NewRecorder()
	if tc.params != nil {
		req = mux.SetURLVars(req, tc.params)
	}

	fn(http.HandlerFunc(tc.fn)).ServeHTTP(rw, req)
	return rw, nil
}
```

An example of ensuring secure headers are added via middleware `secureHeaders`:

```go
func TestSecureHeaders(t *testing.T) {
	next := func(rw http.ResponseWriter, r *http.Request) {
		want := map[string]string{
			"X-Frame-Options":  "deny",
			"X-XSS-Protection": "1; mode=block",
			"Set-Cookie":       "Secure; HttpOnly",
		}

		got := make(map[string]string)
		for k := range want {
			got[k] = rw.Header().Get(k)
		}
		assertObjectEqual(t, got, want)
	}

	tc := &testCase{
		url:    "/api/",
		method: http.MethodGet,
		fn:     next,
	}
	_, err := middlewareTestResponse(t, tc, testServer.secureHeaders)
	checkErr(t, err)
}
```

Here, we validate the headers in the `next` handler instead of using the
`httptest.ResponseRecorder` object.
