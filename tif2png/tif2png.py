import sys
import os
from libtiff import TIFF
import png
from datetime import datetime

class ColorMapper:
    def __init__(self, minval, maxval, colors, transparent=[1,1,1], overflow=[0,0,0]):
        self.min = minval
        self.max = maxval
        self.colors = colors
        self.len = len(colors) - 1
        self.range = [minval, maxval]
        self.interval = (maxval - minval) / self.len
        self.transparent = transparent
        self.overflow = overflow

        self.steps = []
        for i in range(self.len):
            self.steps.append(minval + self.interval*i)
        self.steps.append(maxval)

    def colormap(self, value):
        if value <= self.min:
            return self.transparent
        if value > self.max:
            return self.overflow
        if value == self.max:
            return self.colors[self.len]
        index = int((value - self.min) / self.interval)
        val = value - (self.min + self.interval * index)

        r = self.cmap(val, self.colors[index][0], self.colors[index+1][0])
        g = self.cmap(val, self.colors[index][1], self.colors[index+1][1])
        b = self.cmap(val, self.colors[index][2], self.colors[index+1][2])
        return [r, g, b]

    def cmap(self, val, minc, maxc):
        return int(val * (maxc - minc) / self.interval + minc)

def tif2png(mapper, tiffile):
    fullpath = os.path.abspath(tiffile)
    dirname = os.path.dirname(fullpath)
    name, ext = os.path.splitext(tiffile)
    pngfile = os.path.join(dirname, name + '.png')

    tif = TIFF.open(tiffile, mode='r')
    for image in tif.iter_images():
        matrix = image

    shape = matrix.shape
    img = []
    for i in range(shape[0]):
        row = []
        for j in range(shape[1]):
            v = matrix[i, j]
            p = mapper.colormap(v)
            row = row + p
        img.append(row)

    f = open(pngfile, 'wb')
    w = png.Writer(shape[0], shape[1], transparent=mapper.transparent)
    w.write(f, img)
    f.close()

def main(argv):
    minval = 0.01
    maxval = 10

    red = [255, 0, 0]
    orangered = [255, 69, 0]
    yellow = [255, 255, 0]
    green = [0, 128, 0]
    dodgerblue = [30, 144, 255]
    darkblue = [0, 0, 139]
    indigo = [75, 0, 130]
    colors = [red, orangered, yellow, green, dodgerblue, darkblue, indigo]

    mapper = ColorMapper(minval, maxval, colors)

    tiffiles = []
    arg = argv[0]
    if os.path.isfile(arg):
        tiffiles.append(arg)
    elif os.path.isdir(arg):
        for n in os.listdir(arg):
            name, ext = os.path.splitext(n)
            f = os.path.join(arg, n)
            if os.path.isfile(f) and ext == '.tif':
                tiffiles.append(f)

    for tiffile in tiffiles:
        tif2png(mapper, tiffile)

if __name__ == "__main__":
    start=datetime.now()
    main(sys.argv[1:])
    print(datetime.now()-start)
