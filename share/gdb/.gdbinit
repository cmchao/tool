python
import sys
import os
script_path = os.getenv('HOME') + '/.gdbscript/python'
sys.path.insert(0, script_path)
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers (None)
end

