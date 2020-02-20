import sys

b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

class Converter:
    def __init__(self,data=None):
        self.data = data

    def convert(self,title,author):
        self.outdata = [0xBB,0x6A,0x5F,0x42,0x43,0x45,0x44,0x46,0x52,0x44,0x52,0x3F]
        self.append_word(title)
        self.outdata.append(0x00)

        self.append_word(author)
        self.outdata.append(0x00)
        self.outdata.append(0x00)

        self.outdata.append(0x00)
        self.outdata.append(0x00)
        self.outdata.append(0x00)

        self.headdata = self.outdata[:]
        SECL = 0xFEFF - len(self.headdata)
        self.outdata = []
        for line in self.data.splitlines():
            if " " not in line:
                line+=" "
            WN = 0
            for word in line.split():
                self.append_word(word)
                self.outdata.append(0x20)
                WN+=1
                if WN==32:
                    print("Warning: Line contains more than 32 words",line)

            self.outdata[-1] = 0x00

        data = [0]*(len(self.outdata)//SECL + 1)
        x = A = 0
        while x<len(data):
            data[x] = self.headdata+self.outdata[A:min(len(self.outdata),A+SECL)]+[0xFF]
            A+=SECL
            x+=1

        return data

    def append_word(self,word):
        for c in word:
            n = ord(c)
            if n in range(256):
                self.outdata.append(n)
            else:
                print("Warning: Skipping invalid character",c)

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
    data = converter.convert(input("Title?"),input("Author?"))
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
