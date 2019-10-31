all: requirements
	rm -rf s3-rw-test.zip
	(cd src && zip -qXr ../s3-rw-test.zip .)

requirements: requirements.txt.out

requirements.txt.out: requirements.txt
	git clean -qfdx src
	pip3 install -q -t src -r requirements.txt | tee requirements.txt.out

.PHONY: all requirements
