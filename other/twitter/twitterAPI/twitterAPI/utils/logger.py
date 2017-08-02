

class Logger:
    import sys
    import os
    def __init__(self,fp=sys.stdout,verbose=os.devnull):
        self.fp = fp
        self.verbose = verbose

    def log(self,*args):
        print(*args,file=self.fp)

    def log_error(self,*args):
        self.log("[ERROR]",*args)
    
    def log_info(self,*args):
        self.log("[INFO]",*args)
        
