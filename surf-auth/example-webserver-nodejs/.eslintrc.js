module.exports = {
    parser: 'babel-eslint',
    rules: {
        'import/no-extraneous-dependencies': [
            'error',
            { devDependencies: ['**/*.test.mjs', '**/*.test.js', '**/*.spec.js'] },
        ],
        indent: ['error', 4],
        semi: ['error', 'never'],
        camelcase: 'off',
        'max-len': ['error', { code: 120 }],
        'no-plusplus': 'off',
        'no-await-in-loop': 'off',
        'no-multiple-empty-lines': 'off',
        'no-constant-condition': 'off',
        'arrow-body-style': ['error', 'as-needed'],
        'implicit-arrow-linebreak': 'off',
        'function-paren-newline': 'off',
        'object-curly-newline': 'off',
    },

    parserOptions: {
        ecmaVersion: 2018,
    },
    extends: 'airbnb-base',
    globals: {
        BigInt: true,
    },
}
