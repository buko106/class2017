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
    data = {"status": tweet}
    resp = twitter.post(prefix+resouce,data=data)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        print("created_at",body["created_at"])
    else:
        print(body)

def post_icon(filename):
    resouce = "account/update_profile_image.json"
    from base64 import b64encode
    icon = open(filename,"rb").read()
    icon64 = b64encode(icon)
    data = {"image":icon64}
    resp = twitter.post(prefix+resouce,data=data)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        print("created_at",body["created_at"])
    else:
        print(body)

def get_serch(query,count=100,lang="ja",max_id=None,result_type="mixed"):
    resouce = "search/tweets.json"
    max_id = "891249416937406464"
    params = {"q":query, "count":count, "lang":lang, "result_type":result_type }
    if max_id is not None:
        params["max_id"] = max_id
    resp = twitter.get(prefix+resouce,params=params)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        for status in body["statuses"]:
            print("id =",status["id"],"created at",status["created_at"])
            print("%s@%s" % (status["user"]["name"],status["user"]["screen_name"]))
            print(status["text"])
            print("")
            extended_entities = status.get("extended_entities")
            if extended_entities is not None:
                for media in extended_entities["media"]:
                    wget.download(media["media_url"],out="output")
    else:
        print(body)


#get_serch("")
#post_tweet("あああ")
# get_limits()
#post_icon("result.png")
