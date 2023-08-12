---
title: "sxkcd"
date: 2023-08-10
lastmod: 2023-08-10
draft: true
toc: true
tags:
- projects
- go
- redis
---

s(earch)xkcd is a [xkcd](https://xkcd.com) search engine that supports full-text
search and an extensive query syntax. It is built with Go, Svelte and the data
is stored and indexed in Redis.

{{< alert type="note" >}}
You can try it out [here](xkcd.cheo.dev) and find the source code at
[kencx/sxkcd](https://github.com/kencx/sxkcd) on Github.
{{< /alert >}}

In this post, I will be writing about some things I learnt while building
`sxkcd` including:

- Handling concurrency and signals in Go
- Using Redis Stack's features
- Decoding a JSON stream in Go
- Handling root processes in Docker

## Getting the Data

First, let's discuss how the data was retrieved.

The comics and their metadata were obtained from xkcd's JSON endpoint at
`https://xkcd.com/[n]/info.0.json`, where `n` is the comic number. This contains
the comic number, date of posting, image link, safe title, transcript and
alternative text.

To complement this, I also downloaded data from the
[explainxkcd](https://explainxkcd.com) wiki which contain great explanations of
every single xkcd comic. The data from both sites are cleaned and are combined
into a single `Comic` struct, which will be indexed into Redis (more on that
later).

### Concurrency

When downloading the data, all requests are performed concurrently with
Goroutines. My first implementation of this was a simple [counting
semaphore](https://en.wikipedia.org/wiki/Semaphore_(programming)) using
`sync.WaitGroup`:

```go
func GetAllComics(total int) ([]*XkcdComic, error) {
	var wg sync.WaitGroup

    // max number of concurrent requests
	tokens := make(chan struct{}, 50)
	comics := make([]*XkcdComic, total)

	for i := 1; i < total+1; i++ {
		wg.Add(1)

		go func(i int) {
			defer func() { <-tokens }()
			defer wg.Done()

			tokens <- struct{}{}
			if i == 404 {
				return
			}

			comic, err := GetXkcdComic(strconv.Itoa(i))
			if err != nil {
				log.Println(err)
				return
			}

			comics[i-1] = comic
		}(i)
	}
	wg.Wait()
	return comics, nil
}
```

All data is collected in the array `comics`. You might notice that there are no
mutexes. This is because multiple goroutines can write to *different* slice
elements concurrently. Each slice element in Go has its own address space,
effectively making them distinct variables.

>Structured variables of array, slice, and struct types have elements and fields
>that may be addressed individually. Each such element acts like a variable.
>
>-- [The Go Programming Language
>Specification#Variables](https://go.dev/ref/spec#Variables)

The function above creates a fixed size array `comics` and each goroutine
indexes a comic into a different element. It does not write to the same
element more than once nor does it read the `comics` slice until after
`wg.Wait()` is called, making the function concurrency-safe.

However, the function didn't allow the user to gracefully cancel the process or
handle signals in a clean way.

### ErrGroup

The second implementation aimed to tackle these issues with `sync.errgroup`:

```go
func (c *Client) RetrieveAllComics(latest int) (map[int]*Comic, error) {

	var mu sync.Mutex
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	g, gtx := errgroup.WithContext(ctx)
	g.SetLimit(60)

	comics := make(map[int]*Comic, latest)
	for i := 1; i < latest+1; i++ {
		id := i

		g.Go(func() error {
			if id == 404 {
				return nil
			}
			comic, err := c.RetrieveComic(id)
			if err != nil {
				log.Println(err)
				return err
			}

			mu.Lock()
			defer mu.Unlock()
			comics[id] = comic

			select {
			case <-gtx.Done():
				return gtx.Err()
			default:
				return nil
			}
		})
	}

	if err := g.Wait(); err == nil || err == context.Canceled {
		return comics, nil
	} else {
		return nil, err
	}
}
```

{{< alert type="note" >}}
Because I switched `comics` to being a map, mutexes are required.
{{< /alert >}}

The experimental [errgroup
package](https://pkg.go.dev/golang.org/x/sync/errgroup) offers the `Group` type
which is functionally equivalent to `WaitGroup`, except that it offers an
idiomatic way to handle errors and context cancellations in a group of
goroutines.

In our case, I wanted to cancel the task when a `SIGINT` or `SIGTERM` signal is
given. A new `Group` is created with `errgroup.WithContext` that holds a context
created with `NotifyContext`. This context will be cancelled when any of the
given signals are passed to the process. In that event, the cancellation is
broadcasted to all running goroutines, which are polling for cancellations in
the `select` block.

At the end, there is a `g.Wait()` that behaves like `wg.Wait()` and ensures all
goroutines are done or cancelled before handling any errors.

This method is probably a bit overkill since a channel would have worked just as
well, but I enjoyed learning about `sync.ErrGroup` and this seemed like a great
opportunity to incorporate it.

## Indexing the Data

With the data downloaded and cleaned, it's time to index it for search and
querying.

### Why Redis?

I chose to use Redis for storing and indexing the data for a few reasons:

- It's simple and fast
- The dataset is relatively small and entirely JSON
- It offers a full-text search module with
  [RediSearch](https://redis.io/docs/interact/search-and-query/)
- It offers full support for indexing, querying and filtering JSON documents
  with [RedisJSON](https://redis.io/docs/data-types/json/)

Compared with something more complex like ElasticSearch or Algolia, Redis was
extremely easy to set up and had a decent
[Go client](https://github.com/go-redis/redis) with little trade-off for
performance.

But that's not to say I can't optimize the indexing process.

### Memory Overhead

Each comic is stored as a JSON document in Redis. Redis JSON stores JSON as
binary data after deserialization, which can be more
[costly](https://redis.io/docs/data-types/json/ram/) than simply storing them in
the serialized form. The total filesize of the dataset comes up to 11MB, which
translates to about 41MB or about 2-3% of memory on a system with 2GB of RAM.

```text
# redis-cli) MEMORY STATS
1) "peak.allocated"
2) (integer) 42619944
3) "total.allocated"
4) (integer) 42147800
5) "startup.allocated"
6) (integer) 1014800
...
25) "dataset.bytes"
26) (integer) 40987744
```

In addition to Redis' memory use, there are also the resources used by `sxkcd`
when it first reads the given JSON file and indexes the data into Redis.

My initial implementation was how I usually handled JSON data: reading the file
and unmarshaling the data into a map:

```go
func (s *Server) ReadFile(filename string) error {
    body, err := os.ReadFile(filename)

	if err := json.Unmarshal(body, &s.comics); err != nil {
		return fmt.Errorf("failed to unmarshal data: %v", err)
	}

	err = s.Index()
    // TRUNCATED FOR BREVITY ...
}

func (s *Server) Index() error {

    for i, c := range s.comics {
        j, err := json.Marshal(&c)
        if err != nil {
            return fmt.Errorf("failed to marshal comic %d: %v", c.Number, err)
        }

        id := strconv.Itoa(i)
        pipe.Do(s.ctx, "JSON.SET", "comic:"+id, "$", j)
    }
    // TRUNCATED FOR BREVITY ...
}
```

This contributed to 15.20MB on startup, with most of the memory going to
`os.ReadFile`:

```text
File: sxkcd
Type: inuse_space
Time: Aug 12, 2023 at 1:03am (+08)
Showing nodes accounting for 15.20MB, 100% of 15.20MB total
      flat  flat%   sum%        cum   cum%
   10.68MB 70.24% 70.24%    10.68MB 70.24%  os.ReadFile
    4.53MB 29.76%   100%     4.53MB 29.76%  encoding/json.(*decodeState).literalStore
         0     0%   100%     4.53MB 29.76%  encoding/json.(*decodeState).object
         0     0%   100%     4.53MB 29.76%  encoding/json.(*decodeState).unmarshal
         0     0%   100%     4.53MB 29.76%  encoding/json.(*decodeState).value
         0     0%   100%     4.53MB 29.76%  encoding/json.Unmarshal
         0     0%   100%    15.20MB   100%  github.com/kencx/sxkcd/http.(*Server).ReadFile
         0     0%   100%    15.20MB   100%  main.main
         0     0%   100%    15.20MB   100%  runtime.main
```

To optimize this, I decode the streamed JSON body instead of unmarshaling the
entire file at once:

```go
func decodeFile(filename string) ([]data.Comic, error) {
	var rc io.ReadCloser

    rc, err := os.Open(filename)
    if err != nil {
        return nil, fmt.Errorf("failed to read %s: %v", filename, err)
    }
    defer rc.Close()

	dec := json.NewDecoder(rc)

	t, err := dec.Token()
	if err != nil {
		return nil, fmt.Errorf("token err: %v", err)
	}
	if t.(json.Delim) != '{' {
		return nil, fmt.Errorf("not json object")
	}

	var comics []data.Comic
	for dec.More() {
		_, err = dec.Token()
		if err != nil {
			return nil, fmt.Errorf("key err: %v", err)
		}

		var val data.Comic
		err = dec.Decode(&val)
		if err != nil {
			return nil, fmt.Errorf("decode err: %v", err)
		}
		comics = append(comics, val)
	}
	return comics, nil
}

// TRUNCATED FOR BREVITY
func (s *Server) Initialize(filename string, reindex bool) error {
	comics, err := decodeFile(filename)
	err = s.rds.CreateIndex()
	err = s.rds.AddBatch(comics)
}
```

{{< alert type="note" >}}
I excluded `AddBatch()` because it is similar to the previous `Index()` function
and not important here. For more details, check out the full [source
code](https://github.com/kencx/sxkcd).
{{< /alert >}}

The `json` package docs actually gives a [good
example](https://pkg.go.dev/encoding/json#Decoder.Decode) for decoding a stream
of JSON objects, which I lifted.

With that, the binary now contributes 10MB of memory on startup, a 34.6%
decrease.

```text
File: sxkcd
Type: inuse_space
Time: Aug 12, 2023 at 1:56am (+08)
Showing nodes accounting for 9934.30kB, 100% of 9934.30kB total
      flat  flat%   sum%        cum   cum%
 9250.55kB 93.12% 93.12%  9250.55kB 93.12%  encoding/json.(*decodeState).literalStore
  683.75kB  6.88%   100%  9934.30kB   100%  github.com/kencx/sxkcd/http.decodeFile
         0     0%   100%  9250.55kB 93.12%  encoding/json.(*Decoder).Decode
         0     0%   100%  9250.55kB 93.12%  encoding/json.(*decodeState).object
         0     0%   100%  9250.55kB 93.12%  encoding/json.(*decodeState).unmarshal
         0     0%   100%  9250.55kB 93.12%  encoding/json.(*decodeState).value
         0     0%   100%  9934.30kB   100%  github.com/kencx/sxkcd/http.(*Server).Initialize
         0     0%   100%  9934.30kB   100%  main.main
         0     0%   100%  9934.30kB   100%  runtime.main
```

Saving 5MB seems a little tiny, but it was a good learning experience.

## Updating the Dataset Regularly

Randall uploads new comics every Monday, Wednesday and Friday (usually), and I
needed a way to update the database with new comics when they are released.

Initially, this was done with a crude cronjob that regularly downloads and
re-indexes the entire dataset. This was extremely prone to error and I didn't
like that I was hitting the xkcd site with more than 2000 requests everyday, so
I quickly scraped that.

This is now replaced with a background worker that regularly checks for new
comics. The new comics are downloaded and added to the existing dataset, without
needed to re-index the data or restart the application.

```go
// Add document if not already exists
func (r *Client) Add(id int, comic []byte) error {
	id_str := strconv.Itoa(id - 1)

	exists, err := r.rd.Exists(r.ctx, KeyPrefix+id_str).Result()
	if err != nil {
		if err != redis.Nil {
			return fmt.Errorf("failed to add comic: %v", err)
		}
	}
	if exists != 0 {
		fmt.Printf("comic %v already present", KeyPrefix+id_str)
		return nil
	}

	err = r.rd.Do(r.ctx, "JSON.SET", KeyPrefix+id_str, "$", string(comic)).Err()
	if err != nil {
		return fmt.Errorf("failed to add comic: %v", err)
	}
	return nil
}
```

This checks if a specific comic already exists and adds it to Redis if it does not.

## Root Processes in Docker

The application is deployed with Docker on my VPS. To start it, I used the
entrypoint script:

```bash
#!/bin/sh

./sxkcd server -p 6380 -r redis:6379 -f /data/comics.json
```

There are two problems with this:
- The path to the data file is hardcoded into the image and can only be
  customized by replacing the entire entrypoint
- The container does not have proper signal handling

The former was obvious (although I didn't fix it until very recently), but the
latter was something I wasn't aware of. When running my crude cronjob to update
the dataset, I noticed that the `sxkcd` container always waited for 10s before
shutting down, which was odd since I had proper signal handling in place:

```go
func (s *Server) Run(port int) error {

    // TRUNCATED FOR BREVITY...

	go func() {
		err := srv.ListenAndServe()
		if !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("failed to start server: %v", err)
		}
	}()
	log.Printf("Server started at %s", p)

	// graceful shutdown
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	sig := <-sigCh
	log.Printf("Received signal %s, shutting down...", sig.String())

	tc, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	log.Printf("Application gracefully stopped")
	return nil
```

Some research led me to realising I was starting `sxkcd` as a child process in
the container, and the signals were not being properly propagated from PID 1 to
this child process. The container was taking 10s to shutdown because Docker
force kills the container after a grace period of 10s.

```bash
# inside container
$ ps
PID TIME     CMD
1   00:00:00 /bin/sh /entrypoint.sh
7   00:00:00 ./sxkcd server -p 6380 -r redis:6379 -f /data/comics.json
```

The fix was to prepend an `exec` to the command in the entrypoint,
replacing the parent process with it:

```bash
#!/bin/sh

exec ./sxkcd server -p 6380 -r redis:6379 "$@"
```

The added `$@` also allows the user to pass their own `-f /path/to/comics.json`
to the container.

```bash
# inside container
$ ps
PID TIME     CMD
1   00:00:00 ./sxkcd server -p 6380 -r redis:6379 -f /data/comics.json
```

The root process in the container is now `sxkcd` and stopping the container
takes less than a second.

{{< alert type="note" >}}
I wrote about more signal handling in Docker in my [notes]({{< ref
"notes/docker/signal-handling.md" >}}).
{{< /alert >}}

## Improvements

This post is getting a little long, but I would just like to end off with some
stuff that `sxkcd` could be improved on, most of which concern the frontend:

- The images are not very readable on mobile. It would be great to add an image
  zoom on click.
- Some accented characters and strange unicode might not supported. See #259
- Interactive comics are not supported. The comic simply appears as a `png`
- The `sxkcd` CLI UX is a little messy for my taste and could be more intuitive


## References
- [Can I concurrently write different slice elements](https://stackoverflow.com/questions/49879322/can-i-concurrently-write-different-slice-elements/49879469#49879469)
- [The Go Programming Language Specification](https://go.dev/ref/spec)
