---
title: "Argument Types"
date: 2023-07-07
lastmod: 2023-07-07
draft: false
toc: true
tags:
- python
---

There are seven types of arguments that can be defined in Python functions:

- Positional
- Keyword
- Default
- Keyword-only
- Positional-only
- Variable positional `*args`
- Variable keyword `**kwargs`

## Positional Arguments

Functions are most commonly defined with positional arguments. These can be
called with or without their keyword (or name) `kwarg`. If no keywords are
given, the argument order will default to the order in the function definition.

```python
def add(x, y):
	return x+y

add(1,2)
add(x=1,y=2)
add(y=1,x=2)
add(1, y=2)
```

## Keyword Arguments

Functions can also be called with keyword arguments by explicitly specifying
`kwarg=value`. These must follow specific rules:

- Keyword arguments can be called in any order
- The function cannot contain any undefined keyword arguments
- The function can be called with a mix of positional and keyword arguments, but
  any keyword arguments MUST follow all positional arguments

```python
def add(x, y):
	return x+y

add(x=1, y=2)
add(y=2, x=1)

# invalid examples
add(z=1,a=2)  # unexpected keyword args!
add(x=1, 2)
```

## Default Arguments

A function's arguments can be assigned default values when it's defined. If no
argument is given when the function is called, the default value will be
adopted. Similarly, all rules for positional and keyword arguments apply.

```python
def add(x, y=2):
	return x+y

add(1, 4)      # 5
add(x=1)       # 3
add(x=1, y=1)  # 2
add(1)         # 3

# invalid examples
add(x=1, 5)
```

## Keyword-Only Arguments

Function arguments can be defined to be keyword-only by placing it after an `*`.
In this case, all arguments defined after must be keyword-only when calling the
function.

```python
def foo(*, x):
	print(x)

foo(x=1)

# invalid
foo(1)  # Missing one required keyword-only argument
```

This can be further extended to include default arguments

```python
def add(*, x, y=2):
	return x+y

add(x=1, y=1)  # 2
add(x=1)       # 3

# invalid
add(1, y=1)
add(1)
add(1, 2)
```

## Positional-Only Arguments

There are also positional-only arguments, which are defined by placing them
before `/`. These arguments must be positional-only when calling the function.

```python
def foo(x, /):
	print(a)

foo(1)

# invalid
foo(x=1)
```

{{< alert type="note" >}}
Positional-only arguments are available in Python 3.8.
{{< /alert >}}

## Variable Positional Arguments

Variable positional arguments are represented in the form `*args` as a tuple
with an arbitrary number of arguments. Functions defined with `*args` can be
called with an arbitrary number of positional arguments. If no arguments are
given, `*args` defaults to an empty tuple.

The use of `*args` also forbids the use of any keyword arguments when calling the function.

```python
def add(*numbers):
	return sum(int(n) for n in numbers)

add(1,2,3)  # 6

# invalid
add(1,2,x=3)
```

However, `*args` can be combined with keyword arguments in the function definition:

```python
def foo(*x, y):
	print(f"x is: {x}")
	print(f"y is: {y}")

foo(1,2,y=3)
# x is (1, 2)
# y is 3

# invalid
foo(1,2,3)  # missing keyword argument
```

The above example can also include default arguments for `y`.

## Variable Keyword Arguments

Variable keyword arguments of the form `**kwargs` are represented as a
dictionary with an arbitrary length. Functions defined with `**kwargs` can be
called with an arbitrary number of keyword arguments. If no arguments are given,
`**kwargs` defaults to an empty dictionary.

{{< alert type="note" >}}
The `*` and `**` operators used in function definitions are different from those
used in [function calls]({{< ref "notes/python/asterisks.md#function-calls" >}}) or outside of functions
([Asterisks#Destructuring]({{< ref "notes/python/asterisks.md#destructuring" >}})).
{{< /alert >}}

```python
def foo(**x):
	print(f"x is: {x}")

foo(x=1,y=2,z=3)
# x is {'x': 1, 'y': 2, 'z': 3}
```

Because `**kwargs` allows any keyword arguments to be passed into the function,
we must handle them appropriately with `get()` or `pop()`. These methods also
allow us to set a default value for the key if it is absent:

```python
def change_user_details(username, **kwargs):
	# raise KeyError if arg doesn't exist
	foo = kwargs.pop("foo", None)

	# check for unexpected keyword args and raise TypeError
	if kwargs:
		raise TypeError(f'unexpected keyword {", ".join(sorted(kwargs))}')
```

`*args` and `**kwargs` can be combined to provide variable argument support in functions:

```python
def foo(*args, **kwargs):
	pass
```

## References

- [All you need to know about asterisks in Python](https://bas.codes/posts/python-asterisks)
