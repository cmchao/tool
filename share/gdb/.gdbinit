python
import sys
import os
script_path = os.getenv('HOME') + '/.gdbscript/python'
sys.path.insert(0, script_path)
from libstdcxx.v6.printers import register_libstdcxx_printers
# 5.2.0 script can't work with 4.8.4 gcc
#register_libstdcxx_printers (None)
end

