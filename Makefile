lint:
	find . -type f -name '*.yaml' -o -name '*.yml' | xargs yamllint --strict
