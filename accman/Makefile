all: AccBase Invite InviteRoot AccMan deployerDebot Account

Account:
	tondev sol compile Account.sol

AccBase: 
	tondev sol compile AccBase.sol

Invite:
	tondev sol compile Invite.sol

InviteRoot:
	tondev sol compile InviteRoot.sol

AccMan:
	tondev sol compile AccMan.sol

deployerDebot:
	everdev sol compile deployerDebot.sol

deploy: all
	bash ./deploy_debot.sh

run:
	tonos-cli --url http://127.0.0.1 debot fetch `cat deployerDebot.addr`

debug:
	tonos-cli --url http://127.0.0.1 debot --debug fetch `cat deployerDebot.addr`

updaccman: AccMan
	UPDATE=true ./update.sh net.ton.dev

images:
	tonos-cli run `cat AccMan.addr` getImages {} --abi AccMan.abi.json