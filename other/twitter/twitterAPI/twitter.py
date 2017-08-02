from argparse import ArgumentParser
from twitterAPI.Twitter import Twitter

if __name__ == "__main__":
    parser = ArgumentParser(description="")
    parser.add_argument("-k","--keys",type=str,required=True)
    parser.add_argument("-c","--command",type=str,default="tweet")
    args = parser.parse_args()
    
    twitter = Twitter()
    twitter.readKeys(args.keys)
