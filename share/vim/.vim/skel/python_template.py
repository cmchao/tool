#!/usr/bin/env python
# -*- coding: utf-8 -*-
""" empty comment """
import traceback

def run():
    """ main fucntion """
    pass


if __name__ == "__main__":
    try:
        run()
    except SystemExit as exp:
        if exp.code == 0:
            raise
        else:
            print traceback.print_exc(exp)
    except Exception as exp:
        print traceback.print_exc(exp)
