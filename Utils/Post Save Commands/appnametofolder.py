## Written by lobotomyx (github.com/elbadcode) 2024
## Distribute and modify freely, no warranty or support provided
## This is meant to be compiled to an exe and placed in the Screenshots folder or next to the ReShade.ini file
## Run as a post save command if using a global instance or use it as a static script from the terminal by passing a path as the param

import os
import sys
import time
from glob import glob
from os.path import join, exists, isdir,abspath, dirname
import re


# appreg = re.compile(r"(\w+)\W(\d+)")
# date time macro + over
appreg = r"(?:(\w+)\W((\d{4}(-\d{2}){2}\W)\d{2}(-\d{2,3}){2,3})(\.\w+|\Woverlay\.\w+|\Woriginal\.\w+|\Wbefore\.\w+))"
save_path = ""
if (wd := os.getcwd()) != dirname(__file__):
    os.chdir(dirname(__file__))
try:
    if wd.endswith("Screenshots"):
        save_path = wd
        print(save_path)
    elif isdir(_save := join(wd, "Screenshots")) and exists(join(wd, "ReShade.ini")):
        save_path = _save
    elif len(sys.argv) <= 1:
        _key = "SavePath="
        ini_path = join(os.getcwd(), "ReShade.ini")
        if os.path.exists(ini_path):
            with open(ini_path, "r") as f:
                # I'm sure there's some config library that gets me this in 1-2 lines but costs double the instructions (looking at you pathlib)
                for line in f.readlines():
                    if line.startswith(_key):
                        try_save_path = line.split("=")[1].strip()
                        if try_save_path.startswith("."):
                            try_save_path = join(
                                os.getcwd(), try_save_path.split(".\\")[1]
                            )
                            save_path = try_save_path
    elif len(sys.argv) > 1:
        if os.path.isdir(sys.argv[1]):
            save_path = sys.argv[1]
    print("save path: ", save_path)
    os.chdir(save_path)
    files = []
    for ext in ("*.jpeg", "*.png", "*.jpg", "*.ini", "*.tiff", "*.tif", "*.gif"):
        files.extend(glob(join(save_path, ext)))
    for file in os.scandir(save_path):
        print(file.name)
        matches = re.search(appreg, file.name, re.IGNORECASE)
        if matches:
            appname = matches.group(1)
            print(appname)
            appfolder = abspath(join(save_path, appname))
            if not isdir(appfolder) or not exists(appfolder):
                os.makedirs(appfolder)
            newname = matches.group(2) + matches.group(6)
            subfolder = (
                "Before"
                if "original" in file.name or "before" in file.name
                else "Overlay"
                if "overlay" in file.name
                else "After"
            )
            if subfolder:
                newpath = abspath(join(save_path,appfolder,subfolder, newname))
                print(newpath)
            try:
                os.rename(file, newpath)
                print(newpath)
            except Exception as e:
                print(e)

except Exception as e:
    print(e)
