# systemctl
abbr -a -- sc systemctl
abbr -a -- scu 'systemctl --user'
abbr -a -- scs 'systemctl status'
abbr -a -- scr 'sudo systemctl restart'
abbr -a -- scstart 'sudo systemctl start'
abbr -a -- scstop 'sudo systemctl stop'
abbr -a -- scrl 'sudo systemctl reload'
abbr -a -- sce 'sudo systemctl enable'
abbr -a -- scd 'sudo systemctl disable'
abbr -a -- scen 'sudo systemctl enable --now'
abbr -a -- scdn 'sudo systemctl disable --now'
abbr -a -- scf 'systemctl --failed'
abbr -a -- scdr 'sudo systemctl daemon-reload'

# journalctl
abbr -a -- jr journalctl
abbr -a -- jru 'journalctl --user'
abbr -a -- jrf 'journalctl -f'
abbr -a -- jrb 'journalctl -b -1'
abbr -a -- jre 'journalctl -p err -b'

# networkctl
abbr -a -- nctl networkctl
abbr -a -- nctls 'networkctl status'
abbr -a -- nctll 'networkctl list'

# resolvectl
abbr -a -- rctl resolvectl
abbr -a -- rctls 'resolvectl status'
abbr -a -- rctld 'resolvectl dns'
abbr -a -- rctlq 'resolvectl query'
abbr -a -- rctlf 'resolvectl flush-caches'

# sysadmin
abbr -a -- ports 'ss -tulnp'
abbr -a -- ipa 'ip -c addr'
abbr -a -- ipr 'ip -c route'
abbr -a -- ipl 'ip -c link'
abbr -a -- dm 'dmesg -H'
abbr -a -- freeh 'free -h'
abbr -a -- dk dysk

# docker
abbr -a -- d docker
abbr -a -- dps 'docker ps'
abbr -a -- dpsa 'docker ps -a'
abbr -a -- di 'docker images'
abbr -a -- dex 'docker exec -it'
abbr -a -- dl 'docker logs'
abbr -a -- dlf 'docker logs -f'
abbr -a -- drun 'docker run --rm'
abbr -a -- drit 'docker run -it --rm'
abbr -a -- dpu 'docker pull'
abbr -a -- dst 'docker stop'
abbr -a -- drm 'docker rm'
abbr -a -- drmi 'docker rmi'
abbr -a -- dsp 'docker system prune'

# docker compose
abbr -a -- dc 'docker compose'
abbr -a -- dcu 'docker compose up -d'
abbr -a -- dcd 'docker compose down'
abbr -a -- dcr 'docker compose restart'
abbr -a -- dcl 'docker compose logs -f'
abbr -a -- dcps 'docker compose ps'
abbr -a -- dcb 'docker compose build'
abbr -a -- dcex 'docker compose exec'
abbr -a -- dcp 'docker compose pull'

# Etc
abbr -a -- l 'eza -lh --icons --git'
abbr -a -- v nvim
abbr -a -- cm chezmoi
abbr -a -- se sudoedit
abbr -a -- nr 'npm run'
abbr -a -- nrd 'npm run dev'
abbr -a -- ni 'npm i'
abbr -a -- kssh 'kitty +kitten ssh'
abbr -a -- ksshg 'kitty +kitten ssh gram'
abbr -a -- kicat 'kitty +kitten icat'
abbr -a -- kdiff 'kitty +kitten diff'
abbr -a -- kthemes 'kitty +kitten themes'
abbr -a -- kclip 'kitty +kitten clipboard'
abbr -a -- ktransfer 'kitty +kitten transfer'
abbr -a -- kbroadcast 'kitty +kitten broadcast'
abbr -a -- khints 'kitty +kitten hints'
abbr -a -- kunicode 'kitty +kitten unicode_input'
abbr -a -- kfonts 'kitty +kitten choose-fonts'
abbr -a -- kfiles 'kitty +kitten choose-files'
abbr -a -- cl claude
abbr -a -- clc "claude -c"
abbr -a -- pg 'pgcli -h localhost -p 5432 -U postgres'
abbr -a -- pss 'ps aux | grep -i'
abbr -a -- gg lazygit
