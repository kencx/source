---
title: "Asterisks"
date: 2023-07-07
lastmod: 2023-07-07
draft: false
toc: true
tags:
- python
---

## Use in Argument Types

When used in function **definitions**, asterisk operators `*` and `**kwargs` are
used to define (variable) positional and keyword arguments. See [Argument
Types]({{< ref "til/python/argument-types" >}}) for more details.

## Unpacking Operators

When used in function calls or outside functions, asterisks can be used to
unpack and destructure iterables and dictionaries.

### Function Calls

Unpacking operators are used to unpack values from iterables. `*` can be used on
any Python iterable, while `**` can be used on dictionaries.

With any defined iterable, the `*` operator can be used to *unpack* the iterable
before passing it into a function with a fixed number of arguments. This
iterable must contain the exact number of arguments required by the function.

```python
def add(n1,n2,n3):
	return n1+n2+n3

my_list = [1, 2, 3]
add(*my_list)  # 6

too_long = [1,2,3,4]
add(*too_long)  # add() takes 3 positional args but 4 were given
```

Likewise, multiple unpacking operators can be used to retrieve values from
several iterables:

```python
def add(*args):
	return sum(int(i) for i in args)

list1 = [1, 2, 3]
list2 = [4, 5]
add(*list1, *list2)  # 15
```

Similarly, the `**` operator can also be used in function calls to unpack
dictionaries:

```python
details = {
	"email": "test@example.com"
}

change_user_detail("test", **details)
```

### Destructuring

A list of arbitrary length can be unpacked with the `*` operator during destructuring:

```python
head, *tail = [1,2,3,4,5]

print(head)  # 1
print(tail)  # [2,3,4,5]

head, *middle, tail = [1,2,3,4,5]
print(head)  # 1
print(middle)  # [2,3,4]
print(tail)  # 5
```

{{< alert type="info" >}}
The `*` operator works on any iterable object, including strings:

```python
a = [*"foobar"]
# or
*a, = "foobar"

print(a)
# ['f','o','o','b','a','r']
```
{{< /alert >}}

`_` can be used to ignore specific values during destructuring:

```python
a, _ = [1,2]

print(a)  # 1
```

In combination with `*`, `_*` is used to ignore lists in during destructuring:

```python
a, *_ = [1,2,3,4,5]

print(a)  # 1
```

### Merging Iterables

The unpacking operators are also useful in merging iterables. To merge lists
with a value in the middle,

```python
value = 42
list_1 = [1,2,3]
list_2 = [10,20,30]

merged_list = [*list_1, value, *list_2]
```

To merge dictionaries,

```python
social_media_details = {
    'twitter': 'bascodes'
}

contact_details = {
    'email': 'blog@bascodes.example.com'
}

user_dict = {'username': 'bas', **social_media_details, **contact_details}
```

## References
- [All you need to know about asterisks in Python](https://bas.codes/posts/python-asterisks)
