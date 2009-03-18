all:

install:
	install -p -m 0644 bashrc $(HOME)/.bashrc
	install -p -m 0644 bash_profile $(HOME)/.bash_profile
	install -p -m 0644 vimrc $(HOME)/.vimrc

