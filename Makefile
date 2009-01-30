all:

install:
	install -m 0644 bashrc $(HOME)/.bashrc
	install -m 0644 bash_profile $(HOME)/.bash_profile
	install -m 0644 vimrc $(HOME)/.vimrc

