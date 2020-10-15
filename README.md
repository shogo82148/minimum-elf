# minimum-elf
minimum executable docker image

Avoiding large images speeds up building and deploying containers.
Therefore, it is crucial to reduce the image size to a minimum.
So how much smaller can we reduce the image size?

This is an answer of this question. It's only 188 bytes!

```
$ docker build -t minimum-elf:latest .
$ docker images minimum-elf:latest
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
minimum-elf         latest              7616f85963e1        5 seconds ago       188B
```

Of course, `docker run` works well. It just exits with status code 0.

```
$ docker run minimum-elf:latest
```

## References

- [最小限のELF|κeenのHappy Hacκing Blog](https://keens.github.io/blog/2020/04/12/saishougennoelf/)
- [ELF Golf](http://shinh.skr.jp/binary/fsij061115/)
