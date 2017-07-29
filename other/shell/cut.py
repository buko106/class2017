from subprocess import getoutput
import os

def mp3cut( outfile, time, infile ):
    prog = u"mp3cut"
    command = prog + u" -o " + outfile + u" -t " + time + u" " + infile
    result = getoutput(command)
    print(result)

output = "output"
for fname in os.listdir():
    root, ext = os.path.splitext(fname)
    if ext == ".mp3":
        fname = fname.replace(" ",r"\ ")
        fname = fname.replace("(",r"\(")
        fname = fname.replace(")",r"\)")
        fname = fname.replace("&",r"\&")
        mp3cut(os.path.join(output,fname),"00:04+000-",fname)
