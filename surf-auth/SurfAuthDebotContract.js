const SurfAuthDebotContract = {
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
    code: "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",
    codeHash: "0a8036f22dc346e4da4d88719987757cd9cb1f424615531e5eed8188a620822f",
};
module.exports = { SurfAuthDebotContract };