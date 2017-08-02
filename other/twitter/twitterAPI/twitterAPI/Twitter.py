
from .utils.keyReader import KeyReader
from .utils.logger import Logger

class Twitter:
    def __init__(self):
        self.client_key = ""
        self.client_secret = ""
        self.resource_owner_key = ""
        self.resource_owner_secret = ""
        self.logger = Logger()
        self.reader = KeyReader(self.logger)

    def readKeys(self,key_file_path):
        keys = self.reader.read(key_file_path)
        self.client_key            = keys["client_key"]
        self.client_secret         = keys["client_secret"]
        self.resource_owner_key    = keys["resource_owner_key"]
        self.resource_owner_secret = keys["resource_owner_secret"]
