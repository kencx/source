build:
	zola build

serve:
	zola serve

clean:
	rm -rf public/

deploy:
	git push

redeploy:
	git commit --amend --no-edit --allow-empty
	git push origin master --force-with-lease
