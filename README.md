# Configuration for auto backups to github of minecraft bedrock world files

### Create ssh keys for backup job (use it only for connecting to github repo)
> ssh-keygen -t ed25519 -C "minecraft-backup" -f ~/.ssh/minecraft_backup
> chmod 600 ~/.ssh/minecraft_backup
> chmod 644 ~/.ssh/minecraft_backup.pub

### Add key to gihub repository with write access (deploy keys)
> cat ~/.ssh/minecraft_backup.pub

### Create ssh config
> nano ~/.ssh/config

### Put this there
> Host github-minecraft
'''
HostName github.com
User git
IdentityFile ~/.ssh/minecraft_backup
IdentitiesOnly yes
'''

### Test it
> chmod 600 ~/.ssh/config
> ssh -T github-minecraft

### Clone gihub repo locally
> git clone <github-repo-ssh-url> minecraf-world-backup



