# Configuration for auto backups to github of minecraft bedrock world files
## Requires initial bedrock server configuration running in tmux

### Create ssh keys for backup job (use it only for connecting to github repo)
> ssh-keygen -t ed25519 -C "minecraft-backup" -f ~/.ssh/minecraft_backup
> chmod 600 ~/.ssh/minecraft_backup
> chmod 644 ~/.ssh/minecraft_backup.pub

### Add key to gihub repository with write access (deploy keys)
> cat ~/.ssh/minecraft_backup.pub

### Create ssh config
> nano ~/.ssh/config

### Put this there
```
Host github-minecraft
HostName github.com
User git
IdentityFile ~/.ssh/minecraft_backup
IdentitiesOnly yes
```

### Clone gihub repo locally
> git clone <github-repo-ssh-url> minecraf-world-backup

### Test connectivity
> chmod 600 ~/.ssh/config
> ssh -T github-minecraft

### Create gitignore
> nano ~/minecraft-world-backup/.gitignore
```
*
!worlds/
!worlds/**
!.gitignore
```

### Test manual backup first
> git add worlds .gitignore
> git status
> git commit -m "Initial Minecraft world backup"
> git push origin master

### Download backup script and makeit executable
> chmod +x ~/minecraft-backup.sh

### Create backup service and timer
> sudo nano /etc/systemd/system/minecraft-backup.service
```
[Unit]
Description=Backup Minecraft Bedrock worlds to GitHub
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=guru
ExecStart=/home/guru/minecraft-backup.sh
```
> sudo nano /etc/systemd/system/minecraft-backup.timer
```
[Unit]
Description=Daily Minecraft world backup at 03:00

[Timer]
OnCalendar=*-*-* 01:00:00
OnCalendar=*-*-* 13:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

### Enable everything
> sudo systemctl daemon-reload
> sudo systemctl enable --now minecraft-backup.timer

### Backup should work now, but you can check it
> sudo systemctl start minecraft-backup.service
> journalctl -xeu minecraft-backup.service


