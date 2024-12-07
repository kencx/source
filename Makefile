build:
	hugo --buildDrafts --buildFuture --gc --minify --enableGitInfo

serve:
	hugo serve --buildDrafts --buildFuture --gc --enableGitInfo --ignoreCache --disableFastRender

clean:
	rm -rf public/
