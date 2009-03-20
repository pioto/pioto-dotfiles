DIFFOPTS = -upw

all:

install:
	install -p -m 0644 bashrc $(HOME)/.bashrc
	install -p -m 0644 bash_profile $(HOME)/.bash_profile
	install -p -m 0644 vimrc $(HOME)/.vimrc

diff:
	diff $(DIFFOPTS) $(HOME)/.bashrc bashrc
	diff $(DIFFOPTS) $(HOME)/.bash_profile bash_profile
	diff $(DIFFOPTS) $(HOME)/.vimrc vimrc 

