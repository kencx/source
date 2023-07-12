---
title: "Curl"
date: 2023-07-07
lastmod: 2023-07-07
draft: false
toc: true
tags:
- curl
- snippets
- api
---

## GET

### Query Parameters

This sends a GET request with an URL-encoded query. The explicit `-G, --get`
flag will take all data from the different `-d` variants and append that data to
the url as a query.

```bash
$ curl --get --data-urlencode "foo=bar" http://example.com

# this is similar to
$ curl http://example.com?foo=bar
```

## POST

### Text data

This sends a POST request with data in the request body. The `-d` flag
automatically sets:

- the header `Content-Type: application/x-www-form-urlencoded`
- the flag `-X POST`

```bash
$ curl -X POST -d 'login=foo&password=bar' http://example.com
```

{{< alert type="info" >}}
The flags `-d, --data` and `--data-binary` are similar except that the latter
preserves newlines and carriage returns. The default content type for both is
set to `application/x-www-form-urlencoded`.
{{< /alert >}}

### JSON data

This sends a POST request with JSON data. The `-H` option to set the content
type is compulsory.

```bash
$ curl -d '{"login": "foo", "password": "bar"}' \
	-H 'Content-Type: application/json' \
	http://example.com
```

Alternatively, you can use the `--json` flag as a shortcut. It automatically
sets:

 - The flag `--d data`
 - The header `--header "Content-Type: application/json"`
 - The header `--header "Accept: application/json"`

It does not, however verify that the data passed is valid JSON.

```bash
curl --json '{"login": "foo", "password": "bar"}' http://example.com
```

### Data from File

This sends a POST request with data from a file. The `@` symbol tells curl that `data.txt` is a file instead of a string.

```bash
$ curl -d '@data.txt' http://example.com
```

The above assumes all data is url-encoded. If the data is not, replace `-d` with `--data-urlencode`:

```bash
$ curl -X POST --data-urlencode 'comment=hello world' http://example.com
```

### Data from stdin

curl can also read data from stdin with `@-`

```bash
curl -d @- http://example.com
{
	"foo": "bar"
}
# end with ctrl+d
```

### Form

For HTTP, the `-F, --form` flag allows curl to emulate a filled-in form where
the user has pressed the submit button. This forces curl to use the
`Content-Type: multipart/form-data` header.

The form flag enables uploading of binary files in two ways (`@` and `<`). The
`@` symbol ensures that the file is attached in the POST request as a file
upload. Conversely, the `<` symbol creates a text field and adds the contents
from the file into the text field similar to that in `--data`.

This sends a POST request with a binary file.

```bash
$ curl -F 'file=@photo.png' http://example.com
```

We can also POST the binary file and specify its MIME type. If no type is
specified, curl defaults it to `application/octet-stream`

```bash
$ curl -F 'file=@photo.png;type=image/png' http://example.com
```

### Form and JSON Data

To send both JSON data (from a file) and a binary file in the same request:

```bash
$ curl -X POST -H "Content-Type:multipart/form-data" \
	-F "upload1=<john.json" \
	-F "upload2=@john.jpg" \
	http://example.com

# or

$ curl -X POST -F "upload1=<john.json;type=application/json" \
	-F "upload2=@john.jpg;type=multipart/form-data" \
	http://example.com
```

## References

- [Everything curl](https://everything.curl.dev/)
- [curl Cookbook](https://catonmat.net/cookbooks/curl)
- [Use curl to post multipart form data file and json](https://stackoverflow.com/questions/53724134/use-curl-to-post-multipart-form-data-file-and-lots-of-key-value-pairs)
