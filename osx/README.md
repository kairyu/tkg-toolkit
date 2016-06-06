# OSX Readme

## Dependencies

- libusb-compat:

    ❯ brew install libusb-compat

## Reflashing

    ❯ cd <repo_dir>/osx
    ❯ ./setup.sh
    ❯ PATH=$PATH:$(pwd)/bin

To flash firmware:

    ❯ ./reflash.sh
    
To flash keymap:
    
    ❯ ./reflash.sh ./keymap.eep  # point to your .eep keymap file
