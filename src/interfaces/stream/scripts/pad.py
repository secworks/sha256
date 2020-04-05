import os
import shutil
import struct
import sys

out_filename = sys.argv[1]+".padded"
shutil.copyfile(sys.argv[1], out_filename)
with open(out_filename,'ab') as f:
    f.seek(0, os.SEEK_END)
    size = f.tell()
    print(size)
    #Add padding word to end of file
    f.write(bytearray([0x80]))

    #Calculate number of padding zeroes
    # = File size rounded up to next 512-byte block
    # minues space for padding start byte (0x80)
    # and 64-bit (8 byte) length word
    zeroes = 64 - (size % 64) - 1 - 8
    if zeroes < 0:
        zeroes += 64
    
    print(zeroes)
    f.write(bytearray([0]*zeroes))
    #sizeword = (size % 64)*8
    #if sizeword == 0:
    #    sizeword = 64*8
    sizeword = size*8
    f.write(struct.pack('>Q', sizeword))

