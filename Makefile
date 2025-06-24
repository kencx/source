build:
	zola build

serve:
	zola serve

clean:
	rm -rf public/

deploy:
	git push hetzner master
