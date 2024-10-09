import os
from datetime import datetime

rootdir = input("enter shaders path:\n")
shaderlist = []
shaderlist2 = []
fxcount = 0
fxhcount = 0
logfile = os.path.join(rootdir, "shadercount.txt")
index = 0
with open(logfile, "w") as logfile:
    for root, dirs, files in os.walk(rootdir):
        for file in files:
            if file.endswith(".fx") or file.endswith(".fxh"):
                filepath = os.path.abspath(os.path.join(root, file))
                filename, file_extension = os.path.splitext(file)
                print(filepath)
                shaderlist.append(f"{index}, {filename}, {filepath}")
                index += 1
                if file_extension == ".fx":
                    fxcount += 1
                elif file_extension == ".fxh":
                    fxhcount += 1

        print(f"fxcount: {fxcount}, fxhcount: {fxhcount}")

    for i in shaderlist:
        dupecount = 0
        try:
            for j in shaderlist:
                j_index, j_name, j_path = str(j).split(", ")
                i_index, i_name, i_path = str(i).split(", ")
                if j_name == i_name and j_path != i_path:
                    dupecount += 1
                    print(f"{i_name} {j}")
                    j_path2 = str(j_path) + ".bak"
                    os.rename(j_path, j_path2)
                    shaderlist.remove(j)
            print(i, file=logfile)
            print(f"dupecount: {dupecount}", file=logfile)
            print(i)
            print(f"fxcount: {fxcount}, fxhcount: {fxhcount}")
        except TypeError:
            pass
    print(f"fxcount: {fxcount}, fxhcount: {fxhcount}", file=logfile)
    print(shaderlist, file=logfile)
