---
title: "Truthy and Falsy"
date: 2023-07-12
lastmod: 2023-07-12
draft: false
toc: false
tags:
- python
---

In Python, any object can be tested for truth value in an `if` or `while`
condition, or as an operand of the boolean operations:

```python
x or y
x and y
not x
```

Every value in Python, regardless of type, is considered `True` or truthy,
unless its class defines a:

- `__bool__()` method that returns `False`
- `__len__()` method that returns `0`

Examples of falsy values include:

- Constants defined to be false: `None` and `False`
- Zero of any numeric type
- Empty sequences and collections: `'', (), [], {}, set(), range(0)`

Therefore, the following `if` blocks will be functionally equivalent:

```python
if len(lst) == 0:
	pass

if None:
	pass

if False:
	pass
```

## Gotcha - None is not False

However, this does not mean `None` is always interpreted as `False`. `None`
represents the concept of *nothing* and is not directly equivalent to `False`:
`None != False`. This is important to note when dealing with [identity and
equivalence]({{< relref "til/python/identity-and-equivalence" >}}):

```python
if x:
	pass

if x is not None:
	pass
```

These `if` blocks are not exactly the same. The former is a boolean value test
while the latter explicitly checks that `x` is not `None`.

For example, when checking that `x` has been set to some other value instead of
the default `None`, the former `if` block can evaluate to `false` if it is set
to an empty container or 0.

## References
- [Python docs - Truth Value Testing](https://docs.python.org/3/library/stdtypes.html#truth-value-testing)
- [PEP8 - Programming Recommendations](https://pep8.org/#programming-recommendations)
