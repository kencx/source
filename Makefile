build:
	hugo --buildDrafts --buildFuture -v

serve:
	hugo serve --disableFastRender --gc --ignoreCache --debug --buildDrafts --buildFuture -v

test:
	hugo --gc --minify --enableGitInfo

docker-build:
	docker build . -t site

clean:
	rm -rf public/
