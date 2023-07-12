---
title: "Identity and Equivalence"
date: 2023-07-12
lastmod: 2023-07-12
draft: false
toc: true
tags:
- python
---

In Python, there are two equality operators:

- Double equals `==` ensures **value equality**. It returns `True` if the objects
  referred to by the variables are equal.
- `is` ensures **reference equality**. It returns `True` if the two variables
  reference the same object (in memory).

```python
a = [1,2,3]
b = a

>>> b is a
True
>>> b == a
True
```

If we make a new copy of list `a` and assign it to `b`, `b` no longer refers to
same object as `a`:

```python
a = [1,2,3]
b = a[:]

>>> b is a
False
>>> b == a
True
```

## is Operator

`is` is useful for checking an object that should only exist once in memory,
i.e. a singleton. It does this by checking that the `id` of two objects are the
same.

The [id](https://docs.python.org/3/library/functions.html#id) returns the
identity of an object. This is an integer which is guaranteed to be unique and
constant for this object during its lifetime. In CPython, `id` is the location
in memory. Hence, the following are similar:

```python
>>> a is b
>>> id(a) == id(b)
```

Naturally, `a is b` implies `a == b`.

## Double Equals Operator

The double equals operator `==` is determined by the `__eq__()` method. It is
best used with numbers, strings, mutable objects and lists, sets and
dictionaries. `a == b` does not imply `a is b`.

## Best Practices

[PEP8](https://pep8.org/#programming-recommendations) suggest that comparisons
with `None` should always be done with `is` and `is not`.

`is` should [never be
used](https://stackoverflow.com/questions/306313/is-operator-behaves-unexpectedly-with-integers/28864111#28864111)
to compare integers and other immutable objects. Python will attempt to cache
some of these immutable objects, resulting in unpredictable behaviour if `a is
b` is used.

>On a related note, see [Truthy and Falsy]({{< relref "notes/python/truthy-and-falsy" >}}).

## References

- [Is there a difference between is and \=\=](https://stackoverflow.com/questions/132988/is-there-a-difference-between-and-is)
- [is operator behaves unexpectedly with integers](https://stackoverflow.com/questions/306313/is-operator-behaves-unexpectedly-with-integers/28864111#28864111)
- [PEP8 - Programming Recommendations](https://pep8.org/#programming-recommendations)
