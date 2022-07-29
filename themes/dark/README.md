## SVG Icons

Add new svg icons to `layouts/partials/svg/icons.html` in the following form:

```
	{{ else if eq "[name]" . }}
		<path d="..."></path>
```

and include it in your html with

```
< a href="...">{{ partial "svg/icons" "[name]" }}</a>
```
