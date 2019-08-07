aliasfn @testfun, "testfun!"
n = 5
x! = testfun!(n)
print x!
end

testfun:
asm "
    pla
    pla
    clc
    adc #$02
    pha
    jmp ($02fe)
"