all: AccBase Invite InviteRoot AccMan deployerDebot

AccBase: 
	tondev sol compile AccBase.sol

Invite:
	tondev sol compile Invite.sol

InviteRoot:
	tondev sol compile InviteRoot.sol

AccMan:
	tondev sol compile AccMan.sol

deployerDebot:
	tondev sol compile deployerDebot.sol

deploy: all
	./deploy_debot.sh