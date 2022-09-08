serve:
	hugo serve --disableFastRender --gc --ignoreCache --debug --buildDrafts -v

docker-build:
	docker build . -t site

clean:
	rm -rf public/
