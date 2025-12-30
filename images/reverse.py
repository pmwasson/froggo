def reverse_bits_2x3(n):
    result = 0
    for i in range(3):
        result <<= 2
        result |= n & 3
        n >>= 2
    return result

def print_list(data):
    columns = 8
    for index, item in enumerate(data, 1):
        if index % columns == 1:
            print(".byte ", end="")
        print(f"${item:02X}", end="")

        if index % columns == 0:
            print() # Print a newline
        else:
            print(",", end="")

def main():
    # flip pixels (2 bits at a time)
    data = [reverse_bits_2x3(x) for x in range(64)]
    print_list(data)

main()