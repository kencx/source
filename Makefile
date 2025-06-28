build:
	zola build

serve:
	zola serve

clean:
	rm -rf public/

deploy:
	git push hetzner master

redeploy:
	git commit --amend --no-edit --allow-empty
	git push hetzner master --force-with-lease
