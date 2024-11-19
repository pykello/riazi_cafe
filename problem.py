import glob
import os
import shutil

ids = list(filter(lambda x: x.split('/')[-1].isnumeric(),glob.glob("booklet/*"))) 

mp = {}

def five(s):
    while len(s) < 5:
        s = '0' + s
    return s

for id in ids:
    number = id.split('/')[-1]
    pics = list(glob.glob(id+'/figs/*'))
    for pic in pics:
        name = pic.split('/')[-1]
        dst = f'static/images/problems/{name}'
        # shutil.copyfile(pic, dst)
        mp[pic[len('booklet/'):]] = dst[len('static'):]
    text = ""
    for name in ['problem.tex', 'hint.tex', 'solution.tex']:
        try:
            with open(id+'/'+name) as f:
                text += f.read() + '\n'
        except:
            pass
        for key in mp:
            text = text.replace(key, mp[key])
        with open(f'content/en/problems/twitter/{five(number)}.tex', 'w') as f:
            f.write(text)
        

        
        
