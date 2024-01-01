#base is in MHz
start_freq = 1
end_freq = 12
dfreq = 0.05

start_freq += dfreq/2
float_base = 10**int(str(dfreq/2)[::-1].find('.'))
code = 0

for i in [x/float_base for x in range(int(float_base*start_freq),int(float_base*end_freq),int(float_base*dfreq))]:
    if i != end_freq-dfreq/2:
        print(str([i,0]) + ",")
    else:
        print(str([i,0]))