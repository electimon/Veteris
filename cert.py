def convert_cert_to_header(cert_file, header_file, var_name):
    with open(cert_file, 'r') as cert:
        cert_content = cert.read()

    # Escape special characters and remove newlines
    escaped_cert = cert_content.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n")

    # Add null terminator
    escaped_cert += "\\0"

    # Generate the header content
    header_content = f"""\
#ifndef {var_name.upper()}_H
#define {var_name.upper()}_H

static char *{var_name} = "{escaped_cert}";

#endif // {var_name.upper()}_H
"""

    with open(header_file, 'w') as header:
        header.write(header_content)

    print(f"Header file '{header_file}' created successfully.")

# Usage
convert_cert_to_header('cert.crt', 'cert_header.h', 'cert_content')
