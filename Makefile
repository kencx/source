build:
	hugo --buildDrafts --buildFuture --gc --minify --enableGitInfo

serve:
	hugo serve --buildDrafts --buildFuture --gc --enableGitInfo --ignoreCache --debug --disableFastRender

clean:
	rm -rf public/
