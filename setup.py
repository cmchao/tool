#!/usr/bin/env python
""" setup script """
import argparse
import inspect
import os
import sys

def try_link(src, dst):
    """ link src to dst and print msg by caller name """

    caller = inspect.stack()[1][3]

    try:
        os.symlink(src, dst)
        print "[Ok]%s : link '%s' to '%s'" % (caller, src, dst)
    except OSError as exp:
        print "[Skip]%s : link '%s' to '%s' (%s)" % (caller, src, dst, exp.strerror)


def setup_bash():
    """ setup bash """

    selfname = inspect.stack()[0][3]
    cur = os.getcwd()
    home = os.getenv("HOME")

    cmd = """
if [ -e $HOME/.bashrc.private ]; then
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
        print "[ERROR]%s : can't find '.profile' or '.bashrc.private'" % (selfname)
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
                "gdb",
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

    try_link(cur + "/bin/dis", home + "/tool/bin/dis")
    try_link(cur + "/bin/config-query", home + "/tool/bin/config-query")
    try_link(cur + "/bin/xtools-setup", home + "/tool/bin/xtools-setup")

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


def setup_misc():
    """ setup misc """

    cur = os.getcwd()
    home = os.getenv("HOME")
    try_link(cur + "/bin/suspend", home + "/tool/bin/")

    config_path = home + "/.config/gtk-3.0/"
    if not os.path.exists(config_path):
        os.mkdir(config_path)

    try_link(cur + "/share/ubuntu/gtk.css", config_path)

def setup_all(tools):
    """do all task.  """

    for key, func in tools.items():
        print "setup '%s'" % (key)
        func()


def get_choice(max_choice):
    " Get integer input from prompt. 'q' for leave "

    while True:
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


def parse_argv():
    """ parse command line option """
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter,
            description=("Setup our Ubuntu working environment\n"
                         "Please execute the '%s' in this directory\n") % sys.argv[0])

    return parser.parse_args()


def run():
    """ main function """
    tool_name = ["bash", "xtool", "python", "vim", "git", "gdb", "misc"]
    tool_callback = [setup_bash, setup_xtool, setup_python,
                     setup_vim, setup_git, setup_gdb, setup_misc]
    tools = dict(zip(tool_name, tool_callback))

    for idx, item in enumerate(tools.keys()):
        print "%-2d : %-10s" % (idx + 1, item)

    print "%-2d : %-10s" % (len(tools.keys()) + 1, "all")

    choice = get_choice(len(tools) + 1)
    if choice >= 0 and choice <= len(tool_name):
        tools[tools.keys()[choice - 1]]()
    elif choice == len(tool_name) + 1:
        setup_all(tools)
    else:
        print "Do nothing"
        sys.exit(0)


if __name__ == "__main__":
    parse_argv()
    run()


