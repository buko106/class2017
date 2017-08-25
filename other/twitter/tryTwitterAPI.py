# -*- coding: utf-8 -*-
from requests_oauthlib import OAuth1Session
import requests
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
    resource = "application/rate_limit_status.json"
    resp = twitter.get(prefix+resource)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        for _,dicts in body["resources"].items():
            for k,v in dicts.items():
                print(k,"remaining =",v["remaining"])
    else:
        print(body)

def post_tweet(status,media_ids=None,media=None,in_reply_to_status_id=None):
    assert(type(status)==str)
    resource = "statuses/update.json"
    data = {"status": status}
    if media_ids is not None:
        data["media_ids"]=media_ids
    if media is not None:
        data["media"]=media
    if in_reply_to_status_id is not None:
        data["in_reply_to_status_id"] = in_reply_to_status_id
    resp = twitter.post(prefix+resource,data=data)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        print("created_at",body["created_at"])
    else:
        print(body)

def post_image(filename):
    prefix="https://upload.twitter.com/1.1/"
    resource = "media/upload.json"
    from base64 import b64encode
    media = open(filename,"rb").read()
    media64 = b64encode(media)
    data = {"media_data":media64}
    resp = twitter.post(prefix+resource,data=data)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        print("media_id_string",body["media_id_string"])
    else:
        print(json.dumps(body,indent=2))


def post_icon(filename):
    resource = "account/update_profile_image.json"
    from base64 import b64encode
    icon = open(filename,"rb").read()
    icon64 = b64encode(icon)
    data = {"image":icon64}
    resp = twitter.post(prefix+resource,data=data)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        print("created_at",body["created_at"])
    else:
        print(body)

def get_serch(query,count=100,lang="ja",max_id=None,result_type="mixed",download_media=False):
    resource = "search/tweets.json"
    params = {"q":query, "count":count, "lang":lang, "result_type":result_type }
    if max_id is not None:
        params["max_id"] = max_id
    resp = twitter.get(prefix+resource,params=params)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        for status in body["statuses"]:
            print("id =",status["id"],"created at",status["created_at"])
            print("%s@%s" % (status["user"]["name"],status["user"]["screen_name"]))
            print("url = http://twitter.com/%s/status/%d"%(status["user"]["screen_name"],status["id"]))
            print(status["text"])
            extended_entities = status.get("extended_entities")
            if extended_entities is not None:
                for media in extended_entities["media"]:
                    print("media detected ->",media["media_url"])
                    if download_media:
                        wget.download(media["media_url"],out="output")
            print("\n-----------------------------------------------------------------\n")
    else:
        print(body)

def get_user_timeline(user_id=None,screen_name=None,count=200,since_id=None,max_id=None):
    resource = "statuses/user_timeline.json"
    params = { 
        "user_id":user_id,
        "screen_name":screen_name,
        "count":count,
        "since_id":since_id,
        "max_id":max_id,
    }
    resp = twitter.get(prefix+resource,params=params)
    print("status_code =",resp.status_code)
    body = json.loads(resp.text)
    if resp.status_code == 200:
        for status in body:
            print("id =",status["id"],"created at",status["created_at"])
            print("%s@%s" % (status["user"]["name"],status["user"]["screen_name"]))
            print(status["text"])
            if status["entities"].get("media") is not None:
                for media in status["entities"]["media"]:
                    print("media detected(%s) -> %s"%(media["type"],media["media_url"]))
            # extended_entities = status.get("extended_entities")
            # if download_media and extended_entities is not None:
            #     for media in extended_entities["media"]:
            #         wget.download(media["media_url"],out="output")
            print("\n-----------------------------------------------------------------\n")
 
def get_user_stream(Delimited=None,StallWarnings=None,With=None,Replies=None,Track=None,Locations=None,StringifyFriendIds=None):
    resource = "https://userstream.twitter.com/1.1/user.json"
    # set params
    params = {}
    if Delimited is not None : params["delimited"] = Delimited
    if StallWarnings is not None : params["stall_warnings"] = StallWarnings
    if With is not None : params["with"] = With
    if Replies is not None : params["replies"] = Replies
    if Track is not None : params["track"] = Track
    if Locations is not None : params["locations"] = Locations
    if StringifyFriendIds is not None : params["stringify_friend_ids"] = StringifyFriendIds
    # request
    import requests
    from requests_oauthlib import OAuth1    
    auth = OAuth1(client_key, client_secret, resource_owner_key, resource_owner_secret)
    resp = requests.post(resource,auth=auth,stream=True,params=params)
    import datetime
    for line in resp.iter_lines():
        if not line :
            continue
        body = json.loads(line.decode("utf-8"))
        # print(json.dumps(body,indent=2))
        print("############################################################")
        if body.get("created_at"):
            print("created_at : %s"%body["created_at"])
            parsed = datetime.datetime.strptime(body.get("created_at"),"%a %b %d %H:%M:%S %z %Y")
            if body.get("timestamp_ms"):
                parsed = datetime.datetime.fromtimestamp(float(body["timestamp_ms"])/1000)
                timestr = parsed.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
                if body.get("text") and "334" in body["text"]:
                    post_tweet("@"+ body["user"]["screen_name"]+" [bot] このツイートは "+timestr+" に呟かれました．",in_reply_to_status_id=body["id"])
        if body.get("id_str") and body.get("user") and body.get("user").get("screen_name"):
            print("url : http://twitter.com/%s/status/%s"%(body["user"]["screen_name"],body["id_str"]))
        if body.get("favorited"):
            print("favorited this tweet",body["id"])
        if body.get("retweeted"):
            print("retweeted this tweet",body["id"])                
        if body.get("event"):
            print("event : %s"%body["event"])
        if body.get("user"):
            print("%s@%s"%(body["user"].get("name"),body["user"].get("screen_name")))
        if body.get("in_reply_to_screen_name"):
            print("-> @%s"%body["in_reply_to_screen_name"])
        print("------------------------------------------------------------")
        if body.get("text"):
            print(body["text"])
        # print(json.dumps(body.get("user"),indent=2))
        print("------------------------------------------------------------")
        print(body.keys())
        print("")
        # if body.get("user"):print(json.dumps(body["user"],indent=2))

        if body.get("disconnect"):
            print(json.dumps(body["disconnect"],indent=2))
            return
        
get_user_stream(With="user")
#get_user_timeline(screen_name="buko106")
#get_serch("")
#post_tweet("Twitter Rest APIを用いた，テストツイートです")
#post_image("")
#get_limits()
#post_icon("icon.png")
