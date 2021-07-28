const AuthDebotContract = {
    abi: {
        "ABI version": 2,
        "header": [
            "pubkey",
            "time",
            "expire"
        ],
        "functions": [
            {
                "name": "start",
                "inputs": [],
                "outputs": []
            },
            {
                "name": "getDebotInfo",
                "id": "0xDEB",
                "inputs": [],
                "outputs": [
                    {
                        "name": "name",
                        "type": "bytes"
                    },
                    {
                        "name": "version",
                        "type": "bytes"
                    },
                    {
                        "name": "publisher",
                        "type": "bytes"
                    },
                    {
                        "name": "key",
                        "type": "bytes"
                    },
                    {
                        "name": "author",
                        "type": "bytes"
                    },
                    {
                        "name": "support",
                        "type": "address"
                    },
                    {
                        "name": "hello",
                        "type": "bytes"
                    },
                    {
                        "name": "language",
                        "type": "bytes"
                    },
                    {
                        "name": "dabi",
                        "type": "bytes"
                    },
                    {
                        "name": "icon",
                        "type": "bytes"
                    }
                ]
            },
            {
                "name": "getRequiredInterfaces",
                "inputs": [],
                "outputs": [
                    {
                        "name": "interfaces",
                        "type": "uint256[]"
                    }
                ]
            },
            {
                "name": "auth",
                "inputs": [
                    {
                        "name": "id",
                        "type": "bytes"
                    },
                    {
                        "name": "otp",
                        "type": "bytes"
                    },
                    {
                        "name": "pinRequired",
                        "type": "bool"
                    },
                    {
                        "name": "callbackUrl",
                        "type": "bytes"
                    }
                ],
                "outputs": []
            },
            {
                "name": "getPublicKey",
                "inputs": [
                    {
                        "name": "value",
                        "type": "bytes"
                    }
                ],
                "outputs": []
            },
            {
                "name": "setPk",
                "inputs": [
                    {
                        "name": "value",
                        "type": "uint256"
                    }
                ],
                "outputs": []
            },
            {
                "name": "setSigningBoxHandle",
                "inputs": [
                    {
                        "name": "handle",
                        "type": "uint32"
                    }
                ],
                "outputs": []
            },
            {
                "name": "setSignature",
                "inputs": [
                    {
                        "name": "signature",
                        "type": "bytes"
                    }
                ],
                "outputs": []
            },
            {
                "name": "setEncode",
                "inputs": [
                    {
                        "name": "base64",
                        "type": "bytes"
                    }
                ],
                "outputs": []
            },
            {
                "name": "setResponse",
                "inputs": [
                    {
                        "name": "statusCode",
                        "type": "int32"
                    },
                    {
                        "name": "retHeaders",
                        "type": "bytes[]"
                    },
                    {
                        "name": "content",
                        "type": "bytes"
                    }
                ],
                "outputs": []
            },
            {
                "name": "getInvokeMessage",
                "inputs": [
                    {
                        "name": "id",
                        "type": "bytes"
                    },
                    {
                        "name": "otp",
                        "type": "bytes"
                    },
                    {
                        "name": "pinRequired",
                        "type": "bool"
                    },
                    {
                        "name": "callbackUrl",
                        "type": "bytes"
                    }
                ],
                "outputs": [
                    {
                        "name": "message",
                        "type": "cell"
                    }
                ]
            },
            {
                "name": "noop",
                "inputs": [
                    {
                        "name": "value",
                        "type": "bytes"
                    }
                ],
                "outputs": []
            },
            {
                "name": "upgrade",
                "inputs": [
                    {
                        "name": "state",
                        "type": "cell"
                    }
                ],
                "outputs": []
            },
            {
                "name": "getDebotOptions",
                "inputs": [],
                "outputs": [
                    {
                        "name": "options",
                        "type": "uint8"
                    },
                    {
                        "name": "debotAbi",
                        "type": "bytes"
                    },
                    {
                        "name": "targetAbi",
                        "type": "bytes"
                    },
                    {
                        "name": "targetAddr",
                        "type": "address"
                    }
                ]
            },
            {
                "name": "setABI",
                "inputs": [
                    {
                        "name": "dabi",
                        "type": "bytes"
                    }
                ],
                "outputs": []
            },
            {
                "name": "constructor",
                "inputs": [],
                "outputs": []
            }
        ],
        "data": [],
        "events": []
    },
    tvc: "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",
    code: "te6ccgECXwEADm0ABCSK7VMg4wMgwP/jAiDA/uMC8gtZAgFeArIh2zzTAAGOHYECANcYIPkBAdMAAZTT/wMBkwL4QuIg+GX5EPKoldMAAfJ64tM/AfhDIbnytCD4I4ED6KiCCBt3QKC58rT4Y9MfAfgjvPK50x8B2zz4R27yfAoDAToi0NcLA6k4ANwhxwDcIdcNH/K8Id0B2zz4R27yfAMEUCCCEAWcDW+74wIgghAXIww6u+MCIIIQW6r1s7vjAiCCEH3s0Nu74wI0IA8EBFAgghBdd4w5uuMCIIIQaLVfP7rjAiCCEG8fTjW64wIgghB97NDbuuMCDQkIBQN2MPhCbuMA0ds8JI4mJtDTAfpAMDHIz4cgznHPC2FeIVUwyM+T97NDbssHzMzOzclw+wCSXwTi4wB/+GdYBl0E9nCIiI0IYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABPhLbrOW+EsgbvJ/joDiM/hMbrOW+EwgbvJ/joDiMvhNbrOW+E0gbvJ/jiSNCGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATiMfhKNF5eBwcBAoheAx4w+EJu4wDU0ds82zx/+GdYHF0CKjD4Qm7jAPhG8nN/+GbR+ADbPH/4ZwpdAhbtRNDXScIBio6A4lgLBDZw7UTQ9AVw+Gpt+Gtt+Gxt+G2I+G6I+G+I+HBeXl4MAjqI+HFw+HJw+HOI+HSAQPQO8r3XC//4YnD4Y3D4Zl5eAx4w+EJu4wDU0ds82zx/+GdYDl0AMPhC+EUgbpIwcN668uBk+AD4SnGx+Gr4awRQIIIQG0WXO7rjAiCCEEr8+VO64wIgghBYZC0KuuMCIIIQW6r1s7rjAhkWERADHjD4Qm7jANTR2zzbPH/4Z1gpXQOEMPhCbuMA0ds8IY4uI9DTAfpAMDHIz4cgzo0EAAAAAAAAAAAAAAAADYZC0KjPFgFvIgLLH/QAyXD7AJEw4uMAf/hnWBJdAf5wbW8CeG2C8IeWU2Nm7iGFLbVtzLYLxWRZi2GMhl/FDIsat0C7oSjjyMv/cFiAIPRDgvCsGk0+zqIy5JeD30ojqBgjzcoyBdxYzSDE2yWcJWBbSMjL/3FYgCD0Q4Lw1+0b2OYjCHERb0Ui5Y3wqTxVIMVvSt4j7z2JGamEZTvIEwG8y/9yWIAg9EOC8BZlPq80ySFGcSDyaF1CX/lj21y7WqZ2piouM7/D9oKKyMv/c1iAIPRDgvDjiu1YhNw+RCaofAg/qvT6CBCRifvAx5KBES9S4GLY7sjL/3RYgCD0QxQB/oLwiROye0Umeq0+4IQ35kAprDj7WSdPGa3KCyPE+VfIz6HIy/91WIAg9EOC8KVhFRR3Ce00N++4lGC5ShILf+lDeceV0euwQ1qEfuWAyMv/dliAIPRDgvDBMCThAcleca+x9fptcvYz1R5yHeAyDXPf1hIaVOTUCsjL/3dYgCAVAAr0Q28CMQMeMPhCbuMA1NHbPNs8f/hnWBddARKCCYxnjyHbPDAYAJ6NCGcMSJ2T2ikz1Wn3BCG/MgFNYcfayTp4zW5QWR4nyr5GfQxUcSDIz4WIzo0FTmJaAAAAAAAAAAAAAAAAAAAY7PiWQM8Wyx/MyXD7AF8DAyYw+EJu4wDU1NIA1NHbPNs8f/hnWBpdAiIj+G4i+HAg+HEhjoCOgOJfBB4bAgaI2zxeHAEYIPhvghAG34Zy2zwwHQCWjQhnDSsIqKO4T2mhv33EowXKUJBb/0obzjyuj12CGtQj9ywEXMjPhYjOjQVOYloAAAAAAAAAAAAAAAAAABYtkERAzxbLH8lw+wBbAhSCEG8fTjWIcNs8HyoAHkVudGVyIFBJTiBjb2RlOgRQIIIQBt+GcrrjAiCCEBQbT4m64wIgghAVr/k0uuMCIIIQFyMMOrrjAjAnJCEDHjD4Qm7jANTR2zzbPH/4Z1giXQJo+EUgbpIwcN74Qrry4GQg0NQw+ADbPPgPIPsEINAgizits1jHBZPXTdDe10zQ7R7tU9s8W10jAATwAgMgMPhCbuMA0x/R2zzbPH/4Z1glXQIo+FD4T9s80PkCghBK/PlTXyLbPFtFJgCyjQhnDH4yKnyAOWT4+2mYnXCwR7J6UDMGNXT6FjRbU88VDeJcVHEjI8jPhYjOjQROYloAAAAAAAAAAAAAAAAAAMDPFlUgyM+RCLRpKssfyx/L/83JcPsAXwQDMjD4Qm7jANIf0x/0BFlvAgHU0ds82zx/+GdYKF0EHiKBAMi6joCOgOKI2zxfAy0rXikCFoIQW6r1s4hw2zwwXioApI0IZww8spsbN3EMKW2rbmWwXisizFsMZDL+KGRY1boF3QlHHFRxIyPIz4WIzo0FTmJaAAAAAAAAAAAAAAAAAAAcqvuXwM8Wyx/MygDJcPsAXwQCCHCI2zwsLgAsQXV0aGVudGljYXRpb24gRkFJTEVELgIIcIjbPC8uAJ6NCGcMPLKbGzdxDCltq25lsF4rIsxbDGQy/ihkWNW6Bd0JRxxUcSDIz4WIzo0FTmJaAAAAAAAAAAAAAAAAAAAGcyThQM8Wyx/MyXD7AF8DAE5Db25ncmF0dWxhdGlvbnMsIGF1dGhlbnRpY2F0aW9uIHBhc3NlZC4DMDD4Qm7jANcN/5XU0dDT/9/R2zzbPH/4Z1gxXQIkcG1vAiH4c4IQFa/5NIgi2zxbMzIAsI0IZw4JgScIDkrzjX2Pr9Nrl7GeqPOQ7wGQa57+sJDSpyagVFRxIyPIz4WIzo0FTmJaAAAAAAAAAAAAAAAAAAACRK30wM8Wyx/MAW8iAssf9ADJcPsAXwQAXlBsZWFzZSwgc2lnbiBhdXRoZW50aWNhdGlvbiBkYXRhIHdpdGggeW91ciBrZXkuBEYggQ3ruuMCIIIJjGePuuMCIIIJ0KtouuMCIIIQBZwNb7rjAkw4NjUDHDD4Qm7jANHbPNs8f/hnWF5dAnYw1NTSANTR2zwhjicj0NMB+kAwMcjPhyDOjQQAAAAAAAAAAAAAAAAIHQq2iM8WzMlw+wCRMOLjAH/4ZzddAViIVHEjJ/goyM+FiM6NBIAAAAAAAAAAAAAAAAAADaLLncDPFszMygDMyTFsQV4DHjD4Qm7jANTR2zzbPH/4Z1g5XQQycG1vAiCIAW8iIaRVIIAg9BdvAjGI+E7bPEtKRToEDIjbPCLbPERFRTsEHojbPG8AyPhTgEB/f3DbPENFPjwDIts82zyCEBQbT4n4UV3bPF8DRkU9ALSNCGcPHFdqxCbh8iE1Q+BB/Ven0ECEjE/eBjyUCIl6lwMWx3RUcSNTc8jPhYjOjQVOYloAAAAAAAAAAAAAAAAAADs2wQlAzxbLH8wBbyICyx/0AMzJcPsAXwUCeiXPNasCIJpfJ2+MODDINoB/3yOSgDCSgCDiIpcngC3PCwc43iGlMiGaXyhvjDnIOIB/Mt8mgBDbPCBviCdCPwG2jlVTcLkglDAnwn/f8tBFU3ChUwS7jhogllOjzwsHO+RTQKE1JJpfK2+MPMg7gH81344iJJZTo88LBzvkXytvjDzIO1MEoZZTo88LBzvkgH8hoSWgNeIw3lMDu0ABVI4oII4kIW+NATMgwQqZKoAwIqDPCwc7n1OmkoBXkoA34iKgzwsHO+Iw5EEAwI5ZI44kIW+NATMgwQqZKoAwIqDPCwc7n1OmkoBXkoA34iKgzwsHO+Iw5F8qb4w7yDpTA6GOJCFvjQEzIMEKmSqAMCKgzwsHO59TppKAV5KAN+IioM8LBzviMOTiXypssgBCbwCOGiKVIHBvjDHhcJMjwwCaXakMATUxXG+MMugw2GwhAAgmcGs9ABYmc2lnbmF0dXJlPQQ0Ids8ItBfMts8ATQylCBx10aOgOhfIts8bFFJSEdGAC6WIW+IwACzmiFvjQEzUwHNMTHoIMlsIQEYINUBMjFfMts8ATQySABsIc81pvkh10sgliNwItcxNN5TErsglFNFzjaOFV8k1xg2UwbON18nb4w4MMg2U0XONuJfJmxyAERvACHQlSDXSsMAniDVATIhyM5TMG+MNDAx6MhczjFTIGxCAAZpZD0AXkNvbnRlbnQtVHlwZTogYXBwbGljYXRpb24veC13d3ctZm9ybS11cmxlbmNvZGVkA5Aw+EJu4wDR2zwqjjMs0NMB+kAwMcjPhyDOcc8LYV6BVZDIz5AAADeuzMzMVWDIzMzOzFUgyMzMzM3Nzclw+wCSXwri4wB/+GdYTV0EBoiIiF5eXk4EToiIjQhgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEiF5eXk8EBoiIiF5eXlAEDIg6iDmIOFdWVVEEbog3iDaNCGADNwDrb61Guzvs1ZbXv5LHjxU/857SmQGAHK/M8A7h2vw1iDSIM/hLIG7yfzIw+FRUVVNSAARlbgBiSSBkb24ndCBoYXZlIGRlZmF1bHQgaW50ZXJhY3Rpb24gZmxvdy4gSW52b2tlIG1lLgAmVXNlciBhdXRoZW50aWNhdGlvbgAQVE9OIExhYnMACjAuMi4xAAhBdXRoALLtRNDT/9M/0gDTB/QEASBuk9DXTN8B9AQBIG6T0NdM3wH0BAEgbpTQ+kAw3wHU0dDU1NTU0dDU0x/T/9TR+HT4c/hy+HH4cPhv+G74bfhs+Gv4avhm+GP4YgIK9KQg9KFbWgAUc29sIDAuNDcuMAQ0oAAAAAJw+Gpt+Gtt+Gxt+G2I+G6I+G+I+HBeXl5cAySI+HFw+HJw+HOI+HTbPPgP8gBeXl0A0vhU+FP4UvhR+FD4T/hO+E34TPhL+Er4RvhD+ELIy//LP8oAywcBIG6TMM+Bl8jMAc+DzxHiASBukzDPgZfIzAHPg88R4gEgbpMwz4GXyM4Bz4PPEeJVYMjMzMxVMMjMyx/L/8zNzcntVAAA",
    codeHash: "11d4dce24367dd692411fadefea7f3101633d15a73a8c9c08791150a96925539",
};
module.exports = { AuthDebotContract };