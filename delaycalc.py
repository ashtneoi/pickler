#!/usr/bin/env python3


from sys import argv, stderr, stdout


outer_code = """\
delay?_?:
            movwf U7
_7:{ins}\
{w}\
            decfsz U7
              *bra _7
            return
"""


middle_code = """\
         movlw {ci}
            movwf U{u}
_{u}:{ins}\
            decfsz U{u}
              *bra _{u}
"""


inner_code = """\
         movlw {c1}
_w:\
         decfsz WREG
              *bra _w
"""


def gen_code(c, w):
    cr = list(reversed(c))
    def middle(c, u):
        if len(c) > 1:
            return middle_code.format(
                ci=c[0],
                u=u,
                ins=middle(c[1:], u - 1),
            )
        else:
            return inner_code.format(c1=c[0])

    return outer_code.format(
        ins=middle(c, 6),
        w=("            nop\n" * w),
    )


def main(Fcy, Td, depth):
    Tcy = 1 / Fcy
    nT = Td / Tcy
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
        if (bn < n <= nT):
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

    w = round(nT - bn)
    if w > 10:
        stderr.write("Error: {} nops is too many\n".format(w))
        exit(1)

    stdout.write((
        "; target: {} cyc ({} s)\n"
        "; actual: {} cyc ({} s)\n"
        "; c = {}, w = {}\n"
    ).format(nT, Td, round(nT), Tcy * round(nT), bc, w))
    stdout.write(gen_code(bc, w))



if __name__ == '__main__':
    main(Fcy=float(argv[1]), Td=float(argv[2]), depth=int(argv[3]))
