# crystal-openbsd-port

## Installation:

```
cd /usr/ports/lang
git clone https://github.com/bitfliplabs/crystal-openbsd-port.git crystal
cd crystal
```

## Building:
```
make build
```

## Cleaning:

Clean Working Directory:
```
make clean
```

Clean Dependancies
```
make clean=depends
```

Clean Distribution
```
make clean=dist
```

Clean Packages:
```
make clean=packages
```

## Packaging:
```
make package
```

# Help:

- [Manual for ports](https://man.openbsd.org/ports)
- [Manual for bsd.port.mk](https://man.openbsd.org/bsd.port.mk)
- [Porters Handbook](https://www.openbsd.org/faq/ports/index.html)

