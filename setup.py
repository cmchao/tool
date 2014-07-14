#!/usr/bin/env python
import inspect
import sys
import os

def try_link(src, dst):
    """ link src to dst and print msg by caller name """

    caller = inspect.stack()[1][3]

    try:
        os.symlink(src, dst)
        print "[OK]%s : link '%s' to '%s'" % (caller, src, dst)
    except OSError as e:
        print "[ERROR]%s : link '%s' to '%s' (%s)" % (caller, src, dst, e.strerror)


def setup_bash():
    """ setup bash """

    selfname = inspect.stack()[0][3]
    cur = os.getcwd()
    home = os.getenv("HOME")

    cmd = """
if [ -e $H/.bashrc.private ]; then
    . $HOME/.bashrc.private
fi
    """
    if os.path.exists(home + "/.bashrc"):
        for line in open(home + "/.bashrc"):
            if line.find("$HOME/.bashrc.private") >= 0:
                print "[OK]%s : .bashrc has source .bashrc.private" % (selfname)
                break
        else:
            with open(home + "/.bashrc", "a+") as outfile:
                print >> outfile, cmd

            print "[OK]%s : insert source .bashrc.private to ~/.bashrc" % (selfname)
            try_link(cur + "/share/bash/.bashrc.private", home + "/.bashrc.private")

    elif os.path.exists(home + "/.profile"):
        for line in open(home + "/.profile"):
            if line.find("$HOME/.bashrc.private") >= 0:
                print "[OK]%s : .profile has source .bashrc.private" % (selfname)
                break
        else:
            outfile = open(home + "/.profile", "a+")
            print outfile, cmd
            outfile.close()
            print "[OK]%s : insernt source .bashrc.private to ~/.profile" % (selfname)
            try_link(cur + "/share/bash/.bashrc.private", home + "/.bashrc.private")
    else:
        print "[ERROR]%s : can't find '.profile' or '.bashrc.private'" % ( selfname)
        return



def setup_xtool():
    """ setup xtool """

    arch_list = ["arm", "aarch64"]
    tool_list = [ 
                "addr2line",
                "ar",
                "as",
                "c++",
                "c++filt",
                "cpp",
                "g++",
                "gcc",
                "gccbug",
                "gcov",
                "ld",
                "nm",
                "objcopy",
                "objdump",
                "ranlib",
                "readelf",
                "size",
                "strings",
                "strip",
                ]

    cur = os.getcwd()
    home = os.getenv("HOME")
    for arch in arch_list:
        for item in tool_list:
            try_link(cur + "/bin/armbox", home + "/tool/bin/" + arch + "-" + item)


def setup_python():
    """ setup python """

    cur = os.getcwd()
    home = os.getenv("HOME")
    try_link(cur + "/share/python/.pylintrc", home + "/.pylintrc")


def setup_vim():
    """ setup vim """

    cur = os.getcwd()
    home = os.getenv("HOME")
    try_link(cur + "/share/vim/.vimrc", home + "/.vimrc")
    try_link(cur + "/share/vim/.vim", home + "/.vim")


def setup_git():
    """ setup git """

    cur = os.getcwd()
    home = os.getenv("HOME")
    try_link(cur + "/share/git/.gitconfig", home + "/.gitconfig")
    try_link(cur + "/share/git/.gitignore", home + "/.gitignore")


def setup_gdb():
    """ setup gdb """

    cur = os.getcwd()
    home = os.getenv("HOME")
    try_link(cur + "/share/gdb/.gdbinit", home + "/.gdbinit")
    try_link(cur + "/share/gdb/.gdbscript", home + "/.gdbscript")


def setup_all():
    """do all task.  """

    global tools

    for key, func in tools.items():
        if key != "all":
            func()


def get_choice(max_choice):
    " Get integer input from prompt. 'q' for leave "

    while True :
        try:
            choice = raw_input("Choice [q for quit] : ")
            if choice == 'q':
                choice = 0
                break
            elif choice.isalnum() and 1 <= int(choice) <= max_choice:
                break
            else:
                pass

        except ValueError:
            pass

    return int(choice)


tool_name = ["bash", "xtool", "python", "vim", "git", "gdb", "all"]
tool_callback = [setup_bash, setup_xtool, setup_python, 
                 setup_vim, setup_git, setup_gdb, setup_all]
tools = dict(zip(tool_name, tool_callback))


for idx, item in enumerate(tools.keys()):
    print "%-2d : %-10s" % (idx + 1, item)

choice = get_choice(len(tools))
if choice:
    tools[tools.keys()[choice - 1]]()
else:
    print "Do nothing"
    sys.exit(0)


