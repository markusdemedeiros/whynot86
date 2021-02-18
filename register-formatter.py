def format(data):
    strdat = (bin(data))[2:].rjust(64, '0')
    strdat = (' '.join([strdat[i:i+8] for i in range(0, len(strdat), 8)]))
    print(strdat)

dat = [ 0x0000000100000000
        , 0x0000000380000000
        , 0x0000000DE0000000
        , 0x0000001910000000
        , 0x00000037B8000000
        , 0x0000006424000000
        , 0x000000DE7E000000
        , 0x00000191C1000000
        , 0x0000037B23800000
        , 0x00000642F6400000 ]

for i in dat:
    format(i)
