import time
_starttime = time.clock()
print "Loading modules..."
from PIL import Image
import os,sys,json

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
    

    
def list2chex(listdata):
  return ','.join('0x'+format(i,'02X') for i in listdata)+',\n\t'
    
def sls2src(infile,outpath,outfilename):
  with open(infile,"rb+") as f:
    levels = []
    for line in f.readlines():
      if (line[0] == '{'):
        line = line.replace('{','[').replace('}',']')
        data = json.loads(line)
        newdata = data[8:8*7+1]
        newdata = data[64:68] + newdata
      levels.append(newdata)
  dexport  = '#include <stdint.h>\n#include "'+outfilename+'.h"\n\n'
  dexport += '//note: fmt: x,y,dir,diff, [8*6]\n\n'
  dexport += 'uint8_t leveldata_'+outfilename+'['+str(len(levels)*len(levels[0]))+'] = {\n\t'
  for i in levels:
    dexport += list2chex(i[0:4])
    for j in range(6):
      dexport += list2chex(i[4+j*8:4+(j+1)*8])
  dexport = dexport[0:len(dexport)-1]
  dexport += '};\n\n'
  with open(np(outpath+'/'+outfilename+'.c'),'wb') as f:
    f.write(dexport)
  with open(np(outpath+'/'+outfilename+'.h'),'wb') as f:
    hexport = '#ifndef '+outfilename.upper()+'_H\n#define '+outfilename.upper()+'_H\n\n'
    hexport += '#include <stdint.h>\n\n'
    hexport += '#define '+outfilename+'_numlevels '+str(len(levels))+'\n'
    hexport += 'extern uint8_t leveldata_'+outfilename+'['+str(len(levels)*len(levels[0]))+'];\n'
    hexport += '\n#endif'
    f.write(hexport)
    
  pass
  
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#
# Input format for each line:
# [64 bytes in 8x8 grid] [frogx] [frogy] [direction] [difficulty]

sls2src("editor/LevelSetModified.sls","../src/","base_set")
sls2src("editor/LevelSetPlus.sls","../src/","extend_set")


















