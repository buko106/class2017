
class KeyReader:
    def __init__(self,logger):
        self.logger = logger
    
    def read(self,key_file_path):
        try:
            keys = open(key_file_path,"r").read().split("\n")
        except:
            self.logger.log_error("Could not open key file : %s" % key_file_path)
            raise
        
        retval = {}
        try:
            retval["client_key"]            = keys[0]
            retval["client_secret"]         = keys[1]
            retval["resource_owner_key"]    = keys[2]
            retval["resource_owner_secret"] = keys[3]
        except:
            self.logger.log_error("Key file must composed of 4 lines(CONSUMER_KEY, CONSUMER_SECRET, ACCESS_TOKEN and ACCESS_TOKEN_SECRET in this order)")
            raise
    
        self.logger.log_info("API Keys correctly loaded")
        return retval
