serve:
	hugo serve --disableFastRender --gc --ignoreCache --debug -v

docker-build:
	docker build . -t site

clean:
	rm -rf public/
