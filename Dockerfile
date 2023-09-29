FROM alpine:3.18.4 as builder

RUN apk add --no-cache perl
COPY . .
RUN /usr/bin/perl asm.pl "$(uname -m)" > /elf
RUN chmod +x /elf

FROM scratch
COPY --from=builder /elf /
ENTRYPOINT [ "/elf" ]
