#!/usr/bin/env python3


from sys import argv


def main(Fcy, Td, depth):
    Tcy = 1 / Fcy
    nT = Td / Tcy - 7
    print("Target cycle count = {}".format(nT))
    c = []
    c = [1] * depth
    bn = -1
    bc = [-1] * depth
    done = False
    while not done:
        inc = 0
        n = 3 * c[0]
        for i in range(1, depth):
            n = (n + 3) * c[i] + 1
        n += 3
        if bn < n < nT:
            bn = n
            bc = c[:]
        while True:
            c[inc] += 1
            if c[inc] <= 255 and n <= nT:
                break
            n = 0
            c[inc] = 1
            inc += 1
            if inc >= depth:
                done = True
                break

    print(bn)
    print(bc)


if __name__ == '__main__':
    main(Fcy=float(argv[1]), Td=float(argv[2]), depth=int(argv[3]))
