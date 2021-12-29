all: AccBase Invite InviteRoot AccMan deployerDebot Account

Account:
	everdev sol compile Account.sol

AccBase: 
	everdev sol compile AccBase.sol

Invite:
	everdev sol compile Invite.sol

InviteRoot:
	everdev sol compile InviteRoot.sol

AccMan:
	everdev sol compile AccMan.sol

deployerDebot:
	everdev sol compile deployerDebot.sol

deploy: all
	bash ./deploy_debot.sh

run:
	tonos-cli --url http://127.0.0.1 debot fetch `cat deployerDebot.addr`

debug:
	tonos-cli --url http://127.0.0.1 debot --debug fetch `cat deployerDebot.addr`