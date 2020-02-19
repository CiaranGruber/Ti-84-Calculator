import time
_starttime = time.clock()
print "Loading modules..."
from PIL import Image
import os,sys,ctypes

np = os.path.normpath
se = os.path.splitext
bn = os.path.basename
cd = os.getcwd()

curptr = 0xC000
outarr = []

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

def ensure_dir(d):
  if not os.path.isdir(d):
    os.makedirs(d)
  return
    
def readFile(file):
  a = []
  f = open(file,'rb')
  b = f.read(1)
  while b!=b'':
    a.append(ord(b))
    b = f.read(1)
  f.close()
  return a
        
def writeFile(file,a):
  f = open(file,'wb+')
  f.write(bytearray(a))
  f.close()
        
def appendFile(file,a):
  f = open(file,'ab')
  f.write(bytearray(a))
  f.close()
        
def silentremove(file):
  try:
    os.remove(file)
  except:
    pass
    
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  
def rgb2xlc(rgb):
  # G5:7 to 0:2   ;   B6:7 to 3:4   ;   R5:7 to 5:7
  a = (rgb[1]>>5)&0b00000111
  a = a | ((rgb[2]>>3)&0b00011000)
  a = a | (rgb[0]&0b11100000)
  return a
  
def img2cse(infile):
  f = Image.open(np(infile))
  i = list(f.convert("RGB").getdata()) if (f.mode != "RGB") else list(f.getdata())
  o = []
  w = f.size[0]
  h = f.size[1]
  for y in range(h):
    for x in range(w):
      o.append(rgb2xlc(i[(y*w)+x]))
  return (w,h,o)
  
def img2bw(infile):
  f = Image.open(np(infile))
  fc = f.convert('1',dither=Image.NONE)
  fd = fc.tobytes()
  fd = [ord(i) for i in fd]
  w = f.size[0]
  h = f.size[1]
  return (w,h,fd)
    
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
img = img2bw("pf_tempestra_seven_condensed_modified.png")

imgarr = []
tmparr = []
for idx,i in enumerate(img[2]):
  tmparr.append(i)
  if (idx%8)==7:
    imgarr.append(tmparr)
    tmparr = []
data = ""
with open("../src/font.c","wb+") as f:
  data += "#include <stdint.h>\n#include \"font.h\"\n\n"
  data += "uint8_t font_data["+str(len(img[2]))+"] = {\n\t"
  
  for idx,i in enumerate(imgarr):
    data += ','.join("0x"+format(~a&0xFF,"02X") for a in i)
    data += ", // Char 0x"+format(idx+32,"02X")+"("+chr(idx+32)+")\n\t"
  data = data[:len(data)-1]
  data += "};\n\n"
  
  data += "uint8_t font_spacing["+str(len(imgarr))+"] = {\n\t"
  for idx,i in enumerate(imgarr):
    widest = 0
    for j in i:
      j = ~j&0xFF
      tempwidth = 9
      for k in range(8):
        if (j&1)==1:
          break
        else:
          tempwidth-=1
        j = j>>1
      if tempwidth>widest:
        widest = tempwidth
    if widest == 1: widest = 2
    data += "0x"+format(widest,"02X")
    data += ", // Char 0x"+format(idx+32,"02X")+"("+chr(idx+32)+")\n\t"
  data = data[:len(data)-1]
  data += "};\n\n"
  
  
  f.write(data)
  
with open("../src/font.h","wb+") as f:
  f.write("#ifndef FONT_H\n#define FONT_H\n\n"+
    "#include <stdint.h>\n\n"+
    "extern uint8_t font_data["+str(len(img[2]))+"];\n"+
    "extern uint8_t font_spacing["+str(len(imgarr))+"];\n"+
    "\n#endif")
  
  
  
  
  
  
  



