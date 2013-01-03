local isPrime = {}

local function primes(m)
   for i = #isPrime + 1, m do
      isPrime[i] = true
   end
   local primes = {}
   for i=2,m do
      if isPrime[i] then
         for k=i+i, m, i do
            if isPrime[k] then isPrime[k] = false end
         end
         table.insert(primes, i)
      end
   end
   return primes
end

local max = 0xFFFF
local sTime = os.clock()
local p = primes(max)
local eTime = os.clock() - sTime
local n = #p
print(string.format("# of Primes <= %d: %d", max, n))
print(string.format("Largest: %d", p[n]))
print(string.format("[Gen Primes] Elapsed Time: %.3f", eTime))
