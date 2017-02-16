
input = open('raw3.txt','r')
raw = input.read()
output = open('bin.dat','w+')
for i in range(len(raw)/2):
    print chr(int(raw[2*i:2*i+2],16))
    output.write(chr(int(raw[2*i:2*i+2],16)))

