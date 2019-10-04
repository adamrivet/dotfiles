#
# ~/.bashrc
#

[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

export TERM='xterm-256color'

# http://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
shopt -s histappend	# append history not overwrite it
shopt -s checkwinsize	# check window on resize; for word wrapping
shopt -s autocd		# instead of 'cd Pictures', just run Pictures
shopt -s cdspell	# auto correct cd; cd /sur/src/linus' >> 'cd /usr/src/linux'
shopt -s cmdhist	# If set, Bash attempts to save all lines of a multiple-line command in the same history entry. This allows easy re-editing of multi-line commands.
shopt -s no_empty_cmd_completion # No empty completion

# BASH HISTORY {{{
# make multiple shells share the same history file
export HISTSIZE=1000000         # bash history will save N commands
export HISTFILESIZE=${HISTSIZE} # bash will remember N commands
export HISTCONTROL=ignoreboth   # ingore duplicates and spaces
export HISTIGNORE='&:ls:ll:la:cd:exit:clear:history'
#}}}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

complete -cf sudo 
if [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
fi

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# If not running interactively, do not do anything
[[ $- != *i* ]] && return
[[ -z "$TMUX" ]] && exec tmux attach

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

# find alternative apps if it is installed on your system
find_alt() { for i;do which "$i" >/dev/null && { echo "$i"; return 0;};done;return 1; }

# Set the default programs
# the first program in the array that is detected on your system will be chosen as the default
export OPENER=$(find_alt xdg-open exo-open gnome-open )
export BROWSER=$(find_alt google-chrome-stable firefox $OPENER )
export BROWSERCLI=$(find_alt w3m $OPENER )
export BROWSER_PRIVATE="google-chrome-stable --incognito"

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less
alias vi='nvim'
alias vim='nvim'
alias azimuth='bash /home/ad/.scripts/azimuth.sh'
alias backupS='bash /home/ad/.scripts/backup_system.sh'
alias backupF='bash /home/ad/.scripts/backup_file.sh'
alias backup='bash /home/ad/.scripts/backup_all.sh'
alias cr='clear'
alias rebackup='bash /home/ad/.scripts/rebackup.sh'
alias kali='VBoxManage startvm Kali'
alias win='VBoxManage startvm Windows\ 10\ Education'
alias manjaro='VBoxManage startvm Manjaro'
alias chrome='google-chrome-stable'
alias incognito='google-chrome-stable -incognito'
alias ll='ls -la'
alias sb='source ~/.bashrc'
alias vb='vim ~/.bashrc'
alias gc='surfraw -browser=$BROWSER'
alias enfr='surfraw translate -from=en -to=fr'
alias fren='surfraw translate -from=fr -to=en'
alias fres='surfraw translate -from=fr -to=es'
alias esfr='surfraw translate -from=es -to=fr'
alias defr='surfraw translate -from=de -to=fr'
alias frde='surfraw translate -from=fr -to=de'
alias az='surfraw amazon -country=ca'
alias pornhub='surfraw pornhub'
alias youporn='surfraw youporn'
alias g='google'
alias gg='google'
alias y='youtube'
alias yt='youtube'
alias gD='cd /home/ad/Passport-1/Documents'
alias gM='cd /home/ad/Passport-1/Music'
alias gP='cd /home/ad/Passport-1/Pictures'
alias gV='cd /home/ad/Passport-1/Videos'
alias gphi='cd /home/ad/Passport-1/Philo'
alias gh='cd ~'
alias gr='cd /'
alias gCR='cd /home/ad/Passport-1/Documents/Polytechnique'
alias gCR320='cd /home/ad/Passport-1/Documents/Polytechnique/CR320'
alias gCR340='cd /home/ad/Passport-1/Documents/Polytechnique/CR340'
alias gCR350='cd /home/ad/Passport-1/Documents/Polytechnique/CR350'
alias gCR470='cd /home/ad/Passport-1/Documents/Polytechnique/CR470'
alias gCR430='cd /home/ad/Passport-1/Documents/Polytechnique/CR430'
alias gq='cd /opt/qmk_firmware/'
alias gdnd='cd /home/ad/Passport-1/Documents/Forces\ Armées\ Canadiennes'
alias gvpn='cd /home/ad/Passport-1/Documents/VPN'
alias mD='mv /home/ad/Downloads/* /home/ad/Passport-1/Documents/'
alias mM='mv /home/ad/Downloads/* /home/ad/Passport-1/Music/'
alias mP='mv /home/ad/Downloads/* /home/ad/Passport-1/Pictures/'
alias mV='mv /home/ad/Downloads/* /home/ad/Passport-1/Videos/'
alias cateb='cat ~/.w3m/config | grep extbrowser'
alias catel='cat ~/.w3m/keymap'
alias catmux='cat ~/.tmux.conf | grep tmux'
alias catas='cat ~/.bashrc | grep alias'
alias catbm='cat ~/.config/surfraw/bookmarks'
alias catkb='cat /home/ad/Passport-1/Documents/Atreus/keyboard.txt'
alias catlead='cat /home/ad/Passport-1/Documents/Atreus/leader.txt'
alias p='sudo pacman'
alias tor-start='sudo systemctl start tor.service' 
alias tor-stop='sudo systemctl stop tor.service' 
alias u='w3m'
alias nb='newsboat'
alias mutt='neomutt'

# The Pirate Bay on Tor
pb(){ NAME=$1; torsocks w3m http://uj3wazyk5u4hnvtk.onion/search/"$NAME"/0/7/0; }

# Move Something to Documents
mdoc(){ NAME=$1; mv "$NAME" /home/ad/Passport-1/Documents/; }

# Move Something to Music
mmus(){ NAME=$1; mv "$NAME" /home/ad/Passport-1/Music/; }

# Move Something to Pictures
mpic(){ NAME=$1; mv "$NAME" /home/ad/Passport-1/Pictures/; }

# Move Something to Videos
mvid(){ NAME=$1; mv "$NAME" /home/ad/Passport-1/Videos/; }

# Move Everything from Downloads to Somewhere
mdl(){ NAME=$1; mv /home/ad/Downloads/* "$NAME"; }

# Make a new folder and cd into it
mkcd(){ NAME=$1; mkdir -p "$NAME"; cd "$NAME"; }

# cd into a folder and ls
cl(){ NAME=$1; cd "$NAME"; ls; }

# cd into a folder and ls -la
ca(){ NAME=$1; cd "$NAME"; ls -la; }

# Launch ~/.scripts/ueberzug.sh with defined size and location
climg(){ NAME=$1; /home/ad/.scripts/ueberzug.sh 0 0 160 160 "$NAME"; }

# Preserve your fingers from cd ..; cd ..; cd ..;
up(){ DEEP=$1; for i in $(seq 1 ${DEEP:-"1"}); do cd ../; done; }

# Transfer path: save the current path to a hidden file
tp(){ pwd > ~/.sp;}

# Goto transfer path: goes where the previously saved tp points
gtp(){ cd "$(printf "%q\n" "$(cat ~/.sp)")"; }

# Calculator
calc(){ bc -l <<< "$@"; }

# Transmission CLI
tsm-clearcompleted() {
        transmission-remote -l | grep 100% | grep Done | \
        awk '{print $1}' | xargs -n 1 -I % transmission-remote -t % -r ;}
tsm() { transmission-remote --list ;}
# numbers of ip being blocked by the blocklist
tsm-count() { echo "Blocklist rules:" $(curl -s --data \
	'{"method": "session-get"}' localhost:9091/transmission/rpc -H \
	"$(curl -s -D - localhost:9091/transmission/rpc | grep X-Transmission-Session-Id)" \
	| cut -d: -f 11 | cut -d, -f1) ;}
tsm-blocklist() { $PATH_SCRIPTS/blocklist.sh ;}		# update blocklist
tsm-daemon() { transmission-daemon ;}
tsm-quit() { killall transmission-daemon ;}
tsm-altspeedenable() { transmission-remote --alt-speed ;}	# limit bandwidth
tsm-altspeeddisable() {	transmission-remote --no-alt-speed ;}	# dont limit bandwidth
tsm-add() { transmission-remote --add "$1" ;}
tsm-askmorepeers() { transmission-remote -t"$1" --reannounce ;}
tsm-pause() { transmission-remote -t"$1" --stop ;}		# <id> or all
tsm-start() { transmission-remote -t"$1" --start ;}		# <id> or all
tsm-purge() { transmission-remote -t"$1" --remove-and-delete ;} # delete data also
tsm-remove() { transmission-remote -t"$1" --remove ;}		# leaves data alone
tsm-info() { transmission-remote -t"$1" --info ;}
tsm-speed() { while true;do clear; transmission-remote -t"$1" -i | grep Speed;sleep 1;done ;}
tsm-ncurse() { transmission-remote-cli ;}
tsm-exit() { transmission-remote --exit ;}

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fh - search in your command history and execute selected command
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# Simple substitution cipher
cf(){ NAME=$1; echo "$NAME" | tr '[a-zA-Z]' '[axje.uidchtnmbrl`poygk,qf;AXJE.UIDCHTNMBRL`POYGK,QF:]';}

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# better yaourt colors
export YAOURT_COLORS="nb=1:pkg=1:ver=1;32:lver=1;45:installed=1;42:grp=1;34:od=1;41;5:votes=1;44:dsc=0:other=1;35"

# define NeoVim as default
export VISUAL=nvim
export EDITOR="$VISUAL"

### Added by surfraw. To remove use surfraw-update-path -remove
	export PATH=$PATH:/usr/lib/surfraw
### End surfraw addition.

# define rtv browser
export RTV_BROWSER=~/.scripts/urlportal.sh

