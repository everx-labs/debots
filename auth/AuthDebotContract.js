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
    code: "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",
    codeHash: "3d4709138fd341af51d860ee5e0ef370ab52245c7f9521bc2840f7da5f2eab8d",
};
module.exports = { AuthDebotContract };