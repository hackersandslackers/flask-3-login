PROJECT_NAME := $(shell basename $CURDIR)
VIRTUAL_ENV := $(CURDIR)/.venv
LOCAL_PYTHON := $(VIRTUAL_ENV)/bin/python3

define HELP
Manage $(PROJECT_NAME). Usage:

make install    - Create local virtualenv & install dependencies.
make deploy     - Set up project & run locally (not suitable to serve `production` applications).
make update     - Update dependencies via Poetry and output resulting `./requirements/dev.txt`.
make format     - Run Python code formatter & sort dependencies.
make lint       - Check code formatting with flake8.
make clean      - Remove extraneous compiled files, caches, logs, etc.

endef
export HELP


.PHONY: run install deploy update format lint clean help

all help:
	@echo "$$HELP"

env: $(VIRTUAL_ENV)

$(VIRTUAL_ENV):
	if [ ! -d $(VIRTUAL_ENV) ]; then \
		echo "Creating Python virtual env in \`${VIRTUAL_ENV}\`"; \
		python3 -m venv $(VIRTUAL_ENV); \
	fi

.PHONY: install
install: env
	$(LOCAL_PYTHON) -m pip install --upgrade pip setuptools wheel && \
	$(LOCAL_PYTHON) -m pip install -r requirements/dev.txt && \
	echo Installed dependencies in \`${VIRTUAL_ENV}\`;

.PHONY: update
update: env
	$(LOCAL_PYTHON) -m pip install --upgrade pip setuptools wheel && \
	poetry update && \
	poetry export -f ./requirements/dev.txt --output ./requirements/requirements.txt --without-hashes && \
	echo "Updated dependencies in virtualenv \`${VIRTUAL_ENVIRONMENT}\`";

.PHONY: test
test: env
	$(LOCAL_PYTHON) -m \
		coverage run -m pytest -vv \
		--disable-pytest-warnings && \
		coverage html --title='Coverage Report' -d .reports && \
		open .reports/index.html

.PHONY: format
format: env
	$(LOCAL_PYTHON) -m isort --multi-line=3 . && \
	$(LOCAL_PYTHON) -m black .

.PHONY: lint
lint: env
	$(LOCAL_PYTHON) -m flake8 . --count \
			--select=E9,F63,F7,F82 \
			--exclude .git,.github,__pycache__,.pytest_cache,.venv,logs,creds,.venv,docs,logs,.reports \
			--show-source \
			--statistics

.PHONY: clean
clean:
	find . -name 'poetry.lock' -delete && \
	find . -name '.coverage' -delete && \
	find . -name '*.pyc' -delete \
	find . -name '__pycache__' -delete \
	find . -name 'poetry.lock' -delete \
	find . -name '*.log' -delete \
	find . -name '.DS_Store' -delete \
	find . -wholename '**/*.pyc' -delete && \
	find . -wholename '**/*.html' -delete && \
	find . -type d -wholename '__pycache__' -exec rm -rf {} + && \
	find . -type d -wholename '.venv' -exec rm -rf {} + && \
	find . -type d -wholename '.pytest_cache' -exec rm -rf {} + && \
	find . -type d -wholename '**/.pytest_cache' -exec rm -rf {} + && \
	find . -type d -wholename '**/*.log' -exec rm -rf {} + && \
	find . -type d -wholename './.reports/*' -exec rm -rf {} + && \
	find . -type d -wholename '**/.webassets-cache' -exec rm -rf {}

