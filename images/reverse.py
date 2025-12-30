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
        # Print the item followed by a space
        print(f"${item:02X}", end="") # Adjust the width (e.g., 4) for proper alignment

        # Check if we have printed 8 items and if it's not the very last item
        if index % columns == 0:
            print() # Print a newline
        else:
            print(",", end="")

def main():
    # flip pixels (2 bits at a time)
    data = [reverse_bits_2x3(x) for x in range(64)]
    print_list(data)
    #print()
    #data = [128|reverse_bits_7(x) for x in range(128)]
    #print_list(data)

main()