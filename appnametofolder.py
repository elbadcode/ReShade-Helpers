## Written by lobotomyx (github.com/elbadcode) 2024
## Distribute and modify freely, no warranty or support provided
## This is meant to be compiled to an exe and placed in the Screenshots folder or next to the ReShade.ini file
## Run as a post save command if using a global instance or use it as a static script from the terminal by passing a path as the param

import os
import sys
import time
from glob import glob
from os.path import join
import re


#appreg = re.compile(r"(\w+)\W(\d+)")
appreg = r"(?:(\w+)\W((\d{4}(-\d{2}){2}\W)\d{2}(-\d{2}){2})(\.\w+|\Woverlay\.\w+|\Woriginal\.\w+))"
save_path = ''
if os.getcwd().endswith('Screenshots'):
    save_path = os.getcwd()
    print(save_path)
elif len(sys.argv) <= 1:
    _key = 'SavePath='
    ini_path = os.path.join(os.getcwd(), 'ReShade.ini')
    if os.path.exists(ini_path):
        with open(ini_path, "r") as f:
            for line in f.readlines():
                if line.startswith(_key):
                    try_save_path = line.split('=')[1].strip()
                    if try_save_path.startswith('.'):
                        try_save_path = os.path.join(os.getcwd(), try_save_path.split('.\\')[1])
                        save_path = try_save_path
elif os.path.isdir(sys.argv[1]):
    save_path = sys.argv[1]
print(save_path)
os.chdir(save_path)
files = []
for ext in ('*.jpeg', '*.png', '*.jpg','*.ini'):
    files.extend(glob(join(save_path, ext)))
for file in os.listdir(save_path):
    matches = re.search(appreg,file, re.IGNORECASE)
    if matches:
        appname = matches.group(1)
        appfolder = os.path.join(save_path, appname)
        newname = matches.group(2) + matches.group(6)
        newpath = os.path.join(appfolder, newname)
        try:
            if not os.path.isdir(appfolder):
                os.makedirs(appfolder)
                print(os.path.abspath(appfolder))
            os.rename(file, newpath)
            print(newpath)
        except Exception as e:
            print(e)


