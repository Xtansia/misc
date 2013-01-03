local function de_bruijn(alphabetSize, wordLength)
    local a = {}
    for i = 0, alphabetSize * wordLength -1 do
        a[i] = 0
    end
    local sequence = {}
    local function db( t, p )
        if t > wordLength then
            if wordLength % p == 0 then
                for j = 1, p do
                    table.insert(sequence, a[j])
                end
            end
        else
            a[t] = a[t - p]
            db(t + 1, p)
            for j = a[t - p] + 1, alphabetSize - 1 do
                a[t] = j
                db(t + 1, t)
            end
        end
    end
    db(1, 1)
    return sequence
end

local ALPHABET_SIZE = 2
local WORD_LENGTH = 4

local sequence = de_bruijn(ALPHABET_SIZE, WORD_LENGTH)
print(string.format("DeBruijn sequence for alphabet size %d, with word length %d", ALPHABET_SIZE, WORD_LENGTH))
print(table.concat(sequence))