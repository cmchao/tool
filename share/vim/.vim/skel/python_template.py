#!/usr/bin/env python
# -*- coding: utf-8 -*-
import traceback

def run():
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
