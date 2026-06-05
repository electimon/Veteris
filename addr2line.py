import yaml, sys, os

def main():
    with open('xcbuild/Veteris_.dSYM/Contents/Resources/Relocations/arm/Veteris_.yml', 'r') as f:
        data = yaml.safe_load(f)
        relocs = data['relocations']

    parsed_in = sys.argv[1].split(" + ")
    sym_to_find = parsed_in[0]
    if sym_to_find[0:2] == "__":
        sym_to_find = f"_{sym_to_find}" # ?????????????????????????????????????????????????????????????
    offset = int(parsed_in[1])

    obj_sym_addr = 0x0

    for reloc in relocs:
        if reloc['symName'] == sym_to_find:
            print(f"Found {sym_to_find} at {hex(reloc['symBinAddr'])}")
            obj_sym_addr = reloc['symBinAddr']
            break
    else:
        print(f"Could not find {sym_to_find}")
        return

    print(f"Offset: {hex(offset)}")
    print(f"Symbol Address: {hex(obj_sym_addr)}")
    final_addr = obj_sym_addr + offset
    print(f"Final Address: {hex(final_addr)}")

    command = f"llvm-addr2line-18 -f --default-arch=armv7 --obj xcbuild/Veteris_ -a {hex(final_addr)}"
    print(f"Executing command: {command}")
    os.system(command)

main()
