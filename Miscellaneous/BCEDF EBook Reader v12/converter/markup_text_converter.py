import sys

b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

class Converter:
    def __init__(self,data=None):
        self.data = data

    def convert(self):
        INHEADER = True
        title = [0x00]
        author = [0x00]
        header = [[0],[0],[0]]
        self.outdata = [0xBB,0x6A,0x5F,0x42,0x43,0x45,0x44,0x46,0x52,0x44,0x52,0x3F]
        for line in self.data.splitlines():
            if INHEADER:
                word = line
                try: do = word[0]=="\\" and word[1]!="\\"
                except: do = True
                if do:
                    if ":" in word:
                        w = word[1:].split(":")
                        w[0] = w[0].lower()
                    else:
                        w = [word[1:].lower(),""]
                    if w[0]=="char":
                        try:
                            header[0]+=self.getHex(w[1])
                            header[0][0]+=1
                        except:
                            print("Error! Could not read hex value",w[1])
                            return
                    elif w[0]=="sprite":
                        try:
                            header[1]+=self.getHex(w[1])
                            header[1][0]+=1
                        except:
                            print("Error! Could not read hex value",w[1])
                            return
                    elif w[0]=="image":
                        for i in range(8):
                            if i<len(w): header[2].append(ord(w[1][i])%256)
                            else: header[2].append(0x00)
                        header[2][0]+=1
                    elif w[0]=="title":
                        title = []
                        for c in w[1]:
                            x = ord(c)
                            if x in range(256):
                                title.append(x)
                        title.append(0x00)
                    elif w[0]=="author":
                        author = []
                        for c in w[1]:
                            x = ord(c)
                            if x in range(256):
                                author.append(x)
                        author.append(0x00)
                    elif w[0]=="endheader":
                        INHEADER = False
                        [self.outdata.append(c) for c in title]
                        [self.outdata.append(c) for c in author]
                        self.outdata.append(0x00)
                        for l in header:
                            self.outdata.append(l[0])
                            for c in l[1:]:
                                self.outdata.append(c)
                        self.header = self.outdata[:]
                        self.outdata = []
                        SECL = 0xFEFF - len(self.header)
                    else:
                        print("Warning: Skipping invalid control code in header",word)
            else:
                if " " not in l:
                    line+=" "
                WN = 0
                for word in line.split():
                    try: do = word[0]=="\\" and word[1]!="\\"
                    except: do = True
                    if do:
                        try:
                            w = word[1:].split(":")
                            w[0] = w[0].lower()
                        except:
                            do = False
                    if do:
                        try:
                            if w[0]=="char":
                                self.outdata.append(0x01)
                                self.outdata.append(int(w[1])%256)
                            elif w[0]=="sprite":
                                self.outdata.append(0x02)
                                self.outdata.append(int(w[1])%256)
                            elif w[0]=="imageleft":
                                self.outdata.append(0x03)
                                self.outdata.append(int(w[1])%256)
                            elif w[0]=="imageright":
                                self.outdata.append(0x04)
                                self.outdata.append(int(w[1])%256)
                            elif w[0]=="imagecenter":
                                self.outdata.append(0x05)
                                self.outdata.append(int(w[1])%256)
                            elif w[0]=="link":
                                self.outdata.append(0x06)
                                self.outdata.append(int(w[1])%256)
                                self.outdata.append((int(w[1])//256)%256)
                            elif w[0]=="external":
                                self.outdata.append(0x07)
                                s=w[1].split(",")[0]
                                for x in range(8):
                                    if x<len(s): self.outdata.append(ord(s[x])%256)
                                    else: self.outdata.append(0x00)
                                self.outdata.append(int(w[1].split(",")[1])%256)
                                self.outdata.append((int(w[1].split(",")[1])//256)%256)
                            elif w[0]=="highlight":
                                self.outdata.append(0x08)
                                self.outdata.append(int(w[1])%256)
                            elif w[0]=="underline":
                                self.outdata.append(0x09)
                            elif w[0]=="textscale":
                                self.outdata.append(0x0A)
                                self.outdata.append(((int(w[1].split(",")[0])-1)%16)*16+((int(w[1].split(",")[1])-1)%16))
                            elif w[0]=="textcolor":
                                self.outdata.append(0x0B)
                                self.outdata.append(int(w[1])%256)
                            elif w[0]=="tab":
                                self.outdata.append(0x0C)
                                self.outdata.append(int(w[1])%256)
                            elif w[0]=="horizontal":
                                self.outdata.append(0x0D)
                            elif w[0]=="clear":
                                self.outdata.append(0x0F)
                            elif w[0]=="colors":
                                self.outdata.append(0x10)
                                self.outdata.append(int(w[1].split(",")[0])%256)
                                self.outdata.append(int(w[1].split(",")[1])%256)
                            elif w[0]=="br":
                                self.outdata.append(0x00)
                            else:
                                print("Warning: Skipping invalid control code",word)
                        except:
                            print("Error! Argument is not valid!",word)
                            return
                    else:
                        for c in word:
                            n = ord(c)
                            if n in range(256):
                                self.outdata.append(n)
                            else:
                                print("Warning: Skipping invalid character",c)
                        self.outdata.append(0x20)
                        WN+=1
                        if WN==32:
                            print("Warning: Line contains more than 32 words",line)

        data = [0]*(len(self.outdata)//SECL + 1)
        x = A = 0
        while x<len(data):
            data[x] = self.headdata+self.outdata[A:min(len(self.outdata),A+SECL)]+[0xFF]
            A+=SECL
            x+=1

        return data

    def getHex(self,word):
        o = []
        for A in range(0,len(word),2):
            o.append(int(word[A:A+2],16))
        return o

class Var_struct:
    def __init__(self,name,vt):
        self.header = [0x2A, 0x2A, 0x54, 0x49, 0x38, 0x33, 0x46, 0x2A,
                         #**TI83F*
                         0x1A, 0x0A, 0x00,
                         #signature
                         0x41, 0x70, 0x70, 0x56, 0x61, 0x72, 0x69, 0x61,
                         #comment area
                         0x62, 0x6c, 0x65, 0x20, 0x66, 0x69, 0x6c, 0x65,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x00,
                         0x00, 0x00]
                             #data size
        self.varheader = [0x0D, 0x00,
                            0x00, 0x00,
                            #length of variable in bytes
                            vt,
                            #variable type ID. 0x15 is for appvar, 0x06 is for locked prgm
                            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                            #variable name (max 8 characters)
                            0x00,
                            #version
                            0x80,
                            #flag. 80h for archived variable. 00h otherwise
                            0x00, 0x00,
                            #length of variable in bytes (copy)
                            0x00, 0x00]
                            #length of variable in bytes (another copy...)
        self.checksum = -1
        if len(name)>8:
            self.name = name[0:7]
        elif len(name)==8:
            self.name = name
        else:
            self.name = name + "\x00"*(8-len(name))

        for i in range(8):
            self.varheader[i+5]=ord(self.name[i])

    def update(self,data=[]):
        if len(data)>0xFFEC:
            print("Error: Converted data too large!")
            return
        self.header[53]=(len(data)+19)%256
        self.header[54]=(len(data)+19)//256
        dl=len(data)
        self.varheader[2]=(dl+2)%256
        self.varheader[3]=(dl+2)//256
        self.varheader[15]=(dl+2)%256
        self.varheader[16]=(dl+2)//256
        self.varheader[17]=dl%256
        self.varheader[18]=dl//256
        self.data = self.header + self.varheader + data + [0,0]
        self.checksum=sum(self.varheader)+sum(data)
        self.data[-2]=self.checksum%256
        self.data[-1]=self.checksum//256
        for i in range(len(self.data)):
            self.data[i]%=256

    def write(self,file):
        try:
            with open(file,"wb") as f:
                f.write(bytes(self.data))
            return True
        except:
            print("Something went wrong writing!")
            return False


if __name__=='__main__':
    try:
        file_name = sys.argv[1]
    except:
        file_name = input("File to convert?")
    try:
        with open(file_name,"r") as f:
            data_in = str(f.read())
    except:
        print('Error: File "'+file_name+'" does not exist!')
        exit()

##    try:
##        calc_name = sys.argv[4]
##    except:
##        calc_name = input("Name on calc?")

##    try:
##        vartype = str(sys.argv[3]).lower()
##    except:
##        vartype = input("variable type?")
##
##    try:
##        if "prot" in vartype:
##            vartype=6
##        elif "prgm" in vartype:
##            vartype=5
##        elif "appvar" in vartype or "avar" in vartype:
##            vartype=21
##        else:
##            print("""Error: invalid variable type!
##defaulting to locked program...""")
##            vartype=6
##    except:
##        pass

    converter = Converter(data_in)
    data = converter.convert()
    try:
        if len(data)==1:
            prgm_name = file_name[0:min(len(file_name),7)].upper()
        else:
            prgm_name = file_name[0:min(len(file_name),6)].upper()
        N = 0
        for line in data:
            var = Var_struct(prgm_name+b64[N],6)
            var.update(line)
            var.write(prgm_name+b64[N]+".8xp")
            N+=1
    except Exception as e:
        print(e)
##        try:
##            comp_name = sys.argv[2]
##        except:
##            comp_name = input("File name?")

