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


### Using the bootstrap ghc on Gentoo

1. Extract `ghc.tar.xz` on the target system such that the prefix remains
   the same
2. Add `PATH="/tmp/bootstrap_ghc/bin:${PATH}"` to `/etc/portage/env/dev-lang/ghc`
3. Emerge ghc with `USE=ghcbootstrap`
4. If the build completes successfully, remove the `PATH` setting from
   `/etc/portage/env` and use [this script][1] to build a redistibutable
   bindist

[1]: https://gist.github.com/zeldin/2c3708093e6c99102aba39cddc9fd498
