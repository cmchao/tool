#
set autoexpand
set autolist
set history = 30000
set histdup = erase             # Don't save duplicate entries (i.e. repeated commands).

if ( ! ($?MY_PROJECT) ) then
  set prompt = "%n@%m %{\033[36m%}%~%{\033[0m%} %{\033[33m%}%j%{\033[0m%}- "
else
  if ( ! ($?WINDOW) ) then
    setenv WINDOW "-"
  endif

  set prompt = "%n@%m %{\033[36m%}%~%{\033[0m%} <%{\033[32m%}$MY_PROJECT%{\033[0m%}><%{\033[34m%}$WINDOW%{\033[0m%},%{\033[33m%}%j%{\033[0m%}> "
endif

# Add important paths to the front of the path
#if(-e "/tool/path") setenv PATH "/tool/path:$PATH"

setenv MY_PROJ "AA BB CC DD EE"
setenv EDITOR "vim"
setenv LESS "-EfmrSwX"
setenv PAGER "/usr/bin/less"
setenv VISUAL $EDITOR
setenv LS_COLORS "no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=01;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tz=01;31:*.rpm=01;31:*.cpio=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.xbm=01;35:*.xpm=01;35:*.png=01;35:*.tif=01;35:"
if ($OSTYPE == "solaris") then
    setenv LC_ALL en_US.UTF-8
    setenv LANG en_US.UTF-8
else
    setenv LC_ALL en_US.utf8
    setenv LANG en_US.utf8
endif

#
# common usage
#
alias bye "logout"
alias c "cls"
alias cd.. "cd ../"
alias cd2 "cd ../../"
alias cd3 "cd ../../../"
alias cd4 "cd ../../../../"
alias cd5 "cd ../../../../../"
alias cd6 "cd ../../../../../../"
alias d "ls -l"
alias dir "ls -l"
alias dir/p "ls -l \!* | less"
alias l "less"
if ($OSTYPE == "solaris") then
    echo $OSTYPE
    alias ls "ls -F"
    alias g "/bin/grep"
else
    alias ls "ls -F --color=auto"
    alias g "/bin/grep --color --mmap"
endif

alias ll "ls -al"
alias lll "ls -al | less"
alias m "more"
alias more "less"
alias s screen


complete toproj 'p/*/`echo $MY_PROJ`/'

