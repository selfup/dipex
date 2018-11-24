# Dipex

Dipole Antenna Elixir Project! :radio:

## Purpose

- Listen to a Flex Radio TCP stream
- Parse VITA49
- Based on antenna/frequency turn on/off relay switch via Raspberry Pi GPIO
- Relay switch dictate dipole mode on antenna

This is for my Dad :pray:

We are both HAM radio operators :tada:

## On Boot

#### ENV vars

1. `FLEX_IP` known IP address of the Flex Radio
1. `FLEX_RPI` if the server is running on a RPI with GPIO

- You do not need to define the FLEX_RPI var but you can set it to 0 or 1.
- 1 being that GPIO is on the system and the wiringPi `gpio` CLI is available for use.
- 0 means no, and not defining it means no as well.

Example use on a rpi:

`FLEX_IP=10.0.0.192 FLEX_RPI=1 mix run --no-halt`

#### GPIO

- Unexports all pins
- Exports mode out for BCM pin 17

#### TCP

- Opens TCP `:gen_tcp` connection to flex
- Send a recieve all msg to flex with `:gen_tcp` (need to CLRF msg string)
- Recursive loop recv with `:gen_tcp`

#### Parsing

- Parses recv msg to check for antenna and frequencies
- Based on antenna/frequency turn on/off relay switch via Raspberry Pi GPIO

Forever!

## API

If running on `10.0.0.230`

```elixir
curl 10.230:4000/api/?cmd=on
curl 10.230:4000/api/?cmd=off
curl 10.230:4000/api/?cmd=unexport
curl 10.230:4000/api/?cmd=export
```
