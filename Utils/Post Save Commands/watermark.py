import math
import os
import sys, psutil
from PIL import Image
import b64png


def paste_wm(imgpath, imname, img1, img2, show_after):
    ss_height = img1.size[1]
    ss_width = img1.size[0]
    img2 = img2.resize((ss_width, ss_height))
    img1.paste(img2, (0, 0), img2)
    os.chdir(imgpath)
    img1.save(imname)
    if show_after:
        img1.show()
    img1.close()


def check_screenshots():
    ss = os.path.join(os.path.dirname(sys.argv[0]), "Screenshots")
    img2 = b64png.get_image_data("genshin")
    for f in os.scandir(ss):
        if not f.name.endswith((".jpg", ".jpeg", ".png", ".tga")):
            return
        img1 = Image.open(f.path)
        if f.name.endswith(("jpeg", "jpg")):
            img1.putalpha(1)
        if "genshin" in f.name.lower():
            img2 = b64png.get_image_data("genshin")
        elif "client" in f.name.lower():
            img2 = b64png.get_image_data("wuwa")
        elif "zenless" in f.name.lower():
            img2 = b64png.get_image_data("zenless")
        try:
            if img2:
                paste_wm(
                    os.path.abspath(os.path.dirname(f.path)),
                    f.name,
                    img1,
                    img2,
                    show_after=False,
                )
        except Exception as e:
            print(e)


show_after = False


def main():
    # main
    target = ""
    mark = ""
    extra = ""
    game = ""
    img1 = None
    img2 = None
    show_after = False
    if len(sys.argv) > 1:
        for arg in sys.argv[1:]:
            if arg in ["show", "view", "--v", "v"]:
                show_after = True
            elif arg.endswith((".jpg", ".jpeg", ".png", ".tga", ".tiff")):
                img1 = Image.open(arg)
                if arg.endswith(("jpeg", "jpg")):
                    target = arg
                    img1 = Image.open(target)
                    img1.putalpha(1)
                if "genshin" in arg.lower():
                    img2 = b64png.get_image_data("genshin")
                elif "client" in arg.lower():
                    img2 = b64png.get_image_data("wuwa")
                elif "zenless" in arg.lower():
                    img2 = b64png.get_image_data("zenless")
                if img2 != "":
                    paste_wm(
                        os.path.abspath(os.path.dirname(arg)),
                        os.path.basename(arg),
                        img1,
                        img2,
                        show_after,
                    )
        if img2 == "":
            for proc in psutil.process_iter():
                try:
                    if "genshin" in proc.name().lower():
                        img2 = b64png.get_image_data("genshin")
                    elif "client" in proc.name().lower():
                        img2 = b64png.get_image_data("wuwa")
                    elif "zenless" in proc.name().lower():
                        img2 = b64png.get_image_data("zenless")
                except (
                    psutil.NoSuchProcess,
                    psutil.AccessDenied,
                    psutil.ZombieProcess,
                ):
                    pass

    else:
        check_screenshots()


main()
