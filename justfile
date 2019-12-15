test:
	python2 -m doctest ./setup.py
	python3 -m doctest ./setup.py

lint:
	mypy setup.py || true
	prospector setup.py || true
	bandit setup.py || true
	flake8 setup.py --doctests --max-line-length=135 || true
	pydocstyle --convention=google setup.py || true
