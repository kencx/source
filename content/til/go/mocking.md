---
title: "Flexible Mocking"
date: 2022-07-01T09:55:25+08:00
lastmod:
draft: false
toc: false
tags:
- go
- mocking
---

When creating mocks, we want the ability to modify the mocked object's methods
in order to test every branch of code. This can be done with mock functions:

```go
type mockStore struct {
	getBookFn func(id int) (*Book, error) // mock function
}

// Implementation of actual function to satisfy interface
func (m *mockStore) GetBook(id int) (*Book, error) {
	if m != nil && m.getBookFn != nil {
		return m.getBookFn(id)
	}
}
```

Mock functions can be customized in every test for maximum flexibility

```go
func TestXXX(t *testing.T) {
	mock := &mockStore{
		getBookFn: func GetBook(id int) (*Book, error) {
			return nil, errors.New("error")
		}
	}

	// use mock in test
}
```

## References
- [Flexible mocking for testing in Go](https://medium.com/safetycultureengineering/flexible-mocking-for-testing-in-go-f952869e34f5)
