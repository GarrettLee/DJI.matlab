function y =  getIntFromByte(b1, b2, b3)
if b1 == 255
        chara = -1;
else 
    chara = 1;
end
y = (b2 + b3 * 2^8)*chara;
end