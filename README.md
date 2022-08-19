This is a Dockerfile for building a ghc compiler with a non-standard
prefix on a target platform of choice, in order to get a bootstrap
compiler for a native ghc build on e.g. Gentoo.

First, if your Docker host does not suport the target architecture natively,
install the appropiate qemu-user-static wrapper, example (for 32-bit ARM):

```sh
docker run --rm --privileged aptman/qus -s -- -p arm
```

Next the ghc compiler can be built for the desired target using e.g.

```sh
docker build --platform linux/arm/v7 .
```

In addition to the `--platform` argument selecting the target platform,
`--build-arg` arguments can be specified to affect the build.
Adding additional arguments to the `configure` script:

```
--build-arg extra_config=--disable-ld-override
```

Selecting a different prefix from the default `/tmp/bootstrap_ghc`:

```
--build-arg prefix=/tmp/myprefix
```

Once the build completes, copy the installed ghc out of the image like so:

```sh
docker cp $(docker create 2c5fb493f2):/tmp/bootstrap_ghc - | xz -c > ghc.tar.xz
```

where `2c5fb493f2` is the hash that `docker build` displays at the end.
