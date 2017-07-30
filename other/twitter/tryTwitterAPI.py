# -*- coding: utf-8 -*-
from requests_oauthlib import OAuth1Session
from argparse import ArgumentParser
import json
import wget
import os

description="try Twitter API"
parser = ArgumentParser(description=description)
parser.add_argument("keys",type=str,help="API Key file composed of 4 lines(CONSUMER_KEY, CONSUMER_SECRET, ACCESS_TOKEN and ACCESS_TOKEN_SECRET in this order).")
args = parser.parse_args()

def read_key_file( filename ):
    with open(filename,"r") as f:
        lines = f.read().split("\n")
        assert( len(lines) >= 4 )
        return [ lines[i] for i in range(4) ]
            

client_key, client_secret, resource_owner_key, resource_owner_secret = read_key_file(args.keys)
twitter = OAuth1Session(client_key,
                        client_secret=client_secret,
                        resource_owner_key=resource_owner_key,
                        resource_owner_secret=resource_owner_secret)
prefix = "https://api.twitter.com/1.1/"

def get_limits():
    resouce = "application/rate_limit_status.json"
    resp = twitter.get(prefix+resouce)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    for _,dicts in body["resources"].items():
        for k,v in dicts.items():
            print(k,"remaining =",v["remaining"])

def post_tweet(tweet):
    assert(type(tweet)==str)
    resouce = "statuses/update.json"
    params = {"status": tweet}
    resp = twitter.post(prefix+resouce,params=params)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        print("created_at",body["created_at"])
    else:
        print(body)

def get_serch():
    resouce = "search/tweets.json"
    params = {"q":"スペイベ", "lang":"ja", "count":100 }
    resp = twitter.get(prefix+resouce,params=params)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        for status in body["statuses"]:
            print("created at",status["created_at"])
            print("%s@%s" % (status["user"]["name"],status["user"]["screen_name"]))
            print(status["text"])
            print("")
            extended_entities = status.get("extended_entities")
            if extended_entities is not None:
                for media in extended_entities["media"]:
                    wget.download(media["media_url"],out="output")
    else:
        print(body)

# get_serch()
# post_tweet("test4")
get_limits()
