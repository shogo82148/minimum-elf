FROM alpine:3.12 as builder

RUN apk add --no-cache nasm
COPY elf.asm /
RUN /usr/bin/nasm -o /elf /elf.asm
RUN chmod +x /elf

FROM scratch
COPY --from=builder /elf /
ENTRYPOINT [ "/elf" ]
