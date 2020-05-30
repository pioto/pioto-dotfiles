DIFFOPTS = -upw

all:

install:
	install -p -m 0644 bashrc $(HOME)/.bashrc
	install -p -m 0644 bash_profile $(HOME)/.bash_profile
	install -p -m 0644 zshrc $(HOME)/.zshrc
	install -p -m 0644 zshenv $(HOME)/.zshenv
	install -p -m 0644 zprofile $(HOME)/.zprofile
	install -p -m 0644 vimrc $(HOME)/.vimrc
	install -p -m 0644 inputrc $(HOME)/.inputrc

diff:
	diff $(DIFFOPTS) $(HOME)/.bashrc bashrc || true
	diff $(DIFFOPTS) $(HOME)/.bash_profile bash_profile || true
	diff $(DIFFOPTS) $(HOME)/.zshrc zshrc || true
	diff $(DIFFOPTS) $(HOME)/.zprofile zprofile || true
	diff $(DIFFOPTS) $(HOME)/.vimrc vimrc || true
	diff $(DIFFOPTS) $(HOME)/.inputrc inputrc || true

