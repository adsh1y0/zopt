#/bin/zsh

#################################################
### Changing Directories
#################################################

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

#################################################
### Completion
#################################################

setopt always_to_end
setopt complete_in_word
unsetopt list_beep

WORDCHARS=''

zmodload zsh/complist

zstyle ':completion:*' menu select

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Z}{a-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }

  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

[ -n "${terminfo[kcbt]}" ] && bindkey "${terminfo[kcbt]}" reverse-menu-complete

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

if [ -z "$LS_COLORS" ]; then
  zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:'
else
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

#################################################
### History
#################################################

setopt hist_expire_dups_first
setopt hist_verify
setopt hist_ignore_dups # 前と重複する行は記録しない
setopt hist_ignore_all_dups # 重複するコマンドは古いものを削除する
setopt hist_ignore_space # 行頭がスペースのコマンドは記録しない
setopt hist_find_no_dups # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt hist_reduce_blanks # 余分な空白は詰めて記録
setopt hist_no_store # histroyコマンドは記録しない

setopt share_history # 直前と同じコマンドの場合は履歴に追加しない
setopt inc_append_history
setopt append_history # 複数のzshを同時に使用した際に履歴ファイルを上書きせず追加する

[ -z "$HISTFILE" ] && HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

#################################################
### Input/Output
#################################################

unsetopt flow_control

#################################################
### Functions
#################################################

__record_command() {
  typeset -g _LASTCMD=${1%%$'\n'}
  return 1
}
zshaddhistory_functions+=(__record_command)

__update_history() {
  local last_status="$?"

  # hist_ignore_space
  if [[ ! -n ${_LASTCMD%% *} ]]; then
    return
  fi

  # hist_reduce_blanks
  local cmd_reduce_blanks=$(echo ${_LASTCMD} | tr -s ' ')

  # Record the commands that have succeeded
  if [[ ${last_status} == 0 ]]; then
    print -sr -- "${cmd_reduce_blanks}"
  fi
}
precmd_functions+=(__update_history)

