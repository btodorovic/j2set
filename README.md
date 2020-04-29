# j2set - Junos BRACE-to-SET Format Converter

## Overview
This is a collection of scripts used to convert Junos OS "brace" configuration into "set" format.
Useful when converting snippets from Junos OS Documentation into set-commands.
Two scripts are given - Perl and Python.

**LICENSE** - Released under [GPL 3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)

**ADDITIONAL DISCLAIMER** - Those scripts are not 100% error-free and they possibly don't cover all corner cases.
But most of the configurations I worked with ended up in correct translations.
Use with extreme care!

## Usage
Two scripts are provided - Python and Perl. Both are equivalent to each other and provide the same
result. Well, in most test cases at least ...

Both are used in the same fashion:

<pre>
$ ./j2set.pl juniper.conf
$ ./j2set.py juniper.conf
</pre>

If no configuration file is specified, the configuration is read from stdin.

## About Junos Configuration Formats
Junos OS CLI allows the user to configure the router using several configuration methods:

**Brace-style** - probably inspired by the Unix Gateway Daemon (GateD) - originally developed by
Scott Brim and Jeff Honig from Cornell University, later on maintained by Merit, GateD was the
very first implementation of various routing protocols (RIP, OSPF, EGP and later on BGP) on
Unix OS'ems. GateD used C-language style braces ({, }) to delimit syntax blocks, which is the
same in Junos, which later on led to [YANG / RFC7950](https://tools.ietf.org/html/rfc7950).
The router stores its configuration in this format and we document configuration snippets also
in this format. This is primarily a machine-readable format, but it's also human-friendly.
Example:
<pre>
interfaces {
    ge-0/0/0 {
        unit 0 {
            family inet6 {
                address 2001:db8:cafe:0f:600d:f00d::1/64;
            }
        }
    }
}
</pre>

**SET-style** - intuitive, human-friendly way to manipulate router configurations. It's designed
for manual operations on the router configuration, example:
<pre>
set interfaces ge-0/0/0 unit 0 family inet6 address 2001:db8:cafe:0f:600d:f00d::1/64
</pre>

**XML** - format used primarily for machine-to-machine communication (e.g. scripting) - e.g.:
<pre>
<rpc-reply xmlns:junos="http://xml.juniper.net/junos/18.4R2/junos">
    <configuration junos:changed-seconds="1588149577" junos:changed-localtime="2020-04-29 10:39:37 CEST">
            <interfaces>
                <interface>
                    <name>ge-0/0/0</name>
                    <unit>
                        <name>0</name>
                        <family>
                            <inet6>
                                <address>
                                    <name>2001:db8:cafe:0f:600d:f00d::1/64</name>
                                </address>
                            </inet6>
                        </family>
                    </unit>
                </interface>
            </interfaces>
    </configuration>
    <cli>
        <banner>[edit]</banner>
    </cli>
</rpc-reply>
</pre>

**JSON** - also a good one, used also primarily for M2M:

<pre>
{
    "configuration" : {
        "@" : {
            "junos:changed-seconds" : "1588149577",
            "junos:changed-localtime" : "2020-04-29 10:39:37 CEST"
        },
        "interfaces" : {
            "interface" : [
            {
                "name" : "ge-0/0/0",
                "unit" : [
                {
                    "name" : 0,
                    "family" : {
                        "inet6" : {
                            "address" : [
                            {
                                "name" : "2001:db8:cafe:0f:600d:f00d::1/64"
                            }
                            ]
                        }
                    }
                }
                ]
            }
            ]
        }
    }
}
</pre>

Those scripts convert **BRACE** into **SET** format.

