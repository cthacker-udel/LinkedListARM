

MSG := "this is a message"

git:
	git add -A; git commit -m 'Committed using Makefile'; git push

gitmsg:
	git add -A; git commit -m "${MSG}"; git push
