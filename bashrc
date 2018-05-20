# LOCAL_BASHRC="$HOME/data/src/github.com/sanemat/dotfiles2016/bashrc"
# if [ -f "$LOCAL_BASHRC" ]; then
#   echo "load $LOCAL_BASHRC"
#    . $LOCAL_BASHRC
# fi

PS1='${debian_chroot:+($debian_chroot)}\$ '

# anyenv
export PATH="$HOME/data/anyenv/bin:$PATH"
export ANYENV_ROOT="$HOME/data/anyenv"
eval "$(anyenv init -)"

# golang
export GOPATH="$HOME/go"
export PATH="$PATH:$HOME/bin:$GOPATH/bin"

# rust
export PATH="$PATH:$HOME/.cargo/bin"

# direnv
eval "$(direnv hook bash)"

# haskell
export STACK_ROOT="$HOME/data/stack"
eval "$(stack --bash-completion-script stack)"

# gem-src
export GEMSRC_USE_GHQ=1

# android
export PATH="$PATH:$HOME/data/android-sdk-linux/tools:$HOME/data/android-sdk-linux/platform-tools"

cdls ()
{
    \cd "$@" && ls && pwd
}
alias cd="cdls"

# http://d.hatena.ne.jp/n9d/20090120/1232404797
# thanx hirocaster
function share_history {
  history -a
  history -c
  history -r
}

# share_history
# ディスパッチ処理
dispatch () {
        export EXIT_STATUS="$?" # 直前のコマンド実行結果のエラーコードを保存

        local f
        for f in ${!PROMPT_COMMAND_*}; do #${!HOGE*}は、HOGEで始まる変数の一覧を得る
            eval "${!f}" # "${!f}"は、$fに格納された文字列を名前とする変数を参照する（間接参照）
        done
        unset f
}
export PROMPT_COMMAND="dispatch"

# 複数のターミナルセッションのヒストリを実行順に保存する
shopt -u histappend
export PROMPT_COMMAND_HISTSAVE="share_history"

export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="cd: cd -:pwd"

# http://qiita.com/yungsang/items/09890a06d204bf398eea
peco-history() {
  local NUM=$(history | wc -l)
  local FIRST=$((-1*(NUM-1)))

  if [ $FIRST -eq 0 ] ; then
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
    echo "No history" >&2
    return
  fi

  local CMD=$(fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)

  if [ -n "$CMD" ] ; then
    # Replace the last entry, "peco-history", with $CMD
    history -s $CMD

    if type osascript > /dev/null 2>&1 ; then
      # Send UP keystroke to console
      (osascript -e 'tell application "System Events" to keystroke (ASCII character 30)' &)
    else
      READLINE_LINE="${CMD}"
      READLINE_POINT=${#CMD}
    fi
    # Uncomment below to execute it here directly
    # echo $CMD >&2
    # eval $CMD
  else
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
  fi
}
bind -x '"\C-r":peco-history'

# http://qiita.com/takayuki206/items/f4d0dbb45e5ee2ee698e
function __show_status() {
    local status=$(echo ${PIPESTATUS[@]})
    local SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    local SETCOLOR_FAILURE="echo -en \\033[1;31m"
    local SETCOLOR_WARNING="echo -en \\033[1;33m"
    local SETCOLOR_NORMAL="echo -en \\033[0;39m"

    local SETCOLOR s
    for s in ${status}
    do
        if [ ${s} -gt 100 ]; then
            SETCOLOR=${SETCOLOR_FAILURE}
        elif [ ${s} -gt 0 ]; then
            SETCOLOR=${SETCOLOR_WARNING}
        else
            SETCOLOR=${SETCOLOR_SUCCESS}
        fi
    done
    ${SETCOLOR}
    echo "(rc->${status// /|})"
    ${SETCOLOR_NORMAL}
}
PROMPT_COMMAND_STATUS="__show_status"

# github
alias gl='cd $(ghq root)/$(ghq list | peco)'
alias gr='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

# bundler
alias be='bundle exec'

# rackup
alias rup="rackup -b \"run Rack::Directory.new('.')\" -p 9494"
